require 'spec_helper'

describe PCPEasy::Metric do

  let(:metric_values) { [double('PCPEasy::Metric::Value')] }
  let(:pm_desc) { double('PCPEasy::PMAPI::PmDesc')}
  let(:metric) { PCPEasy::Metric.new('my.metric', pm_desc, metric_values) }

  describe '#name' do
    it 'should return the name' do
      expect(metric.name).to eq 'my.metric'
    end
  end

  describe '#values' do
    it 'should return the values' do
      expect(metric.values).to eq metric_values
    end
  end

  describe '#semantics' do
    it 'returns :counter for counter semantics' do
      allow(pm_desc).to receive(:sem).and_return PCPEasy::PMAPI::PM_SEM_COUNTER
      expect(metric.semantics).to eq :counter
    end
    it 'returns :instant for instant semantics' do
      allow(pm_desc).to receive(:sem).and_return PCPEasy::PMAPI::PM_SEM_INSTANT
      expect(metric.semantics).to eq :instant
    end
    it 'returns :discrete for discrete semantics' do
      allow(pm_desc).to receive(:sem).and_return PCPEasy::PMAPI::PM_SEM_DISCRETE
      expect(metric.semantics).to eq :discrete
    end
    it 'returns :unknown for unknown metrics' do
      allow(pm_desc).to receive(:sem).and_return 123
      expect(metric.semantics).to eq :unknown
    end
  end

  describe '#type' do
    it 'should :no_support for metrics that are not supported' do
      allow(pm_desc).to receive(:type).and_return PCPEasy::PMAPI::PM_TYPE_NOSUPPORT
      expect(metric.type).to eq :no_support
    end
    it 'should return :int32 for signed 32bit types' do
      allow(pm_desc).to receive(:type).and_return PCPEasy::PMAPI::PM_TYPE_32
      expect(metric.type).to eq :int32
    end
    it 'should return :uint32 for unsigned 32bit types' do
      allow(pm_desc).to receive(:type).and_return PCPEasy::PMAPI::PM_TYPE_U32
      expect(metric.type).to eq :uint32
    end
    it 'should return :int64 for signed 64bit types' do
      allow(pm_desc).to receive(:type).and_return PCPEasy::PMAPI::PM_TYPE_64
      expect(metric.type).to eq :int64
    end
    it 'should return :uint64 for unsigned 64bit types' do
      allow(pm_desc).to receive(:type).and_return PCPEasy::PMAPI::PM_TYPE_U64
      expect(metric.type).to eq :uint64
    end
    it 'should return :float for float types' do
      allow(pm_desc).to receive(:type).and_return PCPEasy::PMAPI::PM_TYPE_FLOAT
      expect(metric.type).to eq :float
    end
    it 'should return :double for double types' do
      allow(pm_desc).to receive(:type).and_return PCPEasy::PMAPI::PM_TYPE_DOUBLE
      expect(metric.type).to eq :double
    end
    it 'should return :string for string types' do
      allow(pm_desc).to receive(:type).and_return PCPEasy::PMAPI::PM_TYPE_STRING
      expect(metric.type).to eq :string
    end
    it 'should return :aggregate for aggregate types' do
      allow(pm_desc).to receive(:type).and_return PCPEasy::PMAPI::PM_TYPE_AGGREGATE
      expect(metric.type).to eq :aggregate
    end
    it 'should return :aggregate_static for static aggregate types' do
      allow(pm_desc).to receive(:type).and_return PCPEasy::PMAPI::PM_TYPE_AGGREGATE_STATIC
      expect(metric.type).to eq :aggregate_static
    end
    it 'should return :event for event types' do
      allow(pm_desc).to receive(:type).and_return PCPEasy::PMAPI::PM_TYPE_EVENT
      expect(metric.type).to eq :event
    end
    it 'should return :event_highres for highres event types' do
      allow(pm_desc).to receive(:type).and_return PCPEasy::PMAPI::PM_TYPE_HIGHRES_EVENT
      expect(metric.type).to eq :highres_event
    end
    it 'should return :event_highres for highres event types' do
      allow(pm_desc).to receive(:type).and_return PCPEasy::PMAPI::PM_TYPE_UNKNOWN
      expect(metric.type).to eq :unknown
    end
  end

  describe '#units' do

    let(:pm_units) { double('PCPEasy::PMAPI::PmUnits') }

    before do
      allow(pm_desc).to receive(:units).and_return pm_units
    end

    it 'should return the units for space domain' do
      allow(pm_units).to receive(:dim_space).and_return 1
      allow(pm_units).to receive(:dim_time).and_return 0
      allow(pm_units).to receive(:dim_count).and_return 0
      allow(pm_units).to receive(:scale_space).and_return PCPEasy::PMAPI::PM_SPACE_KBYTE

      expect(metric.units).to eq :domain => :kilobytes, :range => nil
    end
    it 'should return the units for space/time' do
      allow(pm_units).to receive(:dim_space).and_return 1
      allow(pm_units).to receive(:dim_time).and_return -1
      allow(pm_units).to receive(:dim_count).and_return 0
      allow(pm_units).to receive(:scale_space).and_return PCPEasy::PMAPI::PM_SPACE_KBYTE
      allow(pm_units).to receive(:scale_time).and_return PCPEasy::PMAPI::PM_TIME_SEC

      expect(metric.units).to eq :domain => :kilobytes, :range => :seconds
    end
    it 'should return the units for space/count' do
      allow(pm_units).to receive(:dim_space).and_return 1
      allow(pm_units).to receive(:dim_time).and_return 0
      allow(pm_units).to receive(:dim_count).and_return -1
      allow(pm_units).to receive(:scale_space).and_return PCPEasy::PMAPI::PM_SPACE_KBYTE
      allow(pm_units).to receive(:scale_count).and_return 3

      expect(metric.units).to eq :domain => :kilobytes, :range => :count3
    end
    it 'should return the units for time domain' do
      allow(pm_units).to receive(:dim_space).and_return 0
      allow(pm_units).to receive(:dim_time).and_return 1
      allow(pm_units).to receive(:dim_count).and_return 0
      allow(pm_units).to receive(:scale_time).and_return PCPEasy::PMAPI::PM_TIME_SEC

      expect(metric.units).to eq :domain => :seconds, :range => nil
    end
    it 'should return the units for time/space' do
      allow(pm_units).to receive(:dim_space).and_return -1
      allow(pm_units).to receive(:dim_time).and_return 1
      allow(pm_units).to receive(:dim_count).and_return 0
      allow(pm_units).to receive(:scale_time).and_return PCPEasy::PMAPI::PM_TIME_SEC
      allow(pm_units).to receive(:scale_space).and_return PCPEasy::PMAPI::PM_SPACE_MBYTE

      expect(metric.units).to eq :domain => :seconds, :range => :megabytes
    end
  end

  describe '#==' do

    let(:pm_units) { double('PmUnits') }
    let(:other_pm_units) { double('PmUnits') }
    let(:other_pm_desc) { double('PmDesc')}


    before do
      allow(pm_desc).to receive(:sem).and_return PCPEasy::PMAPI::PM_SEM_COUNTER
      allow(pm_desc).to receive(:type).and_return PCPEasy::PMAPI::PM_TYPE_32
      allow(pm_desc).to receive(:units).and_return pm_units
      allow(pm_units).to receive(:dim_space).and_return 0
      allow(pm_units).to receive(:dim_count).and_return 0
      allow(pm_units).to receive(:dim_time).and_return 0

      allow(other_pm_desc).to receive(:sem).and_return PCPEasy::PMAPI::PM_SEM_COUNTER
      allow(other_pm_desc).to receive(:type).and_return PCPEasy::PMAPI::PM_TYPE_32
      allow(other_pm_desc).to receive(:units).and_return other_pm_units
      allow(other_pm_units).to receive(:dim_space).and_return 0
      allow(other_pm_units).to receive(:dim_count).and_return 0
      allow(other_pm_units).to receive(:dim_time).and_return 0
    end

    it 'should be false for different metric names' do
      other = PCPEasy::Metric.new('not.my.metric', other_pm_desc, metric_values)

      expect(metric).to_not eq other
    end
    it 'should be false for different values' do
      other = PCPEasy::Metric.new('my.metric', other_pm_desc, nil)

      expect(metric).to_not eq other
    end
    it 'should be false for different classes' do
      other = "not a metric"

      expect(metric).to_not eq other
    end
    it 'should be false for different semantics' do
      other = PCPEasy::Metric.new('my.metric', other_pm_desc, metric_values)
      allow(other_pm_desc).to receive(:sem).and_return PCPEasy::PMAPI::PM_SEM_INSTANT

      expect(metric).to_not eq other
    end
    it 'should be false for different metric type' do
      other = PCPEasy::Metric.new('my.metric', other_pm_desc, metric_values)
      allow(other_pm_desc).to receive(:type).and_return PCPEasy::PMAPI::PM_TYPE_64

      expect(metric).to_not eq other
    end
    it 'should be false for different units' do
      other = PCPEasy::Metric.new('my.metric', other_pm_desc, metric_values)
      allow(other_pm_units).to receive(:dim_space).and_return 1
      allow(other_pm_units).to receive(:scale_space).and_return PCPEasy::PMAPI::PM_SPACE_KBYTE

      expect(metric).to_not eq other
    end
    it 'should be true if the metrics are the same' do
      other = PCPEasy::Metric.new('my.metric', other_pm_desc, metric_values)

      expect(metric).to eq other
    end
  end

end