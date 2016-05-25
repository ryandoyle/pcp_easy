require 'spec_helper'

describe PCPEasy::PMAPI, :group => :integration do

  describe '#pmLookupName' do
    it 'returns the pmids for names' do
      expect(described_class.new('localhost').pmLookupName(['disk.all.read', 'disk.all.write'])).to eq [251658264, 251658265]
    end
  end

end