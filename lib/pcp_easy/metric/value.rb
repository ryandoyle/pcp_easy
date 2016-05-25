module PCPEasy; class Metric
  class Value

    attr_reader :value, :instance

    def initialize(value, instance)
      @value = value
      @instance = instance
    end

    def ==(other)
      self.class == other.class && \
      value == other.value && \
      instance == other.instance
    end

  end
end
end
