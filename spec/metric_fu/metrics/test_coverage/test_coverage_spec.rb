require "spec_helper"
MetricFu.metrics_require { 'test_coverage/test_coverage' }

describe MetricFu::TestCoverageGenerator do

  before do
    setup_fs
    MetricFu::Configuration.run do |config|
      config.configure_metric(:test_coverage) do |test_coverage|
        test_coverage.enabled = true
      end
    end
  end

  before :each do
    @default_options = MetricFu::Metric.get_metric(:test_coverage).run_options
  end

  describe "emit" do
    before :each do
      options = {:external =>  nil}
      @test_coverage = MetricFu::TestCoverageGenerator.new(@default_options.merge(options))
    end

    it "should clear out previous output and make output folder" do
      expect(MetricFu::Utility).to receive(:rm_rf).with(MetricFu::TestCoverageGenerator.metric_directory, :verbose => false)
      expect(MetricFu::Utility).to receive(:mkdir_p).with(MetricFu::TestCoverageGenerator.metric_directory)
      @test_coverage.reset_output_location
    end

    it "should set the RAILS_ENV" do
      expect(MetricFu::Utility).to receive(:rm_rf).with(MetricFu::TestCoverageGenerator.metric_directory, :verbose => false)
      expect(MetricFu::Utility).to receive(:mkdir_p).with(MetricFu::TestCoverageGenerator.metric_directory)
      options = {:environment => 'metrics', :external => nil}
      @test_coverage = MetricFu::TestCoverageGenerator.new(@default_options.merge(options))
      expect(@test_coverage.command).to include('RAILS_ENV=metrics')
    end
  end

  describe "with RCOV_OUTPUT fed into" do
    before :each do
      options = {:external =>  nil}
      @test_coverage = MetricFu::TestCoverageGenerator.new(@default_options.merge(options))
      expect(@test_coverage).to receive(:load_output).and_return(RCOV_OUTPUT)
      @files = @test_coverage.analyze
    end

    describe "analyze" do
      it "should compute percent of lines run" do
        expect(@files["lib/templates/awesome/awesome_template.rb"][:percent_run]).to eq(13)
        expect(@files["lib/templates/standard/standard_template.rb"][:percent_run]).to eq(14)
      end

      it "should know which lines were run" do
        expect(@files["lib/templates/awesome/awesome_template.rb"][:lines]).
              to include({:content=>"require 'fileutils'", :was_run=>true})
      end

      it "should know which lines NOT were run" do
        expect(@files["lib/templates/awesome/awesome_template.rb"][:lines]).
              to include({:content=>"      if template_exists?(section)", :was_run=>false})
      end
    end

    describe "to_h" do
      it "should calculate total percentage for all files" do
        expect(@test_coverage.to_h[:test_coverage][:global_percent_run]).to eq(13.7)
      end
    end
  end
  describe "with external configuration option set" do
    before :each do
      options = {:external =>  'coverage/test_coverage.txt'}
      @test_coverage = MetricFu::TestCoverageGenerator.new(@default_options.merge(options))
    end

    it "should emit nothing if external configuration option is set" do
      expect(MetricFu::Utility).not_to receive(:rm_rf)
      @test_coverage.emit
    end

    it "should open the external test_coverage analysis file" do
      expect(@test_coverage).to receive(:load_output).and_return(RCOV_OUTPUT)
      @files = @test_coverage.analyze
    end

  end


RCOV_OUTPUT = <<-HERE
Profiling enabled.
.............................................................................................................................................................................................


Top 10 slowest examples:
0.2707830 MetricFu::RoodiGrapher responding to #get_metrics should push 13 to roodi_count
0.1994550 MetricFu::TestCoverageGrapher responding to #get_metrics should update labels with the date
0.1985800 MetricFu::ReekGrapher responding to #get_metrics should set a hash of code smells to reek_count
0.1919860 MetricFu::ReekGrapher responding to #get_metrics should update labels with the date
0.1907400 MetricFu::RoodiGrapher responding to #get_metrics should update labels with the date
0.1883000 MetricFu::FlogGrapher responding to #get_metrics should update labels with the date
0.1882650 MetricFu::FlayGrapher responding to #get_metrics should push 476 to flay_score
0.1868780 MetricFu::FlogGrapher responding to #get_metrics should push to top_five_percent_average
0.1847730 MetricFu::FlogGrapher responding to #get_metrics should push 9.9 to flog_average
0.1844090 MetricFu::FlayGrapher responding to #get_metrics should update labels with the date

Finished in 2.517686 seconds

189 examples, 0 failures
================================================================================
lib/templates/awesome/awesome_template.rb
================================================================================
   require 'fileutils'

   class AwesomeTemplate < MetricFu::Template

     def write
!!     # Getting rid of the crap before and after the project name from integrity
!!     @name = File.basename(MetricFu.run_dir).gsub(/^\w+-|-\w+$/, "")
!!
!!     # Copy Bluff javascripts to output directory
!!     Dir[File.join(template_directory, '..', 'javascripts', '*')].each do |f|
!!       FileUtils.copy(f, File.join(MetricFu.output_directory, File.basename(f)))
!!     end
!!
!!     report.each_pair do |section, contents|
!!       if template_exists?(section)
!!         create_instance_var(section, contents)
!!         @html = erbify(section)
!!         html = erbify('layout')
!!         fn = output_filename(section)
!!         MetricFu.report.save_output(html, MetricFu.output_directory, fn)
!!       end
!!     end
!!
!!     # Instance variables we need should already be created from above
!!     if template_exists?('index')
!!       @html = erbify('index')
!!       html = erbify('layout')
!!       fn = output_filename('index')
!!       MetricFu.report.save_output(html, MetricFu.output_directory, fn)
!!     end
!!   end

     def template_directory
!!     File.dirname(__FILE__)
!!   end
!! end

================================================================================
lib/templates/standard/standard_template.rb
================================================================================
   class StandardTemplate < MetricFu::Template


     def write
!!     report.each_pair do |section, contents|
!!       if template_exists?(section)
!!         create_instance_var(section, contents)
!!         html = erbify(section)
!!         fn = output_filename(section)
!!         MetricFu.report.save_output(html, MetricFu.output_directory, fn)
!!       end
!!     end
!!
!!     # Instance variables we need should already be created from above
!!     if template_exists?('index')
!!       html = erbify('index')
!!       fn = output_filename('index')
!!       MetricFu.report.save_output(html, MetricFu.output_directory, fn)
!!     end
!!   end

     def template_directory
!!     File.dirname(__FILE__)
!!   end
!! end

HERE

  after do
    cleanup_fs
  end

end
