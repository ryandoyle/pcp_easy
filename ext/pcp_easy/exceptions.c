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

#include "exceptions.h"

#include <ruby.h>
#include <pcp/pmapi.h>

/* Error classes */
VALUE pcpeasy_error = Qnil;
VALUE pcpeasy_pmns_error = Qnil;
VALUE pcpeasy_no_pmns_error = Qnil;
VALUE pcpeasy_dup_pmns_error = Qnil;
VALUE pcpeasy_text_error = Qnil;
VALUE pcpeasy_app_version_error = Qnil;
VALUE pcpeasy_value_error = Qnil;
VALUE pcpeasy_timeout_error = Qnil;
VALUE pcpeasy_no_data_error = Qnil;
VALUE pcpeasy_reset_error = Qnil;
VALUE pcpeasy_name_error = Qnil;
VALUE pcpeasy_pmid_error = Qnil;
VALUE pcpeasy_indom_error = Qnil;
VALUE pcpeasy_inst_error = Qnil;
VALUE pcpeasy_unit_error = Qnil;
VALUE pcpeasy_conv_error = Qnil;
VALUE pcpeasy_trunc_error = Qnil;
VALUE pcpeasy_sign_error = Qnil;
VALUE pcpeasy_profile_error = Qnil;
VALUE pcpeasy_ipc_error = Qnil;
VALUE pcpeasy_eof_error = Qnil;
VALUE pcpeasy_not_host_error = Qnil;
VALUE pcpeasy_eol_error = Qnil;
VALUE pcpeasy_mode_error = Qnil;
VALUE pcpeasy_label_error = Qnil;
VALUE pcpeasy_log_rec_error = Qnil;
VALUE pcpeasy_not_archive_error = Qnil;
VALUE pcpeasy_log_file_error = Qnil;
VALUE pcpeasy_no_context_error = Qnil;
VALUE pcpeasy_profile_spec_error = Qnil;
VALUE pcpeasy_pmid_log_error = Qnil;
VALUE pcpeasy_indom_log_error = Qnil;
VALUE pcpeasy_inst_log_error = Qnil;
VALUE pcpeasy_no_profile_error = Qnil;
VALUE pcpeasy_no_agent_error = Qnil;
VALUE pcpeasy_permission_error = Qnil;
VALUE pcpeasy_connlimit_error = Qnil;
VALUE pcpeasy_again_error = Qnil;
VALUE pcpeasy_is_conn_error = Qnil;
VALUE pcpeasy_not_conn_error = Qnil;
VALUE pcpeasy_need_port_error = Qnil;
VALUE pcpeasy_non_leaf_error = Qnil;
VALUE pcpeasy_type_error = Qnil;
VALUE pcpeasy_thread_error = Qnil;
VALUE pcpeasy_no_container_error = Qnil;
VALUE pcpeasy_bad_store_error = Qnil;
VALUE pcpeasy_too_small_error = Qnil;
VALUE pcpeasy_too_big_error = Qnil;
VALUE pcpeasy_fault_error = Qnil;
VALUE pcpeasy_pmda_ready_error = Qnil;
VALUE pcpeasy_pmda_not_ready_error = Qnil;
VALUE pcpeasy_nyi_error = Qnil;


