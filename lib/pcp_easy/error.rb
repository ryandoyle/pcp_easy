require 'pcp_easy/pmapi'


module PCPEasy
  class Error < StandardError

    GenericError = Class.new(self)
    PMNSError = Class.new(self)
    NoPMNSError = Class.new(self)
    DupPMNSError = Class.new(self)
    TextError = Class.new(self)
    AppVersionError = Class.new(self)
    ValueError = Class.new(self)
    TimeoutError = Class.new(self)
    NoDataError = Class.new(self)
    ResetError = Class.new(self)
    NameError = Class.new(self)
    PMIDError = Class.new(self)
    InDomError  = Class.new(self)
    InstError  = Class.new(self)
    UnitError  = Class.new(self)
    ConvError  = Class.new(self)
    TruncError  = Class.new(self)
    SignError  = Class.new(self)
    ProfileError  = Class.new(self)
    IPCError = Class.new(self)
    EOFError = Class.new(self)
    NotHostError = Class.new(self)
    EOLError = Class.new(self)
    ModeError = Class.new(self)
    LabelError = Class.new(self)
    LogRecError = Class.new(self)
    NotArchiveError = Class.new(self)
    LogFileError = Class.new(self)
    NoContextError = Class.new(self)
    ProfileSpecError = Class.new(self)
    PMIDLogError = Class.new(self)
    InDomLogError = Class.new(self)
    InstLogError = Class.new(self)
    NoProfileError = Class.new(self)
    NoAgentError = Class.new(self)
    PermissionError = Class.new(self)
    ConnLimitError = Class.new(self)
    AgainError = Class.new(self)
    IsConnError = Class.new(self)
    NotConnError = Class.new(self)
    NeedPortError = Class.new(self)
    NonLeafError = Class.new(self)
    TypeError = Class.new(self)
    ThreadError = Class.new(self)
    NoContainerError = Class.new(self)
    BadStoreError = Class.new(self)
    TooSmallError = Class.new(self)
    TooBigError = Class.new(self)
    FaultError = Class.new(self)
    PMDAReadyError = Class.new(self)
    PMDANotReadyError = Class.new(self)
    NYIError = Class.new(self)

    ERRORS = {
        PCPEasy::PMAPI::PM_ERR_GENERIC => GenericError,
        PCPEasy::PMAPI::PM_ERR_PMNS => PMNSError,
        PCPEasy::PMAPI::PM_ERR_NOPMNS => NoPMNSError,
        PCPEasy::PMAPI::PM_ERR_DUPPMNS=> DupPMNSError,
        PCPEasy::PMAPI::PM_ERR_TEXT => TextError,
        PCPEasy::PMAPI::PM_ERR_APPVERSION => AppVersionError,
        PCPEasy::PMAPI::PM_ERR_VALUE => ValueError,
        PCPEasy::PMAPI::PM_ERR_TIMEOUT => TimeoutError,
        PCPEasy::PMAPI::PM_ERR_NODATA => NoDataError,
        PCPEasy::PMAPI::PM_ERR_RESET=> ResetError,
        PCPEasy::PMAPI::PM_ERR_NAME => NameError,
        PCPEasy::PMAPI::PM_ERR_PMID => PMIDError,
        PCPEasy::PMAPI::PM_ERR_INDOM => InDomError,
        PCPEasy::PMAPI::PM_ERR_INST => InstError,
        PCPEasy::PMAPI::PM_ERR_UNIT => UnitError,
        PCPEasy::PMAPI::PM_ERR_CONV => ConvError,
        PCPEasy::PMAPI::PM_ERR_CONV => TruncError,
        PCPEasy::PMAPI::PM_ERR_SIGN => SignError,
        PCPEasy::PMAPI::PM_ERR_PROFILE => ProfileError,
        PCPEasy::PMAPI::PM_ERR_IPC => IPCError,
        PCPEasy::PMAPI::PM_ERR_EOF => EOFError,
        PCPEasy::PMAPI::PM_ERR_NOTHOST => NotHostError,
        PCPEasy::PMAPI::PM_ERR_EOL => EOLError,
        PCPEasy::PMAPI::PM_ERR_MODE => ModeError,
        PCPEasy::PMAPI::PM_ERR_LABEL => LabelError,
        PCPEasy::PMAPI::PM_ERR_LOGREC => LogRecError,
        PCPEasy::PMAPI::PM_ERR_NOTARCHIVE => NotArchiveError,
        PCPEasy::PMAPI::PM_ERR_LOGFILE => LogFileError,
        PCPEasy::PMAPI::PM_ERR_NOCONTEXT => NoContextError,
        PCPEasy::PMAPI::PM_ERR_PROFILESPEC => ProfileSpecError,
        PCPEasy::PMAPI::PM_ERR_PMID_LOG => PMIDLogError,
        PCPEasy::PMAPI::PM_ERR_INDOM_LOG => InDomLogError,
        PCPEasy::PMAPI::PM_ERR_INST_LOG => InstLogError,
        PCPEasy::PMAPI::PM_ERR_NOPROFILE => NoProfileError,
        PCPEasy::PMAPI::PM_ERR_NOAGENT => NoAgentError,
        PCPEasy::PMAPI::PM_ERR_PERMISSION => PermissionError,
        PCPEasy::PMAPI::PM_ERR_CONNLIMIT => ConnLimitError,
        PCPEasy::PMAPI::PM_ERR_AGAIN => AgainError,
        PCPEasy::PMAPI::PM_ERR_ISCONN => IsConnError,
        PCPEasy::PMAPI::PM_ERR_NOTCONN => NotConnError,
        PCPEasy::PMAPI::PM_ERR_NEEDPORT => NeedPortError,
        PCPEasy::PMAPI::PM_ERR_NONLEAF => NonLeafError,
        PCPEasy::PMAPI::PM_ERR_TYPE => TypeError,
        PCPEasy::PMAPI::PM_ERR_THREAD => ThreadError,
        PCPEasy::PMAPI::PM_ERR_NOCONTAINER => NoContainerError,
        PCPEasy::PMAPI::PM_ERR_BADSTORE => BadStoreError,
        PCPEasy::PMAPI::PM_ERR_TOOSMALL => TooSmallError,
        PCPEasy::PMAPI::PM_ERR_TOOBIG => TooBigError,
        PCPEasy::PMAPI::PM_ERR_FAULT => FaultError,
        PCPEasy::PMAPI::PM_ERR_PMDAREADY => PMDAReadyError,
        PCPEasy::PMAPI::PM_ERR_PMDANOTREADY => PMDANotReadyError,
        PCPEasy::PMAPI::PM_ERR_NYI => NYIError,
    }

    def self.from_pmapi_error_number(number)
      error_class = ERRORS[number] ||= self
      error_class.new PMAPI.pmErrStr(number)
    end
  end
end