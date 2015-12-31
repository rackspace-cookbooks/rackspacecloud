
require 'bundler/setup'
require 'rspec/core/rake_task'
require 'rubocop/rake_task'
require 'foodcritic'
require 'kitchen'

# Style tests. Rubocop and Foodcritic
namespace :style do
  desc 'Run Chef style checks'
  FoodCritic::Rake::LintTask.new(:chef) do |t|
    t.options = {
      search_gems: true,
      fail_tags: %w(any),
      # FC015: Consider converting definition to a LWRP (allow definitions without complaining)
      tags: %w(~FC015 ~FC041 ~RACK004 ~RACK009),
      chef_version: '11.6.0' # 12.2 was not valid - https://github.com/acrmp/foodcritic/issues/221
    }
  end

  desc 'Run Ruby style checks'
  RuboCop::RakeTask.new(:ruby)
end

desc 'Run all style checks'
task style: ['style:chef', 'style:ruby']

# Rspec and ChefSpec
desc 'Run ChefSpec unit tests'
RSpec::Core::RakeTask.new(:spec) do |t, args|
  t.rspec_opts = 'test/unit'
end

# Integration tests. Kitchen.ci
task :integration do
  desc 'Run Test Kitchen'
  Kitchen.logger = Kitchen.default_file_logger
  @loader = Kitchen::Loader::YAML.new(
    local_config: ENV['KITCHEN_LOCAL_YAML']
  )
  if ENV['KITCHEN_CONCURRENCY_DISABLE']
    Kitchen::Config.new(loader: @loader).instances.each do |instance|
      instance.test(:always)
    end
  else
    config = Kitchen::Config.new(loader: @loader)
    concurrency = config.instances.size
    queue = Queue.new
    config.instances.each { |i| queue << i }
    concurrency.times { queue << nil }
    threads = []
    concurrency.times do
      threads << Thread.new do
        while instance = queue.pop
          instance.send('test')
        end
      end
    end
    threads.map(&:join)
  end
end

# Default
task default: ['style', 'spec', 'integration']
