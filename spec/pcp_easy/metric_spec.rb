require 'spec_helper'

describe PCPEasy::Metric do

  let(:metric) { PCPEasy::Metric.new('my.metric', 123, 'inst1', :instant, :int32) }

  describe '#name' do
    it 'should return the name' do
      expect(metric.name).to eq 'my.metric'
    end
  end

  describe '#value' do
    it 'should return the value' do
      expect(metric.value).to eq 123
    end
  end

  describe '#instance' do
    it 'should return the instance' do
      expect(metric.instance).to eq 'inst1'
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

  describe '#==' do
    it 'should be false for different metric names' do
      other = PCPEasy::Metric.new('not.my.metric', 123, nil, :instant, :int32)
      expect(metric).to_not eq other
    end

    it 'should be false for different values' do
      other = PCPEasy::Metric.new('my.metric', 456, nil, :instant, :int32)
      expect(metric).to_not eq other
    end
    it 'should be false for different classes' do
      other = "not a metric"
      expect(metric).to_not eq other
    end
    it 'should be false for different instances' do
      other = PCPEasy::Metric.new('my.metric', 123, 'inst2', :instant, :int32)
      expect(metric).to_not eq other
    end
    it 'should be false for different semantics' do
      other = PCPEasy::Metric.new('my.metric', 123, 'inst1', :counter, :int32)
      expect(metric).to_not eq other
    end
    it 'should be false for different metric type' do
      other = PCPEasy::Metric.new('my.metric', 123, 'inst1', :instant, :uint32)
      expect(metric).to_not eq other
    end
    it 'should be true if the metrics are the same' do
      other = PCPEasy::Metric.new('my.metric', 123, 'inst1', :instant, :int32)
      expect(metric).to eq other
    end
  end

end