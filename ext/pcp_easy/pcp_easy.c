#include <ruby.h>
#include <pcp/pmapi.h>

#include "exceptions.h"
#include "metric.h"

VALUE pcpeasy_class = Qnil;
VALUE pcpeasy_agent_class = Qnil;


typedef struct {
    int pm_context;
} PcpEasyAgent;

static void pcpeasy_agent_deallocate(void *untyped_pcpeasy_agent) {
    PcpEasyAgent *pcpqz_agent = (PcpEasyAgent*)untyped_pcpeasy_agent;
    pmDestroyContext(pcpqz_agent->pm_context);
    xfree(pcpqz_agent);
}

static VALUE pcpeasy_agent_allocate(VALUE self) {
    PcpEasyAgent *pcpeasy_agent;
    return Data_Make_Struct(self, PcpEasyAgent, 0, pcpeasy_agent_deallocate, pcpeasy_agent);
};

static VALUE pcpeasy_agent_initialize(VALUE self, VALUE hostname_rb) {
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

static char* get_name_from_instance_id(int instance_id, int maximum_instances, int *instance_ids, char **instance_names) {
    int i;
    for(i=0; i<maximum_instances; i++) {
        if(instance_id == instance_ids[i]) {
            return instance_names[i];
        }
    }
    return NULL;
}

static VALUE decode_multiple_instances(pmDesc pm_desc, pmValueSet *pm_value_set, char *metric_name) {
    int error, i;
    int number_of_instances = pm_value_set->numval;
    int *instances = NULL;
    char **instance_names = NULL;
    VALUE result = rb_ary_new2(number_of_instances);


    if((error = pmGetInDom(pm_desc.indom, &instances, &instance_names)) < 0) {
        pcpeasy_raise_from_pmapi_error(error);
    }

    for(i = 0; i < number_of_instances; i++) {
        char *instance_name = get_name_from_instance_id(pm_value_set->vlist[i].inst, number_of_instances, instances, instance_names);
        rb_ary_push(result, pcpeasy_metric_new(metric_name, instance_name, &pm_value_set->vlist[i], &pm_desc, pm_value_set->valfmt));
    }

    free(instances);
    free(instance_names);

    return result;
}

static VALUE decode_single_instance(pmDesc pm_desc, pmValueSet *pm_value_set, char *metric_name) {
    return pcpeasy_metric_new(metric_name, NULL, &pm_value_set->vlist[0], &pm_desc, pm_value_set->valfmt);
}

static VALUE decode_single_metric(pmID pmid, pmValueSet *pm_value_set, char *metric_name) {
    int error;
    pmDesc pm_desc;

    /* No values, bail out */
    if(pm_value_set->numval == 0) {
        return Qnil;
    }

    /* Find out how to decode the metric */
    if((error = pmLookupDesc(pmid, &pm_desc))) {
        pcpeasy_raise_from_pmapi_error(error);
    }

    /* Do we have instances? */
    if(pm_desc.indom == PM_INDOM_NULL) {
        return decode_single_instance(pm_desc, pm_value_set, metric_name);
    } else {
        return decode_multiple_instances(pm_desc, pm_value_set, metric_name);
    }

}

static VALUE decode_pm_result(pmID pmid, pmResult *pm_result, char *metric_name) {
    /* No values (or somehow more than 1) */
    if (pm_result->numpmid != 1) {
        return Qnil;
    }

    return decode_single_metric(pmid, pm_result->vset[0], metric_name);
}

static VALUE pcpeasy_agent_metric(VALUE self, VALUE metric_string_rb) {
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
    result = decode_pm_result(pmid, pm_result, metric_name);
    pmFreeResult(pm_result);

    return result;
}

void Init_pcp_easy() {
    pcpeasy_class = rb_define_module("PCPEasy");
    pcpeasy_agent_class = rb_define_class_under(pcpeasy_class, "Agent", rb_cObject);
    pcpeasy_exceptions_init(pcpeasy_class);
    pcpeasy_metric_init(pcpeasy_class);

    rb_define_alloc_func(pcpeasy_agent_class, pcpeasy_agent_allocate);
    rb_define_method(pcpeasy_agent_class, "initialize", pcpeasy_agent_initialize, 1);
    rb_define_method(pcpeasy_agent_class, "metric", pcpeasy_agent_metric, 1);
    rb_define_attr(pcpeasy_agent_class, "host", 1, 0);

}