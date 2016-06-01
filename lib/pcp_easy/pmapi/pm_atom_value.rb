require 'ffi'

module PCPEasy
  class PMAPI
    class PmAtomValue < FFI::Union
      layout :l, :int32,
             :ul, :uint32,
             :ll, :int64,
             :ull, :uint64,
             :f, :float,
             :d, :double,
             :cp, :pointer,
             :vbp, :pointer

      def l
        self[:l]
      end

      def ul
        self[:ul]
      end

      def ll
        self[:ll]
      end

      def ull
        self[:ull]
      end

      def f
        self[:f]
      end

      def d
        self[:d]
      end

      def cp
        self[:cp]
      end

      def vbp
        self[:vbp]
      end

    end
  end
end
