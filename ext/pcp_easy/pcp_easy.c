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

#include "exceptions.h"
#include "metric.h"
#include "agent.h"

VALUE pcpeasy_class = Qnil;



void Init_pcp_easy() {
    pcpeasy_class = rb_define_module("PCPEasy");
    pcpeasy_exceptions_init(pcpeasy_class);
    pcpeasy_metric_init(pcpeasy_class);
    pcpeasy_agent_init(pcpeasy_class);
}