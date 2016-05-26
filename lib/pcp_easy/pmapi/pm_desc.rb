require 'ffi'
require 'pcp_easy/pmapi/pm_units'

module PCPEasy
  class PMAPI
    class PmDesc < FFI::Struct
      layout :pmid, :uint,
             :type, :int,
             :indom, :uint,
             :sem, :int,
             :units, :uint32

      def inspect
        "<#{self.class.to_s}:#{object_id} pmid=#{pmid} type=#{type} indom=#{indom} sem=#{sem} units=#{units.inspect}>"
      end

      def pmid
        self[:pmid]
      end

      def type
        self[:type]
      end

      def indom
        self[:indom]
      end

      def sem
        self[:sem]
      end

      def units
        @units ||= PmUnits.new(self[:units])
      end

      def ==(other)
        self.class == other.class && \
        pmid == other.pmid && \
        type == other.type && \
        indom == other.indom && \
        sem == other.sem && \
        units == other.units

      end

    end
  end
end