require 'ffi'
require 'pcp_easy/error'
require 'pcp_easy/pmapi/pm_desc'

module PCPEasy
  module FFIInternal
    extend FFI::Library
    ffi_lib 'libpcp.so.3'

    typedef :uint, :pmid

    attach_function :pmNewContext, [:int, :string], :int
    attach_function :pmErrStr_r, [:int, :pointer, :int], :string
    attach_function :pmUseContext, [:int], :void
    attach_function :pmLookupName, [:int, :pointer, :pointer], :int
    attach_function :pmLookupDesc, [:pmid, :pointer], :int
  end

  class PMAPI

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

    PM_INDOM_NULL	= 0xffffffff

    PM_SEM_COUNTER  = 1
    PM_SEM_INSTANT  = 3
    PM_SEM_DISCRETE = 4

    def initialize(host)
      @context = FFIInternal.pmNewContext PM_CONTEXT_HOST, host
      raise PCPEasy::Error.new(@context) if @context < 0
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
      raise PCPEasy::Error.new(error_code) if error_code < 0

      pmid_ptr.get_array_of_uint 0, names.size
    end

    def pmLookupDesc(pmid)
      pmUseContext

      pm_desc = PCPEasy::PMAPI::PmDesc.new
      error_code = FFIInternal.pmLookupDesc(pmid, pm_desc.to_ptr)
      raise PCPEasy::Error.new(error_code) if error_code < 0

      pm_desc
    end

    private

    def pmUseContext
      FFIInternal.pmUseContext @context
    end


  end



end
