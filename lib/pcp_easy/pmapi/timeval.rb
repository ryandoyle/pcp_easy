require 'ffi'

module PCPEasy
  class PMAPI
    class Timeval < FFI::Struct
      layout :tv_sec, :long,
             :tv_usec, :long

      def ==(other)
        self.class == other.class && \
        self[:tv_sec] == other[:tv_sec] && \
        self[:tv_usec] == other[:tv_usec]
      end
    end
  end
end
