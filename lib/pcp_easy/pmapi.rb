require 'ffi'
require 'pcp_easy/error'

module PCPEasy
  module FFIInternal
    extend FFI::Library
    ffi_lib 'libpcp.so.3'

    typedef :uint, :pmid

    attach_function :pmNewContext, [:int, :string], :int
    attach_function :pmErrStr_r, [:int, :pointer, :int], :string
    attach_function :pmUseContext, [:int], :void
    attach_function :pmLookupName, [:int, :pointer, :pointer], :int
  end

  class PMAPI

    PM_CONTEXT_HOST = 1

    PM_MAXERRMSGLEN = 128

    def initialize(host)
      @context = FFIInternal.pmNewContext PM_CONTEXT_HOST, host
      raise PCPEasy::Error.new(@context) if @context < 0
    end

    def self.pmErrStr(number)
      ptr = FFI::MemoryPointer.new(:char, PM_MAXERRMSGLEN)
      FFIInternal.pmErrStr_r number, ptr, PM_MAXERRMSGLEN
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

    private

    def pmUseContext
      FFIInternal.pmUseContext @context
    end


  end



end
