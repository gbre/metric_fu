module MetricFu
  class MetricTestCoverage < Metric

    def name
      :test_coverage
    end

    def default_run_options
      {
        :environment => 'test',
        :test_files =>  Dir['{spec,test}/**/*_{spec,test}.rb'],
        :rcov_opts => rcov_opts,
      }
    end

    def coverage_file=(coverage_file)
      configured_run_options.update(:external => coverage_file)
    end

    def has_graph?
      true
    end

    def enable
      if external_coverage_file?
        super
      else
        mf_debug("RCov is not available. See README")
      end
    end

    def activate
      super
    end

    def external_coverage_file?
      if run_options.has_key?(:external)
        File.exist?(file = run_options[:external].to_s) ||
          mf_log("Configured RCov file #{file.inspect} does not exist")
      else
        false
      end
    end

    private

    def rcov_opts
      rcov_opts = [
        "--sort coverage",
        "--no-html",
        "--text-coverage",
        "--no-color",
        "--profile",
        "--exclude-only '.*'",
        '--include-file "\Aapp,\Alib"'
      ]
      rcov_opts << "-Ispec" if File.exist?("spec")
      rcov_opts
    end

  end
end
