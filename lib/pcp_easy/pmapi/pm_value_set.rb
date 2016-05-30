require 'ffi'
require 'pcp_easy/pmapi/pm_value'

module PCPEasy
  class PMAPI
    class PmValueSet < FFI::Struct

      layout :pmid, :uint,
             :numval, :int,
             :valfmt, :int,
             :vlist, PmValue
             # Can have one or more PmValue

      def vlist
        @vlist ||= numval.times.collect {|n| PmValue.new(start_of_vlist + PmValue.size * n)}
      end

      def numval
        self[:numval]
      end

      def pmid
        self[:pmid]
      end

      def valfmt
        self[:valfmt]
      end

      private

      def start_of_vlist
        pointer + (self.size - PmValue.size)
      end

    end
  end
end
