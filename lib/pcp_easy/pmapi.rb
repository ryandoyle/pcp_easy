require 'ffi'
require 'pcp_easy/error'
require 'pcp_easy/pmapi/pm_desc'
require 'pcp_easy/pmapi/pm_result'
require 'pcp_easy/pmapi/pm_value'
require 'pcp_easy/pmapi/pm_atom_value'

module PCPEasy
  module FFIInternal
    extend FFI::Library
    ffi_lib 'libpcp.so.3'

    typedef :uint, :pmid
    typedef :uint, :indom

    attach_function :pmNewContext, [:int, :string], :int
    attach_function :pmErrStr_r, [:int, :pointer, :int], :string
    attach_function :pmUseContext, [:int], :void
    attach_function :pmLookupName, [:int, :pointer, :pointer], :int
    attach_function :pmLookupDesc, [:pmid, :pointer], :int
    attach_function :pmDestroyContext, [:int], :int
    attach_function :pmFetch, [:int, :pointer, :pointer], :int
    attach_function :pmFreeResult, [:pointer], :void
    attach_function :pmGetInDom, [:indom, :pointer, :pointer], :int
    attach_function :pmExtractValue, [:int, PMAPI::PmValue, :int, PMAPI::PmAtomValue, :int], :int
  end
  module LibC
    extend FFI::Library
    ffi_lib FFI::Library::LIBC
    attach_function :free, [:pointer], :void
  end

  class PMAPI
    extend Forwardable

    PM_CONTEXT_HOST = 1

    PM_MAXERRMSGLEN = 128

    PM_TYPE_NOSUPPORT = -1
    PM_TYPE_32    = 0
    PM_TYPE_U32   = 1
    PM_TYPE_64    = 2
    PM_TYPE_U64   = 3
    PM_TYPE_FLOAT   = 4
    PM_TYPE_DOUBLE  = 5
    PM_TYPE_STRING  = 6
    PM_TYPE_AGGREGATE         = 7
    PM_TYPE_AGGREGATE_STATIC  = 8
    PM_TYPE_EVENT   = 9
    PM_TYPE_HIGHRES_EVENT = 10
    PM_TYPE_UNKNOWN	      = 255

    PM_VAL_INSITU	= 0
    PM_VAL_DPTR	= 1
    PM_VAL_SPTR	= 2


    PM_INDOM_NULL	= 0xffffffff

    PM_SEM_COUNTER  = 1
    PM_SEM_INSTANT  = 3
    PM_SEM_DISCRETE = 4

    PM_SPACE_BYTE = 0
    PM_SPACE_KBYTE = 1
    PM_SPACE_MBYTE = 2
    PM_SPACE_GBYTE = 3
    PM_SPACE_TBYTE = 4
    PM_SPACE_PBYTE = 5
    PM_SPACE_EBYTE = 6

    PM_TIME_NSEC = 0
    PM_TIME_USEC = 1
    PM_TIME_MSEC = 2
    PM_TIME_SEC = 3
    PM_TIME_MIN = 4
    PM_TIME_HOUR = 5

    PM_COUNT_ONE = 0

    PM_ERR_BASE2 = 12345
    PM_ERR_BASE = PM_ERR_BASE2

    PM_ERR_GENERIC = (-PM_ERR_BASE-0)
    PM_ERR_PMNS = (-PM_ERR_BASE-1)
    PM_ERR_NOPMNS = (-PM_ERR_BASE-2)
    PM_ERR_DUPPMNS = (-PM_ERR_BASE-3)
    PM_ERR_TEXT = (-PM_ERR_BASE-4)
    PM_ERR_APPVERSION = (-PM_ERR_BASE-5)
    PM_ERR_VALUE = (-PM_ERR_BASE-6)
    PM_ERR_TIMEOUT = (-PM_ERR_BASE-8)
    PM_ERR_NODATA = (-PM_ERR_BASE-9)
    PM_ERR_RESET = (-PM_ERR_BASE-10)
    PM_ERR_NAME	= (-PM_ERR_BASE-12)
    PM_ERR_PMID	= (-PM_ERR_BASE-13)
    PM_ERR_INDOM = (-PM_ERR_BASE-14)
    PM_ERR_INST	= (-PM_ERR_BASE-15)
    PM_ERR_UNIT = (-PM_ERR_BASE-16)
    PM_ERR_CONV = (-PM_ERR_BASE-17)
    PM_ERR_TRUNC = (-PM_ERR_BASE-18)
    PM_ERR_SIGN = (-PM_ERR_BASE-19)
    PM_ERR_PROFILE = (-PM_ERR_BASE-20)
    PM_ERR_IPC = (-PM_ERR_BASE-21)
    PM_ERR_EOF = (-PM_ERR_BASE-23)
    PM_ERR_NOTHOST = (-PM_ERR_BASE-24)
    PM_ERR_EOL = (-PM_ERR_BASE-25)
    PM_ERR_MODE = (-PM_ERR_BASE-26)
    PM_ERR_LABEL = (-PM_ERR_BASE-27)
    PM_ERR_LOGREC = (-PM_ERR_BASE-28)
    PM_ERR_NOTARCHIVE	= (-PM_ERR_BASE-29)
    PM_ERR_LOGFILE = (-PM_ERR_BASE-30)
    PM_ERR_NOCONTEXT = (-PM_ERR_BASE-31)
    PM_ERR_PROFILESPEC = (-PM_ERR_BASE-32)
    PM_ERR_PMID_LOG = (-PM_ERR_BASE-33)
    PM_ERR_INDOM_LOG = (-PM_ERR_BASE-34)
    PM_ERR_INST_LOG = (-PM_ERR_BASE-35)
    PM_ERR_NOPROFILE = (-PM_ERR_BASE-36)
    PM_ERR_NOAGENT = (-PM_ERR_BASE-41)
    PM_ERR_PERMISSION = (-PM_ERR_BASE-42)
    PM_ERR_CONNLIMIT = (-PM_ERR_BASE-43)
    PM_ERR_AGAIN = (-PM_ERR_BASE-44)
    PM_ERR_ISCONN = (-PM_ERR_BASE-45)
    PM_ERR_NOTCONN = (-PM_ERR_BASE-46)
    PM_ERR_NEEDPORT = (-PM_ERR_BASE-47)
    PM_ERR_NONLEAF = (-PM_ERR_BASE-49)
    PM_ERR_TYPE	= (-PM_ERR_BASE-52)
    PM_ERR_THREAD = (-PM_ERR_BASE-53)
    PM_ERR_NOCONTAINER = (-PM_ERR_BASE-54)
    PM_ERR_BADSTORE = (-PM_ERR_BASE-55)
    PM_ERR_TOOSMALL = (-PM_ERR_BASE-98)
    PM_ERR_TOOBIG = (-PM_ERR_BASE-99)
    PM_ERR_FAULT = (-PM_ERR_BASE-100)
    PM_ERR_PMDAREADY = (-PM_ERR_BASE-1048)
    PM_ERR_PMDANOTREADY = (-PM_ERR_BASE-1049)
    PM_ERR_NYI = (-PM_ERR_BASE-8999)


    def_delegator self, :pmExtractValue

    def initialize(host)
      @context = FFIInternal.pmNewContext PM_CONTEXT_HOST, host
      raise PCPEasy::Error.from_pmapi_error_number(@context) if @context < 0
      ObjectSpace.define_finalizer(self, self.class.finalize(@context) )
    end

    def self.pmErrStr(number)
      buffer = FFI::MemoryPointer.new(:char, PM_MAXERRMSGLEN)
      FFIInternal.pmErrStr_r number, buffer, PM_MAXERRMSGLEN
    end

    def pmLookupName(names)
      pmUseContext

      names_ptr = FFI::MemoryPointer.new(:pointer, names.size)
      names_ptr.write_array_of_pointer names.collect {|n| FFI::MemoryPointer.from_string n}
      pmid_ptr = FFI::MemoryPointer.new(:uint, names.size)

      error_code = FFIInternal.pmLookupName names.size, names_ptr, pmid_ptr
      raise PCPEasy::Error.from_pmapi_error_number(error_code) if error_code < 0

      pmid_ptr.get_array_of_uint 0, names.size
    end

    def pmLookupDesc(pmid)
      pmUseContext

      pm_desc = PCPEasy::PMAPI::PmDesc.new
      error_code = FFIInternal.pmLookupDesc(pmid, pm_desc.to_ptr)
      raise PCPEasy::Error.from_pmapi_error_number(error_code) if error_code < 0

      pm_desc
    end

    def pmFetch(pmids)
      pmUseContext

      pmids_ptr = FFI::MemoryPointer.new(:uint, pmids.size)
      pmids_ptr.write_array_of_uint pmids
      pm_result_ptr = FFI::MemoryPointer.new :pointer

      error_code = FFIInternal.pmFetch(pmids.size, pmids_ptr, pm_result_ptr)
      raise PCPEasy::Error.from_pmapi_error_number(error_code) if error_code < 0

      pm_result_ptr = FFI::AutoPointer.new(pm_result_ptr.get_pointer(0), FFIInternal.method(:pmFreeResult))

      PCPEasy::PMAPI::PmResult.new(pm_result_ptr)
    end

    def pmGetInDom(indom)
      pmUseContext

      internal_ids = FFI::MemoryPointer.new :pointer
      external_names = FFI::MemoryPointer.new :pointer

      error_or_num_results = FFIInternal.pmGetInDom indom, internal_ids, external_names
      raise PCPEasy::Error.from_pmapi_error_number(error_or_num_results) if error_or_num_results < 0

      ids = internal_ids.get_pointer(0).get_array_of_int(0, error_or_num_results)
      names = external_names.get_pointer(0).get_array_of_string(0, error_or_num_results)
      Hash[ids.zip(names)]
    end

    def self.pmExtractValue(value_format, pm_desc, pm_value)

      atom = PCPEasy::PMAPI::PmAtomValue.new
      error_code = FFIInternal.pmExtractValue(value_format, pm_value.pointer, pm_desc.type, atom.pointer, pm_desc.type)
      raise PCPEasy::Error.from_pmapi_error_number(error_code) if error_code < 0

      case pm_desc.type
        when PM_TYPE_32
          atom.l
        when PM_TYPE_U32
          atom.ul
        when PM_TYPE_64
          atom.ll
        when PM_TYPE_U64
          atom.ull
        when PM_TYPE_FLOAT
          atom.f
        when PM_TYPE_DOUBLE
          atom.d
        when PM_TYPE_STRING
          str = atom.cp.read_string
          LibC.free(atom.cp) if atom.cp
          str
        when PM_TYPE_AGGREGATE || PM_TYPE_EVENT || PM_TYPE_HIGHRES_EVENT
          # No support, make sure we free the pointer
          LibC.free(atom.vbp) if atom.vbp
          raise PCPEasy::Error.new "Metric type #{pm_desc.type} not supported"
        else
          raise ArgumentError.new "Type #{pm_desc.type} not valid"
      end
    end

    private

    def pmUseContext
      FFIInternal.pmUseContext @context
    end

    def self.finalize(context)
      proc { FFIInternal.pmDestroyContext(context) }
    end

  end

end
