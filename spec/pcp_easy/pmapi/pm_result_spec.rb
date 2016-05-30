require 'spec_helper'

describe PCPEasy::PMAPI::PmResult do

  describe '#vset' do
    it 'returns the value set' do
      ptr = FFI::MemoryPointer.new(described_class.size + PCPEasy::PMAPI::PmValueSet.size * 2)
      pm_result = described_class.new(ptr)
      pm_result[:numpmid] = 3

      expect(pm_result.vset).to match_array [
                                                instance_of(PCPEasy::PMAPI::PmValueSet),
                                                instance_of(PCPEasy::PMAPI::PmValueSet),
                                                instance_of(PCPEasy::PMAPI::PmValueSet),
                                            ]
    end
  end

  describe '#numpmid' do
    it 'returns the number of pmids' do
      pm_result = described_class.new
      pm_result[:numpmid] = 3

      expect(pm_result.numpmid).to eq 3
    end
  end

  describe '#timestamp' do
    it 'returns the timestamp of the request' do
      pm_result = described_class.new
      timestamp = PCPEasy::PMAPI::Timeval.new
      timestamp[:tv_sec] = 123
      timestamp[:tv_usec] = 456
      pm_result[:timestamp] = timestamp

      expect(pm_result.timestamp).to eq timestamp
    end
  end

end