require 'spec_helper'

describe PCPEasy::PMAPI::PmUnits do

  describe '#dim_space' do
    it 'returns a positive integer for positive space dimensions' do
      expect(described_class.new(0b0001 << 28).dim_space).to eq 1
    end
    it 'returns a negative integer for negative space dimensions' do
      expect(described_class.new(0b1111 << 28).dim_space).to eq -1
    end
    it 'returns a negative integer for other negative space dimensions' do
      expect(described_class.new(0b1110 << 28).dim_space).to eq -2
    end
    it 'is zero if not used' do
      expect(described_class.new(0b0000 << 28).dim_space).to eq 0
    end
  end

  describe '#dim_time' do
    it 'returns a positive integer for positive time dimensions' do
      expect(described_class.new(0b0001 << 24).dim_time).to eq 1
    end
    it 'returns a negative integer for negative time dimensions' do
      expect(described_class.new(0b1111 << 24).dim_time).to eq -1
    end
    it 'returns a negative integer for other negative time dimensions' do
      expect(described_class.new(0b1110 << 24).dim_time).to eq -2
    end
    it 'is zero if not used' do
      expect(described_class.new(0b0000 << 24).dim_time).to eq 0
    end
  end

  describe '#dim_count' do
    it 'returns a positive integer for positive count dimensions' do
      expect(described_class.new(0b0001 << 20).dim_count).to eq 1
    end
    it 'returns a negative integer for negative count dimensions' do
      expect(described_class.new(0b1111 << 20).dim_count).to eq -1
    end
    it 'returns a negative integer for other negative count dimensions' do
      expect(described_class.new(0b1110 << 20).dim_count).to eq -2
    end
    it 'is zero if not used' do
      expect(described_class.new(0b0000 << 20).dim_count).to eq 0
    end
  end

  describe '#scale_space' do
    it 'returns a positive space scale up to 3 bits' do
      expect(described_class.new(0b0111 << 16).scale_space).to eq 7
    end
    it 'returns a positive space scale when 4th significant bit is non-zero' do
      expect(described_class.new(0b1011 << 16).scale_space).to eq 11
    end
  end

  describe '#scale_time' do
    it 'returns a positive time scale up to 3 bits' do
      expect(described_class.new(0b0111 << 12).scale_time).to eq 7
    end
    it 'returns a positive time scale when 4th significant bit is non-zero' do
      expect(described_class.new(0b1011 << 12).scale_time).to eq 11
    end
  end

  describe '#scale_count' do
    it 'returns a positive integer for positive count scales' do
      expect(described_class.new(0b0001 << 8).scale_count).to eq 1
    end
    it 'returns a negative integer for negative count scales' do
      expect(described_class.new(0b1111 << 8).scale_count).to eq -1
    end
    it 'returns a negative integer for other negative count scales' do
      expect(described_class.new(0b1110 << 8).scale_count).to eq -2
    end
    it 'is zero if not used' do
      expect(described_class.new(0b0000 << 8).scale_count).to eq 0
    end
  end

  describe '#==' do
    it 'is true if all the values are the same' do
      pm_units1 = described_class.new(0b10101111_01010111_10010110_10101010)
      pm_units2 = described_class.new(0b10101111_01010111_10010110_10101010)

      expect(pm_units1).to eq pm_units2
    end
    it 'is true regardless of the padding byte if all values are the same' do
      pm_units1 = described_class.new(0b10101111_01010111_10010110_00000000)
      pm_units2 = described_class.new(0b10101111_01010111_10010110_11111111)

      expect(pm_units1).to eq pm_units2
    end
    it 'is false if the values are different' do
      pm_units1 = described_class.new(0b10101111_01010111_10010110_00000000)
      pm_units2 = described_class.new(0b00101111_01010111_10010110_11111111)

      expect(pm_units1).to_not eq pm_units2
    end
  end

end