require 'spec_helper'

describe PCPEasy::PMAPI::PmDesc  do

  let(:pm_desc) { described_class.new }

  describe 'pmid' do
    it 'sets without error' do
      expect{pm_desc[:pmid] = 123}.to_not raise_error
    end
    it 'has an accessor' do
      pm_desc[:pmid] = 123
      expect(pm_desc.pmid).to eq 123
    end
  end

  describe 'type' do
    it 'sets without error' do
      expect{pm_desc[:type] = 1}.to_not raise_error
    end
    it 'has an accessor' do
      pm_desc[:type] = 1
      expect(pm_desc.type).to eq 1
    end
  end

  describe 'indom' do
    it 'sets without error' do
      expect{pm_desc[:indom] = 1}.to_not raise_error
    end
    it 'has an accessor' do
      pm_desc[:indom] = 1
      expect(pm_desc.indom).to eq 1
    end
  end

  describe 'sem' do
    it 'sets without error' do
      expect{pm_desc[:sem] = 1}.to_not raise_error
    end
    it 'has an accessor' do
      pm_desc[:sem] = 1
      expect(pm_desc.sem).to eq 1
    end
  end

  describe 'units' do
    it 'sets without error' do
      expect{pm_desc[:units] = 1}.to_not raise_error
    end
    it 'has an accessor' do
      pm_units = double('PmUnits')
      allow(PCPEasy::PMAPI::PmUnits).to receive(:new).with(1).and_return pm_units
      pm_desc[:units] = 1

      expect(pm_desc.units).to eq pm_units
    end
  end

  describe '==' do
    it 'is true if all fields are equal' do
      pm_desc1 = described_class.new
      pm_desc1[:pmid] = 123
      pm_desc1[:type] = 1
      pm_desc1[:indom] = 1
      pm_desc1[:sem] = 1
      pm_desc1[:units] = 1

      pm_desc2 = described_class.new
      pm_desc2[:pmid] = 123
      pm_desc2[:type] = 1
      pm_desc2[:indom] = 1
      pm_desc2[:sem] = 1
      pm_desc2[:units] = 1

      expect(pm_desc1).to eq pm_desc2
    end

  end

end