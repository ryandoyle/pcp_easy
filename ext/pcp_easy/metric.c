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

#define READ_ONLY 1, 0
#define CONSTRUCTOR_ARGS 6
#define rb_symbol_new(name) ID2SYM(rb_intern(name))

VALUE pcpeasy_metric_class;

static VALUE initialize(VALUE self, VALUE name, VALUE value, VALUE instance, VALUE semantics, VALUE type, VALUE units) {
    rb_iv_set(self, "@name", name);
    rb_iv_set(self, "@value", value);
    rb_iv_set(self, "@instance", instance);
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

static VALUE instance_name(char *instance) {
    if(instance == NULL) {
        return Qnil;
    }
    return rb_tainted_str_new_cstr(instance);
}

static VALUE value(int value_format, pmValue *pm_value, int type) {
    pmAtomValue pm_atom_value;
    int error;

    if((error = pmExtractValue(value_format, pm_value, type, &pm_atom_value, type)) < 0) {
        pcpeasy_raise_from_pmapi_error(error);
    }

    switch(type) {
        case PM_TYPE_32:
            return LONG2NUM(pm_atom_value.l);
        case PM_TYPE_U32:
            return ULONG2NUM(pm_atom_value.ul);
        case PM_TYPE_64:
            return LL2NUM(pm_atom_value.ll);
        case PM_TYPE_U64:
            return ULL2NUM(pm_atom_value.ull);
        case PM_TYPE_FLOAT:
            return DBL2NUM(pm_atom_value.f);
        case PM_TYPE_DOUBLE:
            return DBL2NUM(pm_atom_value.d);
        case PM_TYPE_STRING:
            return rb_tainted_str_new_cstr(pm_atom_value.vbp->vbuf);
        default:
            rb_raise(pcpeasy_error, "Metric type %d not supported", type);
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
    if(!is_field_equal("@value", self, other))
        return Qfalse;
    if(!is_field_equal("@instance", self, other))
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

VALUE pcpeasy_metric_new(char *metric_name, char *instance, pmValue *pm_value, pmDesc *pm_desc, int value_format) {
    VALUE args[CONSTRUCTOR_ARGS];
    args[0] = rb_tainted_str_new_cstr(metric_name);
    args[1] = value(value_format, pm_value, pm_desc->type);
    args[2] = instance_name(instance);
    args[3] = semantics_symbol(pm_desc->sem);
    args[4] = type(pm_desc->type);
    args[5] = units(pm_desc->units);

    return rb_class_new_instance(CONSTRUCTOR_ARGS, args, pcpeasy_metric_class);
}

void pcpeasy_metric_init(VALUE pcpeasy_class) {
    pcpeasy_metric_class = rb_define_class_under(pcpeasy_class, "Metric", rb_cObject);

    rb_define_method(pcpeasy_metric_class, "initialize", initialize, CONSTRUCTOR_ARGS);
    rb_define_method(pcpeasy_metric_class, "==", equal, 1);
    rb_define_attr(pcpeasy_metric_class, "name", READ_ONLY);
    rb_define_attr(pcpeasy_metric_class, "value", READ_ONLY);
    rb_define_attr(pcpeasy_metric_class, "instance", READ_ONLY);
    rb_define_attr(pcpeasy_metric_class, "semantics", READ_ONLY);
    rb_define_attr(pcpeasy_metric_class, "type", READ_ONLY);
    rb_define_attr(pcpeasy_metric_class, "units", READ_ONLY);
}