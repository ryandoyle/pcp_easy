require 'spec_helper'

describe PCPEasy::PMAPI, :group => :integration do

  let(:pmapi) { described_class.new('localhost') }
  let(:sample_many_int) { 121634896 }
  let(:sample_many_int_indom) { 121634824 }
  let(:sample_ulonglong_million) { 121634917 }
  let(:sample_longlong_million) { 121634839 }
  let(:sample_long_million) { 121634829 }
  let(:sample_ulong_million) { 121634912 }
  let(:sample_float_million) { 121634834 }
  let(:sample_double_million) { 121634844 }
  let(:sample_string_hullo) { 121634847 }
  let(:sample_aggregate_hullo) { 121634850 }

  describe '#pmLookupName' do
    it 'returns the pmids for names' do
      expect(pmapi.pmLookupName(['disk.all.read', 'disk.all.write'])).to eq [251658264, 251658265]
    end
  end

  describe '#pmLookupDesc' do
    it 'returns the PmDesc of a pmid' do
      pm_desc = PCPEasy::PMAPI::PmDesc.new
      pm_desc[:pmid] = 251658264
      pm_desc[:type] = PCPEasy::PMAPI::PM_TYPE_U64
      pm_desc[:indom] = PCPEasy::PMAPI::PM_INDOM_NULL
      pm_desc[:sem] = PCPEasy::PMAPI::PM_SEM_COUNTER
      pm_desc[:units] = 1048576

      expect(pmapi.pmLookupDesc(251658264)).to eq pm_desc
    end
  end

  describe '#pmFetch' do
    it 'returns a PmResult with the correct number of pmids' do
      result = pmapi.pmFetch([sample_many_int])
      expect(result.numpmid).to eq 1
    end
    it 'returns a PmValueSet with the correct number of values' do
      result = pmapi.pmFetch([sample_many_int])
      expect(result.vset[0].numval).to eq 5
    end
    it 'returns a PmResult with the correct instance ID' do
      result = pmapi.pmFetch([sample_many_int])
      expect(result.vset[0].vlist[1].inst).to eq 1
    end
    it 'returns a PmResult with the correct value' do
      result = pmapi.pmFetch([sample_many_int])
      expect(result.vset[0].vlist[1].value.lval).to eq 1
    end
  end

  describe '#pmGetInDom' do
    it 'returns the instance IDs and text strings' do
      expect(pmapi.pmGetInDom(sample_many_int_indom)).to eq 0 => 'i-0', 1 => 'i-1', 2 => 'i-2', 3 => 'i-3', 4 => 'i-4'
    end
    it 'raises an error for invalid indomns' do
      expect{pmapi.pmGetInDom(123)}.to raise_error PCPEasy::Error::InDomError
    end
  end

  describe '#pmExtractValue' do

    def value_for(metric)
      pm_desc = pmapi.pmLookupDesc(metric)
      pm_value_set = pmapi.pmFetch([metric]).vset[0]
      pmapi.pmExtractValue(pm_value_set.valfmt, pm_desc, pm_value_set.vlist[0])
    end

    it 'extracts a long' do
      expect(value_for(sample_long_million)).to eq 1_000_000
    end
    it 'extracts a ulong' do
      expect(value_for(sample_ulong_million)).to eq 1_000_000
    end
    it 'extracts a longlong' do
      expect(value_for(sample_longlong_million)).to eq 1_000_000
    end
    it 'extracts a ulonglong' do
      expect(value_for(sample_ulonglong_million)).to eq 1_000_000
    end
    it 'extracts a float' do
      expect(value_for(sample_float_million)).to eq 1_000_000
    end
    it 'extracts a double' do
      expect(value_for(sample_double_million)).to eq 1_000_000
    end
    it 'extracts a string' do
      expect(value_for(sample_string_hullo)).to eq 'hullo world!'
    end
    it 'raises an error for other types' do
      expect{value_for(sample_aggregate_hullo)}.to raise_error PCPEasy::Error
    end
  end

end

describe PCPEasy::PMAPI do

  let(:pmapi) { described_class.new('not-a-host') }

  before do
    allow(PCPEasy::FFIInternal).to receive(:pmNewContext).and_return 0
    allow(PCPEasy::FFIInternal).to receive(:pmUseContext)
  end

  describe '#new' do
    it 'creates a new context' do
      expect(PCPEasy::FFIInternal).to receive(:pmNewContext).with(PCPEasy::PMAPI::PM_CONTEXT_HOST, 'somehost').and_return 123

      described_class.new('somehost')
    end
    it 'raises an error if there is an error creating the context' do
      allow(PCPEasy::FFIInternal).to receive(:pmNewContext).and_return -1

      expect{described_class.new('somehost')}.to raise_error PCPEasy::Error
    end
  end

  describe '#pmErrStr' do
    it 'returns the string representation of the error' do
      buffer = double('string buffer')
      allow(FFI::MemoryPointer).to receive(:new).with(:char, PCPEasy::PMAPI::PM_MAXERRMSGLEN).and_return buffer
      allow(PCPEasy::FFIInternal).to receive(:pmErrStr_r).with(123, buffer, PCPEasy::PMAPI::PM_MAXERRMSGLEN).and_return 'my error'
      expect(described_class.pmErrStr(123)).to eq 'my error'
    end
  end

  describe '#pmExtractValue' do

    before do
      allow(PCPEasy::FFIInternal).to receive(:pmExtractValue).and_return 0
    end

    it 'frees strings when the metric is a string' do
      pm_desc = double('PmDesc', :type => PCPEasy::PMAPI::PM_TYPE_STRING)
      pm_value = double('PmValue', :pointer => nil)
      pm_atom_value_cp = double('Poiner', :read_string => 'derps')
      pm_atom_value = double('PmAtomValue', :cp => pm_atom_value_cp, :pointer => nil)
      allow(PCPEasy::PMAPI::PmAtomValue).to receive(:new).and_return pm_atom_value

      expect(PCPEasy::LibC).to receive(:free).with(pm_atom_value_cp)

      described_class.pmExtractValue(PCPEasy::PMAPI::PM_VAL_DPTR, pm_desc, pm_value)
    end
    it 'raises an error for unsupported metrics' do
      pm_desc = double('PmDesc', :type => PCPEasy::PMAPI::PM_TYPE_AGGREGATE)
      pm_value = double('PmValue', :pointer => nil)
      pm_atom_value = double('PmAtomValue', :vbp => nil, :pointer => nil)
      allow(PCPEasy::PMAPI::PmAtomValue).to receive(:new).and_return pm_atom_value

      expect{described_class.pmExtractValue(PCPEasy::PMAPI::PM_VAL_DPTR, pm_desc, pm_value)}.to raise_error PCPEasy::Error
    end
    it 'frees any pmValueBlock' do
      pm_desc = double('PmDesc', :type => PCPEasy::PMAPI::PM_TYPE_AGGREGATE)
      pm_value = double('PmValue', :pointer => nil)
      pm_atom_value_vbp = double('Poiner')
      pm_atom_value = double('PmAtomValue', :vbp => pm_atom_value_vbp, :pointer => nil)
      allow(PCPEasy::PMAPI::PmAtomValue).to receive(:new).and_return pm_atom_value

      expect(PCPEasy::LibC).to receive(:free).with(pm_atom_value_vbp)

      begin
      described_class.pmExtractValue(PCPEasy::PMAPI::PM_VAL_DPTR, pm_desc, pm_value)
      rescue PCPEasy::Error
      end

    end
  end

end