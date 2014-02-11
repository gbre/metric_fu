MetricFu.reporting_require { 'graphs/grapher' }
module MetricFu
  class TestCoverageGrapher < Grapher
    attr_accessor :test_coverage_percent, :labels

    def self.metric
      :test_coverage
    end

    def initialize
      super
      self.test_coverage_percent = []
      self.labels = {}
    end

    def get_metrics(metrics, date)
      if coverage_metrics = metrics(metrics)
        self.test_coverage_percent.push(coverage_metrics[:global_percent_run])
        self.labels.update( { self.labels.size => date })
      end
    end

    # Coverage metrics keys backwards compatibility
    def metrics(metrics)
      metrics &&
        metrics.fetch(:test_coverage) { metrics[:rcov] }
    end

    def title
      'TestCoverage: code coverage'
    end

    def data
      [
        ['test_coverage', @test_coverage_percent.join(',')]
      ]
    end

    def output_filename
      'test_coverage.js'
    end

  end
end
