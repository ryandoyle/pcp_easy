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
#include "metric_value.h"

#define READ_ONLY 1, 0
#define CONSTRUCTOR_ARGS 5
#define rb_symbol_new(name) ID2SYM(rb_intern(name))

VALUE pcpeasy_metric_class;

static VALUE initialize(VALUE self, VALUE name, VALUE values, VALUE semantics, VALUE type, VALUE units) {
    rb_iv_set(self, "@name", name);
    rb_iv_set(self, "@values", values);
    rb_iv_set(self, "@semantics", semantics);
    rb_iv_set(self, "@type", type);
    rb_iv_set(self, "@units", units);

    return self;
}

static VALUE semantics_symbol(int semantics) {
    switch(semantics) {
        case PM_SEM_COUNTER:
            return rb_symbol_new("counter");
        case PM_SEM_DISCRETE:
            return rb_symbol_new("discrete");
        case PM_SEM_INSTANT:
            return rb_symbol_new("instant");
        default:
            return Qnil;
    }
}

static int is_field_equal(const char *name, VALUE self, VALUE other) {
    return TYPE(rb_funcall(rb_iv_get(self, name), rb_intern("=="), 1, rb_iv_get(other, name))) == T_TRUE;
}

static VALUE equal(VALUE self, VALUE other) {
    if(rb_class_of(other) != pcpeasy_metric_class)
        return Qfalse;
    if(!is_field_equal("@name", self, other))
        return Qfalse;
    if(!is_field_equal("@values", self, other))
        return Qfalse;
    if(!is_field_equal("@semantics", self, other))
        return Qfalse;
    if(!is_field_equal("@type", self, other))
        return Qfalse;
    if(!is_field_equal("@units", self, other))
        return Qfalse;

    return Qtrue;
}

static VALUE type(int type) {
    switch(type) {
        case PM_TYPE_32:
            return rb_symbol_new("int32");
        case PM_TYPE_U32:
            return rb_symbol_new("uint32");
        case PM_TYPE_64:
            return rb_symbol_new("int64");
        case PM_TYPE_U64:
            return rb_symbol_new("uint64");
        case PM_TYPE_FLOAT:
            return rb_symbol_new("float");
        case PM_TYPE_DOUBLE:
            return rb_symbol_new("double");
        case PM_TYPE_STRING:
            return rb_symbol_new("string");
        case PM_TYPE_AGGREGATE:
            return rb_symbol_new("aggregate");
        case PM_TYPE_AGGREGATE_STATIC:
            return rb_symbol_new("aggregate_static");
        case PM_TYPE_EVENT:
            return rb_symbol_new("event");
        case PM_TYPE_HIGHRES_EVENT:
            return rb_symbol_new("highres_event");
        case PM_TYPE_NOSUPPORT:
            return rb_symbol_new("nosupport");
        case PM_TYPE_UNKNOWN:
        default:
            return rb_symbol_new("unknown");
    }
}

