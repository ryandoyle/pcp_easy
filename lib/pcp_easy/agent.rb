require 'pcp_easy/pmapi'

module PCPEasy
  class Agent

    attr_reader :host

    def initialize(host)
      @host = host
    end

    def metric(name)
      metrics([name]).first
    end

    def metrics(names)
      raise ArgumentError, "array required for metrics" unless names.is_a? Array
      pmids = pmapi.pmLookupName(names)
      pmids_names = Hash[pmids.zip(names)]
      pmapi.pmFetch(pmids).vset.collect {|v| metric_from_vset(v, pmids_names)}
    end

    private

    def metric_from_vset(pm_value_set, pmid_names)
      pm_desc = pmapi.pmLookupDesc pm_value_set.pmid
      name = pmid_names[pm_value_set.pmid]

      if pm_desc.indom == PCPEasy::PMAPI::PM_INDOM_NULL
        metric_values = metric_value_for_no_indom(pm_value_set, pm_desc)
      else
        metric_values = metric_value_for_indoms(pm_value_set, pm_desc)
      end
      PCPEasy::Metric.new(name, pm_desc, metric_values)
    end

    def metric_value_for_no_indom(pm_value_set, pm_desc)
      value = pmapi.pmExtractValue(pm_value_set.valfmt, pm_desc, pm_value_set.vlist.first)
      [PCPEasy::Metric::Value.new(value, nil)]
    end

    def metric_value_for_indoms(pm_value_set, pm_desc)
      indoms = pmapi.pmGetInDom(pm_desc.indom)
      pm_value_set.vlist.collect do |v|
        value = pmapi.pmExtractValue(pm_value_set.valfmt, pm_desc, v)
        PCPEasy::Metric::Value.new(value, indoms[v.inst])
      end
    end



    def pmapi
      @pmapi ||= PCPEasy::PMAPI.new(@host)
    end

  end
end

