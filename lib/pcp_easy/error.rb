require 'pcp_easy/pmapi'

module PCPEasy
  class Error < StandardError
    def initialize(number)
      super(PMAPI.pmErrStr(number))
    end
  end
end