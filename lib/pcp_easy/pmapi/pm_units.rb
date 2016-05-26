module PCPEasy
  class PMAPI
    class PmUnits

      # Decodes a 32bit integer into the correct fields of pmUnits.
      # This implementation assumes little-endian encoding

      def initialize(pm_units)
        @pm_units = pm_units
      end

      def dim_space
        signed_4_bit(@pm_units >> 28)
      end

      def dim_time
        signed_4_bit(@pm_units >> 24)
      end

      def dim_count
        signed_4_bit(@pm_units >> 20)
      end

      def scale_space
        unsigned_4_bit(@pm_units >> 16)
      end

      def scale_time
        unsigned_4_bit(@pm_units >> 12)
      end

      def scale_count
        signed_4_bit(@pm_units >> 8)
      end

      def inspect
        "<#{self.class.to_s}:#{object_id} @pm_units=#{@pm_units} {#{dim_space},#{dim_time},#{dim_count},#{scale_space},#{scale_time},#{scale_count}}>"
      end

      def ==(other)
        self.class == other.class && \
        dim_space == other.dim_space && \
        dim_time == other.dim_time && \
        dim_count == other.dim_count && \
        scale_space == other.scale_space && \
        scale_time == other.scale_time && \
        scale_count == other.scale_count
      end

      private

      def signed_4_bit(lowest_4_bits)
        lowest_4_bits & 0x8 == 0 ? lowest_4_bits & 0xf : -((~lowest_4_bits & 0xf) + 1)
      end

      def unsigned_4_bit(lowest_4_bits)
        lowest_4_bits & 0xf
      end

    end
  end
end
