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

typedef struct {
    char **names;
    pmID *pmids;
    int number_of_names;
} PcpEasyNames;

static void free_metric_names(PcpEasyNames names) {
    xfree(names.names);
    xfree(names.pmids);
}

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

static char* lookup_metric_name_from_pmid(pmID pmid, PcpEasyNames names) {
    int i;
    for (i = 0; i < names.number_of_names; i++) {
        if(names.pmids[i] == pmid) {
            return names.names[i];
        }
    }
    return NULL;
}

static PcpEasyNames get_metric_names(VALUE metric_strings) {
    /* Get the pmID */
    int error, i;
    PcpEasyNames names;
    names.number_of_names = RARRAY_LENINT(metric_strings);
    names.pmids = ALLOC_N(pmID, names.number_of_names);
    names.names = ALLOC_N(char*, names.number_of_names);
    for(i = 0; i < names.number_of_names; i++) {
        VALUE metric_string = rb_ary_entry(metric_strings, i);
        if(TYPE(metric_string) != T_STRING) {
            free_metric_names(names);
            rb_raise(rb_eArgError, "metric name must be a String");
        }
        names.names[i] = RSTRING_PTR(metric_string);
    }
    if((error = pmLookupName(names.number_of_names, names.names, names.pmids)) < 0) {
        free_metric_names(names);
        pcpeasy_raise_from_pmapi_error(error);
    }
    return names;
}

static VALUE metric(VALUE self, VALUE metric_strings) {
    PcpEasyAgent *pcpeasy_agent;
    PcpEasyNames names;
    int error, i;
    pmResult *pm_result;
    VALUE result;

    /* Check args */
    if(TYPE(metric_strings) != T_ARRAY) {
        rb_raise(rb_eArgError, "metric names must be an Array");
    }

    /* Get our context */
    Data_Get_Struct(self, PcpEasyAgent, pcpeasy_agent);
    pmUseContext(pcpeasy_agent->pm_context);

    /* Get the pmID */
    names = get_metric_names(metric_strings);

    /* Do the fetch */

    if((error = pmFetch(names.number_of_names, names.pmids, &pm_result))) {
        free_metric_names(names);
        pcpeasy_raise_from_pmapi_error(error);
    }

    /* Decode the result */
    result = rb_ary_new2(pm_result->numpmid);
    for(i = 0; i < pm_result->numpmid;  i++) {
        char *metric_name = lookup_metric_name_from_pmid(pm_result->vset[i]->pmid, names);
        rb_ary_push(result, pcpeasy_metric_new(metric_name, pm_result->vset[i], pcpeasy_agent->pm_context));
    }
    pmFreeResult(pm_result);
    free_metric_names(names);

    return result;
}

static VALUE single_metric(VALUE self, VALUE metric_string_rb) {
    VALUE query = rb_ary_new2(1);
    VALUE result;
    rb_ary_push(query, metric_string_rb);

    result = metric(self, query);

    return RARRAY_AREF(result, 0);
}

void pcpeasy_agent_init(VALUE rb_cPCPEasy) {
    pcpeasy_agent_class = rb_define_class_under(rb_cPCPEasy, "Agent", rb_cObject);

    rb_define_alloc_func(pcpeasy_agent_class, allocate);
    rb_define_method(pcpeasy_agent_class, "initialize", initialize, 1);
    rb_define_method(pcpeasy_agent_class, "metric", single_metric, 1);
    rb_define_method(pcpeasy_agent_class, "metrics", metric, 1);
    rb_define_attr(pcpeasy_agent_class, "host", 1, 0);
}