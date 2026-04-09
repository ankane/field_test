require "bundler/gem_tasks"
require "rake/testtask"
require "rake/extensiontask"
require "ruby_memcheck"

test_config = lambda do |t|
  t.pattern = "test/**/*_test.rb"
end
Rake::TestTask.new(&test_config)

namespace :test do
  RubyMemcheck::TestTask.new(:valgrind, &test_config)
end

task default: :test

Rake::ExtensionTask.new("field_test") do |ext|
  ext.name = "ext"
  ext.lib_dir = "lib/field_test"
end

task :remove_ext do
  Dir["lib/field_test/ext.{bundle,so}"].each do |path|
    File.unlink(path)
  end
end

Rake::Task["build"].enhance [:remove_ext]

task :benchmark do
  require "benchmark/ips"
  require "field_test"

  Benchmark.ips do |x|
    x.report("two variants") do
      FieldTest::BinaryTest.probabilities([
        {participated: 1000, converted: 900},
        {participated: 800, converted: 700}
      ])
    end
    x.report("three variants") do
      FieldTest::BinaryTest.probabilities([
        {participated: 1000, converted: 900},
        {participated: 800, converted: 700},
        {participated: 600, converted: 500}
      ])
    end
    x.report("four variants") do
      FieldTest::BinaryTest.probabilities([
        {participated: 1000, converted: 900},
        {participated: 800, converted: 700},
        {participated: 600, converted: 500},
        {participated: 400, converted: 300}
      ])
    end
  end
end