static VALUE units(pmUnits pm_units) {
    VALUE units = rb_hash_new();
    VALUE dimension = Qnil;

    if(pm_units.dimSpace == 1 && pm_units.dimTime == 0 && pm_units.dimCount == 0)
        dimension = rb_symbol_new("space");
    if(pm_units.dimSpace == 1 && pm_units.dimTime == -1 && pm_units.dimCount == 0)
        dimension = rb_symbol_new("space_time");
    if(pm_units.dimSpace == 1 && pm_units.dimTime == 0 && pm_units.dimCount == -1)
        dimension = rb_symbol_new("space_count");
    if(pm_units.dimSpace == 0 && pm_units.dimTime == 1 && pm_units.dimCount == 0)
        dimension = rb_symbol_new("time");
    if(pm_units.dimSpace == -1 && pm_units.dimTime == 1 && pm_units.dimCount == 0)
        dimension = rb_symbol_new("time_space");
    if(pm_units.dimSpace == 0 && pm_units.dimTime == 1 && pm_units.dimCount == -1)
        dimension = rb_symbol_new("time_count");
    if(pm_units.dimSpace == 0 && pm_units.dimTime == 0 && pm_units.dimCount == 1)
        dimension = rb_symbol_new("count");
    if(pm_units.dimSpace == -1 && pm_units.dimTime == 0 && pm_units.dimCount == 1)
        dimension = rb_symbol_new("count_space");
    if(pm_units.dimSpace == 0 && pm_units.dimTime == -1 && pm_units.dimCount == 1)
        dimension = rb_symbol_new("count_time");

    rb_hash_aset(units, rb_symbol_new("dimension"), dimension);

    if(pm_units.dimSpace != 0) {
        VALUE scale_space;
        switch(pm_units.scaleSpace) {
            case PM_SPACE_BYTE:
                scale_space = rb_symbol_new("bytes");
                break;
            case PM_SPACE_KBYTE:
                scale_space = rb_symbol_new("kilobytes");
                break;
            case PM_SPACE_MBYTE:
                scale_space = rb_symbol_new("megabytes");
                break;
            case PM_SPACE_GBYTE:
                scale_space = rb_symbol_new("gigabytes");
                break;
            case PM_SPACE_TBYTE:
                scale_space = rb_symbol_new("terabytes");
                break;
            case PM_SPACE_PBYTE:
                scale_space = rb_symbol_new("petabytes");
                break;
            case PM_SPACE_EBYTE:
                scale_space = rb_symbol_new("exabytes");
                break;
            default:
                scale_space = Qnil;
        }
        rb_hash_aset(units, rb_symbol_new("space"), scale_space);
    }

    if(pm_units.dimTime != 0) {
        VALUE scale_time;
        switch(pm_units.scaleTime) {
            case PM_TIME_NSEC:
                scale_time = rb_symbol_new("nanoseconds");
                break;
            case PM_TIME_USEC:
                scale_time = rb_symbol_new("microseconds");
                break;
            case PM_TIME_MSEC:
                scale_time = rb_symbol_new("milliseconds");
                break;
            case PM_TIME_SEC:
                scale_time = rb_symbol_new("seconds");
                break;
            case PM_TIME_MIN:
                scale_time = rb_symbol_new("minutes");
                break;
            case PM_TIME_HOUR:
                scale_time = rb_symbol_new("hour");
                break;
            default:
                scale_time = Qnil;
        }
        rb_hash_aset(units, rb_symbol_new("time"), scale_time);
    }

    if(pm_units.dimCount != 0) {
        rb_hash_aset(units, rb_symbol_new("count_scaling"), INT2NUM(pm_units.scaleCount));
    }

    return units;
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

static VALUE build_metric_values_for_multiple_instances(pmValueSet *pm_value_set, pmDesc pm_desc) {
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
        rb_ary_push(result, pcpeasy_metric_value_new(instance_name, pm_value_set->valfmt, &pm_value_set->vlist[i], pm_desc.type));
    }

    free(instances);
    free(instance_names);

    return result;
}

static VALUE build_metrics_values(pmValueSet *pm_value_set, pmDesc pm_desc) {
    VALUE result = rb_ary_new2(pm_value_set->numval);

    if(pm_value_set->numval > 0) {
        if (pm_desc.indom != PM_INDOM_NULL) {
            rb_ary_concat(result, build_metric_values_for_multiple_instances(pm_value_set, pm_desc));
        } else {
            return rb_ary_push(result, pcpeasy_metric_value_new(NULL, pm_value_set->valfmt, &pm_value_set->vlist[0], pm_desc.type));
        }
    }
    return result;
}

VALUE pcpeasy_metric_new(char *metric_name, pmValueSet *pm_value_set) {
    VALUE args[CONSTRUCTOR_ARGS];
    int error;
    pmDesc pm_desc;

    /* Find out how to decode the metric */
    if((error = pmLookupDesc(pm_value_set->pmid, &pm_desc))) {
        pcpeasy_raise_from_pmapi_error(error);
    }

    args[0] = rb_tainted_str_new_cstr(metric_name);
    args[1] = build_metrics_values(pm_value_set, pm_desc);
    args[2] = semantics_symbol(pm_desc.sem);
    args[3] = type(pm_desc.type);
    args[4] = units(pm_desc.units);

    return rb_class_new_instance(CONSTRUCTOR_ARGS, args, pcpeasy_metric_class);
}

void pcpeasy_metric_init(VALUE rb_cPCPEasy) {
    pcpeasy_metric_class = rb_define_class_under(rb_cPCPEasy, "Metric", rb_cObject);
    pcpeasy_metric_value_init(pcpeasy_metric_class);

    rb_define_method(pcpeasy_metric_class, "initialize", initialize, CONSTRUCTOR_ARGS);
    rb_define_method(pcpeasy_metric_class, "==", equal, 1);
    rb_define_attr(pcpeasy_metric_class, "name", READ_ONLY);
    rb_define_attr(pcpeasy_metric_class, "values", READ_ONLY);
    rb_define_attr(pcpeasy_metric_class, "semantics", READ_ONLY);
    rb_define_attr(pcpeasy_metric_class, "type", READ_ONLY);
    rb_define_attr(pcpeasy_metric_class, "units", READ_ONLY);
}