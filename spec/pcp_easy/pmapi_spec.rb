require 'spec_helper'

describe PCPEasy::PMAPI, :group => :integration do

  let(:pmapi) { described_class.new('localhost') }

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

end