require 'spec_helper'

describe PCPEasy::PMAPI::PmValue do
  describe '#inst' do
    it 'returns the instance of the PmValue' do
      pm_value = described_class.new
      pm_value[:inst] = 123

      expect(pm_value.inst).to eq 123
    end
  end
  describe '#value' do
    it 'returns the value union' do
      pm_value = described_class.new
      pm_value[:value] = PCPEasy::PMAPI::PmValueU.new

      expect(pm_value.value).to be_instance_of PCPEasy::PMAPI::PmValueU
    end
  end
end