#ifndef PCPEASY_RUBY_EXCEPTIONS_H
#define PCPEASY_RUBY_EXCEPTIONS_H 1

#include <ruby.h>
VALUE pcpeasy_error;
void pcpeasy_exceptions_init(VALUE pcpeasy_class);
void pcpeasy_raise_from_pmapi_error(int error_number);

#endif
