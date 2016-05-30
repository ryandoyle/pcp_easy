require 'spec_helper'

describe PCPEasy::PMAPI::PmValueSet do

  describe '#vlist' do
    it 'returns a list of PmValue(s)' do
      raw_pointer = FFI::MemoryPointer.new(PCPEasy::PMAPI::PmValueSet.size + 2 * PCPEasy::PMAPI::PmValue.size)
      pm_value_set = described_class.new(raw_pointer)
      pm_value_set[:numval] = 3

      expect(pm_value_set.vlist).to match_array [
                                                    instance_of(PCPEasy::PMAPI::PmValue),
                                                    instance_of(PCPEasy::PMAPI::PmValue),
                                                    instance_of(PCPEasy::PMAPI::PmValue),
                                                ]
    end
  end

  describe '#numval' do
    it 'returns the number of values in the vset' do
      pm_value_set = described_class.new
      pm_value_set[:numval] = 123

      expect(pm_value_set.numval).to eq 123
    end
  end

  describe '#pmid' do
    it 'returns the pmid for the value set' do
      pm_value_set = described_class.new
      pm_value_set[:pmid] = 321

      expect(pm_value_set.pmid).to eq 321
    end
  end

  describe '#valfmt' do
    it 'returns the value format for the value set' do
      pm_value_set = described_class.new
      pm_value_set[:valfmt] = 1

      expect(pm_value_set.valfmt).to eq 1
    end
  end

end