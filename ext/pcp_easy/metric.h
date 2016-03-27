#ifndef PCPEASY_RUBY_METRIC_H
#define PCPEASY_RUBY_METRIC_H 1

#include <ruby.h>
#include <pcp/pmapi.h>

void pcpeasy_metric_init(VALUE pcpeasy_class);
VALUE pcpeasy_metric_new(char *metric_name, char *instance, pmValue *pm_value, pmDesc *pm_desc, int value_format);

#endif
