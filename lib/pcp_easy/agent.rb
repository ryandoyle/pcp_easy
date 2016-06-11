require 'pcp_easy/pmapi'

module PCPEasy
  class Agent

    attr_reader :host

    def initialize(host)
      @host = host
    end

    def metric(name)
      pmid = pmapi.pmLookupName([name]).first
      pm_desc = pmapi.pmLookupDesc pmid

      pm_result = pmapi.pmFetch([pmid])


      if pm_desc.indom == PCPEasy::PMAPI::PM_INDOM_NULL
        metric_vset = pm_result.vset.first
        value = pmapi.pmExtractValue(metric_vset.valfmt, pm_desc, metric_vset.vlist.first)
        metric_values = [PCPEasy::Metric::Value.new(value, nil)]
      else
        indoms = pmapi.pmGetInDom(pm_desc.indom)
        metric_vset = pm_result.vset.first
        metric_values = metric_vset.vlist.collect do |v|
          value = pmapi.pmExtractValue(metric_vset.valfmt, pm_desc, v)
          PCPEasy::Metric::Value.new(value, indoms[v.inst])
        end
      end
      PCPEasy::Metric.new(name, pm_desc, metric_values)
    end


    private

    def pmapi
      @pmapi ||= PCPEasy::PMAPI.new(@host)
    end

  end
end

