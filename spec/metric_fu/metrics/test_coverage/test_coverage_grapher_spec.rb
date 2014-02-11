require "spec_helper"
MetricFu.metrics_require { 'test_coverage/test_coverage_grapher' }

describe TestCoverageGrapher do
  before :each do
    @test_coverage_grapher = MetricFu::TestCoverageGrapher.new
    MetricFu.configuration
  end

  it "should respond to test_coverage_percent and labels" do
    expect(@test_coverage_grapher).to respond_to(:test_coverage_percent)
    expect(@test_coverage_grapher).to respond_to(:labels)
  end

  describe "responding to #initialize" do
    it "should initialise test_coverage_percent and labels" do
      expect(@test_coverage_grapher.test_coverage_percent).to eq([])
      expect(@test_coverage_grapher.labels).to eq({})
    end
  end

  describe "responding to #get_metrics" do
    context "when metrics were not generated" do
      before(:each) do
        @metrics = FIXTURE.load_metric("metric_missing.yml")
        @date = "1/2"
      end

      it "should not push to test_coverage_percent" do
        expect(@test_coverage_grapher.test_coverage_percent).not_to receive(:push)
        @test_coverage_grapher.get_metrics(@metrics, @date)
      end

      it "should not update labels with the date" do
        expect(@test_coverage_grapher.labels).not_to receive(:update)
        @test_coverage_grapher.get_metrics(@metrics, @date)
      end
    end

    context "when metrics have been generated" do
      before(:each) do
        @metrics = FIXTURE.load_metric("20090630.yml")
        @date = "1/2"
      end

      it "should push to test_coverage_percent" do
        expect(@test_coverage_grapher.test_coverage_percent).to receive(:push).with(49.6)
        @test_coverage_grapher.get_metrics(@metrics, @date)
      end

      it "should update labels with the date" do
        expect(@test_coverage_grapher.labels).to receive(:update).with({ 0 => "1/2" })
        @test_coverage_grapher.get_metrics(@metrics, @date)
      end
    end
  end
end
