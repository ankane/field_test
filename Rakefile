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
    x.report("two variants") do
      binary_test = FieldTest::BinaryTest.new
      binary_test.add(1000, 900)
      binary_test.add(800, 700)
      binary_test.probabilities
    end
    x.report("three variants") do
      binary_test = FieldTest::BinaryTest.new
      binary_test.add(1000, 900)
      binary_test.add(800, 700)
      binary_test.add(600, 500)
      binary_test.probabilities
    end
    x.report("four variants") do
      binary_test = FieldTest::BinaryTest.new
      binary_test.add(1000, 900)
      binary_test.add(800, 700)
      binary_test.add(600, 500)
      binary_test.add(400, 300)
      binary_test.probabilities
    end
  end
end