static const struct pmapi_to_ruby_exception {
    int pmapi_error;
    VALUE *ruby_exception;
} pmapi_to_ruby_exception_map[] = {
        {PM_ERR_GENERIC, &pcpeasy_error},
        {PM_ERR_PMNS, &pcpeasy_pmns_error},
        {PM_ERR_NOPMNS, &pcpeasy_no_pmns_error},
        {PM_ERR_DUPPMNS, &pcpeasy_dup_pmns_error},
        {PM_ERR_TEXT, &pcpeasy_text_error},
        {PM_ERR_APPVERSION, &pcpeasy_app_version_error},
        {PM_ERR_VALUE, &pcpeasy_value_error},
        {PM_ERR_TIMEOUT, &pcpeasy_timeout_error},
        {PM_ERR_NODATA, &pcpeasy_no_data_error},
        {PM_ERR_RESET, &pcpeasy_reset_error},
        {PM_ERR_NAME, &pcpeasy_name_error},
        {PM_ERR_PMID, &pcpeasy_pmid_error},
        {PM_ERR_INDOM, &pcpeasy_indom_error},
        {PM_ERR_INST, &pcpeasy_inst_error},
        {PM_ERR_UNIT, &pcpeasy_unit_error},
        {PM_ERR_CONV, &pcpeasy_conv_error},
        {PM_ERR_TRUNC, &pcpeasy_trunc_error},
        {PM_ERR_SIGN, &pcpeasy_sign_error},
        {PM_ERR_PROFILE, &pcpeasy_profile_error},
        {PM_ERR_IPC, &pcpeasy_ipc_error},
        {PM_ERR_EOF, &pcpeasy_eof_error},
        {PM_ERR_NOTHOST, &pcpeasy_not_host_error},
        {PM_ERR_EOL, &pcpeasy_eol_error},
        {PM_ERR_MODE, &pcpeasy_mode_error},
        {PM_ERR_LABEL, &pcpeasy_label_error},
        {PM_ERR_LOGREC, &pcpeasy_log_rec_error},
        {PM_ERR_NOTARCHIVE, &pcpeasy_not_archive_error},
        {PM_ERR_LOGFILE, &pcpeasy_log_file_error},
        {PM_ERR_NOCONTEXT, &pcpeasy_no_context_error},
        {PM_ERR_PROFILESPEC, &pcpeasy_profile_spec_error},
        {PM_ERR_PMID_LOG, &pcpeasy_pmid_log_error},
        {PM_ERR_INDOM_LOG, &pcpeasy_indom_log_error},
        {PM_ERR_INST_LOG, &pcpeasy_inst_log_error},
        {PM_ERR_NOPROFILE, &pcpeasy_no_profile_error},
        {PM_ERR_NOAGENT, &pcpeasy_no_agent_error},
        {PM_ERR_PERMISSION, &pcpeasy_permission_error},
        {PM_ERR_CONNLIMIT, &pcpeasy_connlimit_error},
        {PM_ERR_AGAIN, &pcpeasy_again_error},
        {PM_ERR_ISCONN, &pcpeasy_is_conn_error},
        {PM_ERR_NOTCONN, &pcpeasy_not_conn_error},
        {PM_ERR_NEEDPORT, &pcpeasy_need_port_error},
        {PM_ERR_NONLEAF, &pcpeasy_non_leaf_error},
        {PM_ERR_TYPE, &pcpeasy_type_error},
        {PM_ERR_THREAD, &pcpeasy_thread_error},
        {PM_ERR_NOCONTAINER, &pcpeasy_no_container_error},
        {PM_ERR_BADSTORE, &pcpeasy_bad_store_error},
        {PM_ERR_TOOSMALL, &pcpeasy_too_small_error},
        {PM_ERR_TOOBIG, &pcpeasy_too_big_error},
        {PM_ERR_FAULT, &pcpeasy_fault_error},
        {PM_ERR_PMDAREADY, &pcpeasy_pmda_ready_error},
        {PM_ERR_PMDANOTREADY, &pcpeasy_pmda_not_ready_error},
        {PM_ERR_NYI, &pcpeasy_nyi_error},
};

static VALUE get_exception_from_pmapi_error_code(int error_code) {
    int i, number_of_pmapi_to_ruby_errors;
    number_of_pmapi_to_ruby_errors = sizeof(pmapi_to_ruby_exception_map) / sizeof(struct pmapi_to_ruby_exception);

    for(i=0; i < number_of_pmapi_to_ruby_errors; i++) {
        if(pmapi_to_ruby_exception_map[i].pmapi_error == error_code) {
            return *pmapi_to_ruby_exception_map[i].ruby_exception;
        }
    }
    /* Default to a generic error */
    return pcpeasy_error;
}

void pcpeasy_raise_from_pmapi_error(int error_number) {
    char errmsg[PM_MAXERRMSGLEN];
    VALUE exception_to_raise;

    exception_to_raise = get_exception_from_pmapi_error_code(error_number);

    rb_raise(exception_to_raise, (const char *)pmErrStr_r(error_number, (char *)&errmsg, sizeof(errmsg)));
}


