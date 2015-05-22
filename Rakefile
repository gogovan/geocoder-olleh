require 'bundler'
Bundler::GemHelper.install_tasks

ACCEPTED_DB_VALUES = %w(sqlite postgres mysql)
DATABASE_CONFIG_FILE = 'test/database.yml'

def config
  require 'yaml'
  YAML.load(File.open(DATABASE_CONFIG_FILE))
end

namespace :db do
  task :create do
    if ACCEPTED_DB_VALUES.include? ENV['DB']
      Rake::Task["db:#{ENV['DB']}:create"].invoke
    end
  end

  task :drop do
    if ACCEPTED_DB_VALUES.include? ENV['DB']
      Rake::Task["db:#{ENV['DB']}:drop"].invoke
    end
  end

  task :reset => [:drop, :create]

  namespace :mysql do
    desc 'Create the MySQL test databases'
    task :create do
      `mysql --user=#{config['mysql']['username']} -e "create DATABASE #{config['mysql']['database']} DEFAULT CHARACTER SET utf8 DEFAULT COLLATE utf8_unicode_ci "`
    end

    desc 'Drop the MySQL test databases'
    task :drop do
      `mysqladmin --user=#{config['mysql']['username']} -f drop #{config['mysql']['database']}`
    end
  end

  namespace :postgres do
    desc 'Create the PostgreSQL test databases'
    task :create do
      `createdb -E UTF8 -T template0 #{config['postgres']['database']}`
    end

    desc 'Drop the PostgreSQL test databases'
    task :drop do
      `dropdb #{config['postgres']['database']}`
    end
  end

  namespace :sqlite do
    task :drop
    task :create
  end
end

require 'rake/testtask'
desc "Use DB to test with #{ACCEPTED_DB_VALUES}, otherwise test standalone"
Rake::TestTask.new(:test) do |test|
  Rake::Task['db:reset'].invoke if ACCEPTED_DB_VALUES.include? ENV['DB']
  test.libs << 'lib' << 'test'
  test.pattern = 'test/unit/**/*_test.rb'
  test.verbose = true
end

# Rake::TestTask.new(:integration) do |test|
#   test.libs << 'lib' << 'test'
#   test.pattern = 'test/integration/*_test.rb'
#   test.verbose = true
# end

task :default => [:test]

require 'rdoc/task'
Rake::RDocTask.new do |rdoc|
  rdoc.rdoc_dir = 'rdoc'
  rdoc.title = "Geocoder #{Geocoder::Olleh::VERSION}"
  rdoc.rdoc_files.include('*.rdoc')
  rdoc.rdoc_files.include('lib/**/*.rb')
end
