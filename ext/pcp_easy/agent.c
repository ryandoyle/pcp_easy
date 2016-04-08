/*
 * Copyright (C) 2016 Ryan Doyle
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 *
 */

#include <ruby.h>
#include <pcp/pmapi.h>

#include "exceptions.h"
#include "metric.h"

VALUE pcpeasy_agent_class = Qnil;


typedef struct {
    int pm_context;
} PcpEasyAgent;

static void deallocate(void *untyped_pcpeasy_agent) {
    PcpEasyAgent *pcpqz_agent = (PcpEasyAgent*)untyped_pcpeasy_agent;
    pmDestroyContext(pcpqz_agent->pm_context);
    xfree(pcpqz_agent);
}

static VALUE allocate(VALUE self) {
    PcpEasyAgent *pcpeasy_agent;
    return Data_Make_Struct(self, PcpEasyAgent, 0, deallocate, pcpeasy_agent);
};

static VALUE initialize(VALUE self, VALUE hostname_rb) {
    PcpEasyAgent *pcpeasy_agent;
    const char *hostname;
    int pm_context;

    Data_Get_Struct(self, PcpEasyAgent, pcpeasy_agent);
    hostname = StringValueCStr(hostname_rb);

    if((pm_context = pmNewContext(PM_CONTEXT_HOST, hostname)) < 0) {
        pcpeasy_raise_from_pmapi_error(pm_context);
    }

    rb_iv_set(self, "@host", hostname_rb);

    /* Store away with this instance */
    pcpeasy_agent->pm_context = pm_context;

    return self;
}

static VALUE decode_pm_result(pmResult *pm_result, char *metric_name, int context) {
    /* No values (or somehow more than 1) */
    if (pm_result->numpmid != 1) {
        return Qnil;
    }

    return pcpeasy_metric_new(metric_name, pm_result->vset[0], context);
}

static VALUE metric(VALUE self, VALUE metric_string_rb) {
    /* Get our context */
    PcpEasyAgent *pcpeasy_agent;
    Data_Get_Struct(self, PcpEasyAgent, pcpeasy_agent);
    pmUseContext(pcpeasy_agent->pm_context);

    /* Get the pmID */
    int error;
    pmID pmid;
    pmID *pmid_list = ALLOC(pmID);
    char **metric_list = ALLOC(char*);
    char *metric_name = StringValueCStr(metric_string_rb);
    metric_list[0] = metric_name;
    if((error = pmLookupName(1, metric_list, pmid_list)) < 0) {
        xfree(pmid_list);
        xfree(metric_list);
        pcpeasy_raise_from_pmapi_error(error);
    }
    pmid = pmid_list[0];
    xfree(pmid_list);
    xfree(metric_list);


    /* Do the fetch */
    pmResult *pm_result;
    VALUE result;
    if((error = pmFetch(1, &pmid, &pm_result))) {
        pcpeasy_raise_from_pmapi_error(error);
    }

    /* Decode the result */
    result = decode_pm_result(pm_result, metric_name, pcpeasy_agent->pm_context);
    pmFreeResult(pm_result);

    return result;
}


void pcpeasy_agent_init(VALUE rb_cPCPEasy) {
    pcpeasy_agent_class = rb_define_class_under(rb_cPCPEasy, "Agent", rb_cObject);

    rb_define_alloc_func(pcpeasy_agent_class, allocate);
    rb_define_method(pcpeasy_agent_class, "initialize", initialize, 1);
    rb_define_method(pcpeasy_agent_class, "metric", metric, 1);
    rb_define_attr(pcpeasy_agent_class, "host", 1, 0);
}