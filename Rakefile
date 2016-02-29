desc 'Install gems that this app depends on. May need to be run with sudo.'
task :install_dependencies do
  dependencies = {
    'json'       => '1.8.0',
    'sshkit'     => '1.8.1',
    'sshkit/dsl' => '1.8.1',
    'yaml'       => '4.2.2',
  }
  dependencies.each do |gem_name, version|
    puts "#{gem_name} #{version}"
    system "gem install #{gem_name} --version #{version}"
  end
end

require 'json'
require 'sshkit'
require 'sshkit/dsl'
require 'yaml'
require_relative 'lib/emailer'

Rake.add_rakelib 'lib/tasks'

env = ''
if ENV['DEPLOY_ENV']
  env = ENV['DEPLOY_ENV']
end

if File.exists? "./config-#{ENV['DEPLOY_ENV']}.yml"
  @config = YAML.load_file("./config-#{ENV['DEPLOY_ENV']}.yml")
elsif File.exists? "./config.#{ENV['DEPLOY_ENV']}.yml"
  @config = YAML.load_file("./config.#{ENV['DEPLOY_ENV']}.yml")
elsif File.exists? "./config.yml"
  @config = YAML.load_file("./config.yml")
else
  puts 'Couldn\'t find a configuration file. Quitting...'
  exit 1
end
@timestamp = Time.now.strftime('%Y%m%d%H%M%S%Z')

task 'backup:both'   => ['backup:config', 'backup:public']
task 'db:migrate'    => ['deploy:common']
task 'deploy:all'    => ['db:migrate', 'deploy:config', 'deploy:public']
task 'deploy:both'   => ['deploy:config', 'deploy:public']
task 'deploy:config' => ['deploy:common']
task 'deploy:public' => ['deploy:common']
task 'destroy:both'  => ['destroy:config', 'destroy:public']
task 'setup:both'    => ['setup:config', 'setup:public']

