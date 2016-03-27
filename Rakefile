require 'rake/extensiontask'
require 'bundler/gem_tasks'
require 'rspec/core/rake_task'

RSpec::Core::RakeTask.new(:spec)

spec = Gem::Specification.load('pcp_easy.gemspec')
Rake::ExtensionTask.new('pcp_easy', spec)

Bundler::GemHelper.install_tasks