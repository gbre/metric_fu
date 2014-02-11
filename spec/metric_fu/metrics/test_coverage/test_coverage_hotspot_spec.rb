require "spec_helper"
MetricFu.metrics_require { 'hotspots/init' }
MetricFu.metrics_require { 'hotspots/hotspot' }
MetricFu.metrics_require { 'hotspots/analysis/record' }
MetricFu.metrics_require { 'test_coverage/test_coverage_hotspot' }

describe MetricFu::TestCoverageHotspot do
  describe "map" do
    let(:zero_row) do
      MetricFu::Record.new({"percentage_uncovered"=>0.0}, nil)
    end

    let(:non_zero_row) do
      MetricFu::Record.new({"percentage_uncovered"=>0.75}, nil)
    end

    it {expect(subject.map(zero_row)).to eql(0.0)}
    it {expect(subject.map(non_zero_row)).to eql(0.75)}
  end
end
