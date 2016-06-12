require 'pcp_easy/pmapi'

module PCPEasy
  class Metric

    def initialize(name, pm_desc, metric_values)
      @name = name
      @pm_desc = pm_desc
      @metric_values = metric_values
    end

    def name
      @name
    end

    def values
      @metric_values
    end

    def ==(other)
      self.class == other.class && \
      name == other.name && \
      values == other.values && \
      semantics == other.semantics && \
      type == other.type && \
      units == other.units
    end

    def semantics
      case @pm_desc.sem
        when PCPEasy::PMAPI::PM_SEM_COUNTER
          :counter
        when PCPEasy::PMAPI::PM_SEM_INSTANT
          :instant
        when PCPEasy::PMAPI::PM_SEM_DISCRETE
          :discrete
        else
          :unknown
      end
    end


    def type
      case @pm_desc.type
        when PCPEasy::PMAPI::PM_TYPE_NOSUPPORT
          :no_support
        when PCPEasy::PMAPI::PM_TYPE_32
          :int32
        when PCPEasy::PMAPI::PM_TYPE_U32
          :uint32
        when PCPEasy::PMAPI::PM_TYPE_64
          :int64
        when PCPEasy::PMAPI::PM_TYPE_U64
          :uint64
        when PCPEasy::PMAPI::PM_TYPE_FLOAT
          :float
        when PCPEasy::PMAPI::PM_TYPE_DOUBLE
          :double
        when PCPEasy::PMAPI::PM_TYPE_STRING
          :string
        when PCPEasy::PMAPI::PM_TYPE_AGGREGATE
          :aggregate
        when PCPEasy::PMAPI::PM_TYPE_AGGREGATE_STATIC
          :aggregate_static
        when PCPEasy::PMAPI::PM_TYPE_EVENT
          :event
        when PCPEasy::PMAPI::PM_TYPE_HIGHRES_EVENT
          :highres_event
        else
          :unknown
      end
    end

    def units
      pm_units = @pm_desc.units

      if pm_units.dim_space == 1 && pm_units.dim_time == 0 && pm_units.dim_count == 0
        {:domain => space_unit(pm_units.scale_space), :range => nil}
      elsif pm_units.dim_space == 1 && pm_units.dim_time == -1 && pm_units.dim_count == 0
        {:domain => space_unit(pm_units.scale_space), :range => time_unit(pm_units.scale_time)}
      elsif pm_units.dim_space == 1 && pm_units.dim_time == 0 && pm_units.dim_count == -1
        {:domain => space_unit(pm_units.scale_space), :range => count_unit(pm_units.scale_count)}

      elsif pm_units.dim_space == 0 && pm_units.dim_time == 1 && pm_units.dim_count == 0
        {:domain => time_unit(pm_units.scale_time), :range => nil}
      elsif pm_units.dim_space == -1 && pm_units.dim_time == 1 && pm_units.dim_count == 0
        {:domain => time_unit(pm_units.scale_time), :range => space_unit(pm_units.scale_space)}
      elsif pm_units.dim_space == 0 && pm_units.dim_time == 1 && pm_units.dim_count == -1
        {:domain => time_unit(pm_units.scale_time), :range => count_unit(pm_units.scale_count)}

      elsif pm_units.dim_space == 0 && pm_units.dim_time == 0 && pm_units.dim_count == 1
        {:domain => count_unit(pm_units.scale_count), :range => nil}
      elsif pm_units.dim_space == -1 && pm_units.dim_time == 0 && pm_units.dim_count == 1
        {:domain => count_unit(pm_units.scale_count), :range => space_unit(pm_units.scale_space)}
      elsif pm_units.dim_space == 0 && pm_units.dim_time == -1 && pm_units.dim_count == 1
        {:domain => count_unit(pm_units.scale_count), :range => time_unit(pm_units.scale_time)}
      else
        {:domain => nil, :range => nil}
      end
    end

    def inspect
      "<#{self.class.to_s} name=#{name} values=#{values} semantics=#{semantics} type=#{type} units=#{units}>"
    end

    private

    def count_unit(exponent)
      "count#{exponent}".to_sym
    end

    def space_unit(unit)
      case unit
        when PCPEasy::PMAPI::PM_SPACE_BYTE
          :bytes
        when PCPEasy::PMAPI::PM_SPACE_KBYTE
          :kilobytes
        when PCPEasy::PMAPI::PM_SPACE_MBYTE
          :megabytes
        when PCPEasy::PMAPI::PM_SPACE_GBYTE
          :gigabytes
        when PCPEasy::PMAPI::PM_SPACE_TBYTE
          :terabytes
        when PCPEasy::PMAPI::PM_SPACE_PBYTE
          :petabytes
        when PCPEasy::PMAPI::PM_SPACE_EBYTE
          :exabytes
        else
          nil
      end
    end

    def time_unit(unit)
      case unit
        when PCPEasy::PMAPI::PM_TIME_NSEC
          :nanoseconds
        when PCPEasy::PMAPI::PM_TIME_USEC
          :microseconds
        when PCPEasy::PMAPI::PM_TIME_MSEC
          :milliseconds
        when PCPEasy::PMAPI::PM_TIME_SEC
          :seconds
        when PCPEasy::PMAPI::PM_TIME_MIN
          :minutes
        when PCPEasy::PMAPI::PM_TIME_HOUR
          :hours
        else
          nil
      end
    end

  end
end