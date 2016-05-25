require 'spec_helper'

describe PCPEasy::Metric, :disabled => true do

  let(:units) { {:dimension=>:count, :count_scaling=>0} }
  let(:metric_values) { [double('PCPEasy::Metric::Value')] }
  let(:metric) { PCPEasy::Metric.new('my.metric', metric_values, :instant, :int32, units) }

  describe '#name' do
    it 'should return the name' do
      expect(metric.name).to eq 'my.metric'
    end
  end

  describe '#values' do
    it 'should return the values' do
      expect(metric.values).to eq metric_values
    end
  end

  describe '#semantics' do
    it 'should return the semantics' do
      expect(metric.semantics).to eq :instant
    end
  end

  describe '#type' do
    it 'should return the type' do
      expect(metric.type).to eq :int32
    end
  end

  describe '#units' do
    it 'should return the units' do
      expect(metric.units).to eq :dimension=>:count, :count_scaling=>0
    end
  end

  describe '#==' do
    it 'should be false for different metric names' do
      other = PCPEasy::Metric.new('not.my.metric', metric_values, :instant, :int32, units)
      expect(metric).to_not eq other
    end
    it 'should be false for different values' do
      other = PCPEasy::Metric.new('my.metric', double('Another value'), :instant, :int32, units)
      expect(metric).to_not eq other
    end
    it 'should be false for different classes' do
      other = "not a metric"
      expect(metric).to_not eq other
    end
    it 'should be false for different semantics' do
      other = PCPEasy::Metric.new('my.metric', metric_values, :counter, :int32, units)
      expect(metric).to_not eq other
    end
    it 'should be false for different metric type' do
      other = PCPEasy::Metric.new('my.metric', metric_values, :instant, :uint32, units)
      expect(metric).to_not eq other
    end
    it 'should be false for different units' do
      other = PCPEasy::Metric.new('my.metric', metric_values, :instant, :int32, :dimension=>:count, :count_scaling=>1)
      expect(metric).to_not eq other
    end
    it 'should be true if the metrics are the same' do
      other = PCPEasy::Metric.new('my.metric', metric_values, :instant, :int32, units)
      expect(metric).to eq other
    end
  end

end