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

#define CONSTRUCTOR_ARGS 2
#define READ_ONLY 1, 0


VALUE easy_metric_value_class;


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

static VALUE initialize(VALUE self, VALUE value, VALUE instance) {
    rb_iv_set(self, "@value", value);
    rb_iv_set(self, "@instance", instance);

    return self;
}

static VALUE equal(VALUE self, VALUE other) {
    if(rb_class_of(other) != easy_metric_value_class)
        return Qfalse;
    if(!is_field_equal("@value", self, other))
        return Qfalse;
    if(!is_field_equal("@instance", self, other))
        return Qfalse;

    return Qtrue;
}

VALUE pcpeasy_metric_value_new(char *instance, int value_format, pmValue *pm_value, int type) {
    VALUE args[CONSTRUCTOR_ARGS];
    args[0] = value(value_format, pm_value, type);
    args[1] = instance_name(instance);

    return rb_class_new_instance(CONSTRUCTOR_ARGS, args, easy_metric_value_class);
}

void pcpeasy_metric_value_init(VALUE rb_cPCPEasyMetric) {
    easy_metric_value_class = rb_define_class_under(rb_cPCPEasyMetric, "Value", rb_cObject);

    rb_define_method(easy_metric_value_class, "initialize", initialize, CONSTRUCTOR_ARGS);
    rb_define_method(easy_metric_value_class, "==", equal, 1);
    rb_define_attr(easy_metric_value_class, "value", READ_ONLY);
    rb_define_attr(easy_metric_value_class, "instance", READ_ONLY);
}