void pcpeasy_exceptions_init(VALUE pcpeasy_class) {
    pcpeasy_error = rb_define_class_under(pcpeasy_class, "Error", rb_eStandardError);
    pcpeasy_pmns_error = rb_define_class_under(pcpeasy_class, "PMNSError", pcpeasy_error);
    pcpeasy_no_pmns_error = rb_define_class_under(pcpeasy_class, "NoPMNSError", pcpeasy_error);
    pcpeasy_dup_pmns_error = rb_define_class_under(pcpeasy_class, "DupPMNSError", pcpeasy_error);
    pcpeasy_text_error = rb_define_class_under(pcpeasy_class, "TextError", pcpeasy_error);
    pcpeasy_app_version_error = rb_define_class_under(pcpeasy_class, "AppVersionError", pcpeasy_error);
    pcpeasy_value_error = rb_define_class_under(pcpeasy_class, "ValueError", pcpeasy_error);
    pcpeasy_timeout_error = rb_define_class_under(pcpeasy_class, "TimeoutError", pcpeasy_error);
    pcpeasy_no_data_error = rb_define_class_under(pcpeasy_class, "NoDataError", pcpeasy_error);
    pcpeasy_reset_error = rb_define_class_under(pcpeasy_class, "ResetError", pcpeasy_error);
    pcpeasy_name_error = rb_define_class_under(pcpeasy_class, "NameError", pcpeasy_error);
    pcpeasy_pmid_error = rb_define_class_under(pcpeasy_class, "PMIDError", pcpeasy_error);
    pcpeasy_indom_error = rb_define_class_under(pcpeasy_class, "InDomError", pcpeasy_error);
    pcpeasy_inst_error = rb_define_class_under(pcpeasy_class, "InstError", pcpeasy_error);
    pcpeasy_unit_error = rb_define_class_under(pcpeasy_class, "UnitError", pcpeasy_error);
    pcpeasy_conv_error = rb_define_class_under(pcpeasy_class, "ConvError", pcpeasy_error);
    pcpeasy_trunc_error = rb_define_class_under(pcpeasy_class, "TruncError", pcpeasy_error);
    pcpeasy_sign_error = rb_define_class_under(pcpeasy_class, "SignError", pcpeasy_error);
    pcpeasy_profile_error = rb_define_class_under(pcpeasy_class, "ProfileError", pcpeasy_error);
    pcpeasy_ipc_error = rb_define_class_under(pcpeasy_class, "IPCError", pcpeasy_error);
    pcpeasy_eof_error = rb_define_class_under(pcpeasy_class, "EOFError", pcpeasy_error);
    pcpeasy_not_host_error = rb_define_class_under(pcpeasy_class, "NotHostError", pcpeasy_error);
    pcpeasy_eol_error = rb_define_class_under(pcpeasy_class, "EOLError", pcpeasy_error);
    pcpeasy_mode_error = rb_define_class_under(pcpeasy_class, "ModeError", pcpeasy_error);
    pcpeasy_label_error = rb_define_class_under(pcpeasy_class, "LabelError", pcpeasy_error);
    pcpeasy_log_rec_error = rb_define_class_under(pcpeasy_class, "LogRecError", pcpeasy_error);
    pcpeasy_not_archive_error = rb_define_class_under(pcpeasy_class, "NotArchiveError", pcpeasy_error);
    pcpeasy_log_file_error = rb_define_class_under(pcpeasy_class, "LogFileError", pcpeasy_error);
    pcpeasy_no_context_error = rb_define_class_under(pcpeasy_class, "NoContextError", pcpeasy_error);
    pcpeasy_profile_spec_error = rb_define_class_under(pcpeasy_class, "ProfileSpecError", pcpeasy_error);
    pcpeasy_pmid_log_error = rb_define_class_under(pcpeasy_class, "PMIDLogError", pcpeasy_error);
    pcpeasy_indom_log_error = rb_define_class_under(pcpeasy_class, "InDomLogError", pcpeasy_error);
    pcpeasy_inst_log_error = rb_define_class_under(pcpeasy_class, "InstLogError", pcpeasy_error);
    pcpeasy_no_profile_error = rb_define_class_under(pcpeasy_class, "NoProfileError", pcpeasy_error);
    pcpeasy_no_agent_error = rb_define_class_under(pcpeasy_class, "NoAgentError", pcpeasy_error);
    pcpeasy_permission_error = rb_define_class_under(pcpeasy_class, "PermissionError", pcpeasy_error);
    pcpeasy_connlimit_error = rb_define_class_under(pcpeasy_class, "ConnLimitError", pcpeasy_error);
    pcpeasy_again_error = rb_define_class_under(pcpeasy_class, "AgainError", pcpeasy_error);
    pcpeasy_is_conn_error = rb_define_class_under(pcpeasy_class, "IsConnError", pcpeasy_error);
    pcpeasy_not_conn_error = rb_define_class_under(pcpeasy_class, "NotConnError", pcpeasy_error);
    pcpeasy_need_port_error = rb_define_class_under(pcpeasy_class, "NeedPortError", pcpeasy_error);
    pcpeasy_non_leaf_error = rb_define_class_under(pcpeasy_class, "NonLeafError", pcpeasy_error);
    pcpeasy_type_error = rb_define_class_under(pcpeasy_class, "TypeError", pcpeasy_error);
    pcpeasy_thread_error = rb_define_class_under(pcpeasy_class, "ThreadError", pcpeasy_error);
    pcpeasy_no_container_error = rb_define_class_under(pcpeasy_class, "NoContainerError", pcpeasy_error);
    pcpeasy_bad_store_error = rb_define_class_under(pcpeasy_class, "BadStoreError", pcpeasy_error);
    pcpeasy_too_small_error = rb_define_class_under(pcpeasy_class, "TooSmallError", pcpeasy_error);
    pcpeasy_too_big_error = rb_define_class_under(pcpeasy_class, "TooBigError", pcpeasy_error);
    pcpeasy_fault_error = rb_define_class_under(pcpeasy_class, "FaultError", pcpeasy_error);
    pcpeasy_pmda_ready_error = rb_define_class_under(pcpeasy_class, "PMDAReadyError", pcpeasy_error);
    pcpeasy_pmda_not_ready_error = rb_define_class_under(pcpeasy_class, "PMDANotReadyError", pcpeasy_error);
    pcpeasy_nyi_error = rb_define_class_under(pcpeasy_class, "NYIError", pcpeasy_error);
}