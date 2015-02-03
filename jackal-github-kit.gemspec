$LOAD_PATH.unshift File.expand_path(File.dirname(__FILE__)) + '/lib/'
require 'jackal-github-kit/version'
Gem::Specification.new do |s|
  s.name = 'jackal-github-kit'
  s.version = Jackal::GithubKit::VERSION.version
  s.summary = 'Message processing helper'
  s.author = 'Chris Roberts'
  s.email = 'code@chrisroberts.org'
  s.homepage = 'https://github.com/carnivore-rb/jackal-github-kit'
  s.description = 'GitHub interaction helper'
  s.require_path = 'lib'
  s.license = 'Apache 2.0'
  s.add_dependency 'jackal'
  s.add_dependency 'octokit'
  s.files = Dir['lib/**/*'] + %w(jackal-github-kit.gemspec README.md CHANGELOG.md CONTRIBUTING.md LICENSE)
end
