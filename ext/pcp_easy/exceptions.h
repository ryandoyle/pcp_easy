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

#ifndef PCPEASY_RUBY_EXCEPTIONS_H
#define PCPEASY_RUBY_EXCEPTIONS_H 1

#include <ruby.h>
extern VALUE pcpeasy_error;
void pcpeasy_exceptions_init(VALUE pcpeasy_class);
void pcpeasy_raise_from_pmapi_error(int error_number);

#endif
