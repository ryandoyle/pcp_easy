require 'ffi'

module PCPEasy
  class PMAPI

    class PmValueU < FFI::Union
      layout :pval, :pointer,
             :lval, :int

      def pval
        self[:pval]
      end

      def lval
        self[:lval]
      end
    end

    class PmValue < FFI::Struct
      layout :inst, :int,
             :value, PmValueU
      def inst
        self[:inst]
      end

      def value
        self[:value]
      end

    end


  end
end