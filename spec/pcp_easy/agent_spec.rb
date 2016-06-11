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
      it 'should have the correct type' do
        expect(metric.type).to eq :int32
      end
      it 'should have the correct units' do
        expect(metric.units).to eq :domain => nil, :range => nil
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
  #
  # describe '#metrics' do
  #   it 'should raise an error if not passed an array' do
  #     expect{agent.metrics('somestring')}.to raise_error ArgumentError
  #   end
  #   it 'should raise an error if the array does not contain strings' do
  #     expect{agent.metrics([1,2])}.to raise_error ArgumentError
  #   end
  #   it 'should return multiple metrics if multiple metrics are queried for' do
  #     expect(agent.metrics(['sample.long.ten', 'sample.many.int']).length).to eq 2
  #   end
  # end

end