require "bundler/gem_tasks"
require "rake/testtask"
require "rake/extensiontask"

task default: :test
Rake::TestTask.new do |t|
  t.libs << "test"
  t.pattern = "test/**/*_test.rb"
  t.warning = false
end

Rake::ExtensionTask.new("field_test") do |ext|
  ext.name = "ext"
  ext.lib_dir = "lib/field_test"
end

task :remove_ext do
  path = "lib/field_test/ext.bundle"
  File.unlink(path) if File.exist?(path)
end

Rake::Task["build"].enhance [:remove_ext]

task :benchmark do
  require "benchmark/ips"
  require "field_test"

  Benchmark.ips do |x|
    x.report("prob_b_beats_a") do
      FieldTest::Calculations.prob_b_beats_a(1000, 900, 800, 700)
    end
    x.report("prob_c_beats_a_and_b") do
      FieldTest::Calculations.prob_c_beats_a_and_b(1000, 900, 800, 700, 600, 500)
    end
    x.report("prob_d_beats_a_and_b_and_c") do
      FieldTest::Calculations.prob_d_beats_a_and_b_and_c(1000, 900, 800, 700, 600, 500, 400, 300)
    end
  end
end
