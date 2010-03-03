require 'rubygems'
require 'rake'
require 'rake/rdoctask'
require 'rake/gempackagetask'
require 'spec/rake/spectask'

desc 'Default: run unit tests.'
task :default => :test

desc 'Test http_configuration.'
Spec::Rake::SpecTask.new(:test) do |t|
  t.spec_files = 'spec/**/*_spec.rb'
end

desc 'Generate documentation for http_configuration.'
Rake::RDocTask.new(:rdoc) do |rdoc|
  rdoc.rdoc_dir = 'rdoc'
  rdoc.options << '--title' << 'HTTP Configuration' << '--line-numbers' << '--inline-source' << '--main' << 'README'
  rdoc.rdoc_files.include('README')
  rdoc.rdoc_files.include('lib/**/*.rb')
end

spec = Gem::Specification.new do |s| 
  s.name = "http_configuration"
  s.version = "1.0.2"
  s.author = "Brian Durand"
  s.platform = Gem::Platform::RUBY
  s.summary = "Provide configuration options for Net::HTTP"
  s.files = FileList["lib/*", "init.rb", "MIT-LICENSE", 'Rakefile'].to_a
  s.require_path = "lib"
  s.test_files = FileList["{spec}/**/*_spec.rb"].to_a
  s.has_rdoc = true
  s.rdoc_options << '--title' << 'HTTP Configuration' << '--line-numbers' << '--inline-source' << '--main' << 'README'
  s.extra_rdoc_files = ["README"]
  s.homepage = "http://httpconfig.rubyforge.org"
  s.rubyforge_project = "httpconfig"
  s.email = 'brian@embellishedvisions.com'
  s.requirements = 'rspec 1.0.8 or higher is needed to run the tests'
end
 
Rake::GemPackageTask.new(spec) do |pkg| 
  pkg.need_tar = true 
end