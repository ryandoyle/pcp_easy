$:.unshift File.expand_path(File.dirname(__FILE__) + '../lib')
require 'pcp_easy'

RSpec.configure do |config|
  config.filter_run_excluding :disabled => true
end

RSpec::Matchers.define :have_the_value do |expected|
  match do |actual|
    @failure_message = ""

     unless actual
       @failure_message << "metric does not exist "
       return false
     end

     if @instance
       metric = actual.find{|metric| metric.instance == @instance}
       unless metric
         @failure_message << "no instance '#{@instance}' found in "
         return false
       end
     else
       metric = actual
     end

     if metric.value != expected
       @failure_message << "actual value '#{metric.value}' does not match expected value '#{expected}' "
       if @instance
         @failure_message << "for instance '#{@instance}' "
       end
       return false
     end

     return true
  end

  chain :for_instance do |instance|
    @instance = instance
  end

  failure_message do |actual|
    "#{@failure_message}in #{actual}"
  end

end