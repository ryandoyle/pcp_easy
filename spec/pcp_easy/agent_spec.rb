require 'spec_helper'

describe PCPEasy::Agent do

  let(:agent) { described_class.new('localhost') }

  describe '#host' do
    it 'returns the host that the agent is connected to' do
      expect(agent.host).to eq 'localhost'
    end
  end

  describe '#metric' do
    describe 'a single instance' do
      let(:metric) { agent.metric('sample.long.ten') }

      it 'should return the correct value' do
        expect(metric.value).to eq 10
      end
      it 'should have a nil instance' do
        expect(metric.instance).to eq nil
      end
      it 'should have the correct semantics' do
        expect(metric.semantics).to eq :instant
      end
    end

    describe 'multiple instances' do
      let(:metrics) { agent.metric('sample.many.int') }

      it 'should contain the first metric' do
        expected = PCPEasy::Metric.new('sample.many.int', 0, 'i-0', :instant, :int32, {:dimension=>:count, :count_scaling=>0})
        expect(metrics).to include(expected)
      end
    end
  end

end