#!/usr/bin/env rake
begin
  require 'bundler/setup'
rescue LoadError
  puts 'You must `gem install bundler` and `bundle install` to run rake tasks'
end

require 'yard'
YARD::Rake::YardocTask.new do |t|
  t.files = [
    'lib/**/*.rb',
    '-',
    'README.md',
    'STATUS_MATRIX.html',
    'RELATED_WORK.md',
  ]
  t.options = %w(--markup=markdown --markup-provider=redcarpet)
end

Bundler::GemHelper.install_tasks

require 'rake/testtask'

Rake::TestTask.new(:test) do |t|
  t.libs << 'lib'
  t.libs << 'test'
  t.pattern = 'test/**/*_test.rb'
  t.verbose = false
end

task :default => :test
