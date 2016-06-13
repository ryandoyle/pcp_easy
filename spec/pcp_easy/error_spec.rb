require 'spec_helper'

describe PCPEasy::Error do

  describe '#raise_for_pm_error_number' do
    it 'raises the correct exception for the error number' do
      expect(described_class.from_pmapi_error_number(PCPEasy::PMAPI::PM_ERR_NAME)).to be_a_kind_of PCPEasy::Error::NameError
    end
    it 'raises a generic error if the pm error number is unknown' do
      expect(described_class.from_pmapi_error_number(123)).to be_a_kind_of PCPEasy::Error
    end
  end

end