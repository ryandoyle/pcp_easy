require 'spec_helper'

describe PCPEasy::Metric::Value do

    let(:value) { described_class.new(123, 'myinst') }

    describe '#instance' do
      it 'should return the instance' do
        expect(value.instance).to eq 'myinst'
      end
    end

    describe '#value' do
      it 'should return the value' do
        expect(value.value).to eq 123
      end
    end

    describe '==' do
      it 'should be true for metric values that are the same' do
        other = described_class.new(123, 'myinst')
        expect(value).to eq other
      end
      it 'should be false for metric values that are different types' do
        expect(value).to_not eq 'a string'
      end
      it 'should be false for metric values with different values' do
        other = described_class.new(456, 'myinst')
        expect(value).to_not eq other
      end
      it 'should be false for metric values with different instances' do
        other = described_class.new(123, 'other inst')
        expect(value).to_not eq other
      end
    end

end