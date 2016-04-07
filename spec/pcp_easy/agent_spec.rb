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
        expect(metric.values.first.value).to eq 10
      end
      it 'should have a nil instance' do
        expect(metric.values.first.instance).to eq nil
      end
      it 'should have the correct semantics' do
        expect(metric.semantics).to eq :instant
      end
    end

    describe 'multiple instances' do
      let(:metrics) { agent.metric('sample.many.int') }

      it 'should contain the first metric' do
        expected_value = PCPEasy::Metric::Value.new(0, 'i-0')
        expect(metrics.values).to include(expected_value)
      end
    end
  end

end