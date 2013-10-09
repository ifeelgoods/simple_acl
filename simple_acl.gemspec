$:.push File.expand_path('../lib', __FILE__)

require 'simple_acl/version'

Gem::Specification.new do |gem|
  gem.platform      = Gem::Platform::RUBY
  gem.name          = 'simple_acl'
  gem.version       = SimpleAcl::VERSION
  gem.author        = 'mtparet'
  gem.email         = 'tech@ifeelgoods.com'
  gem.description   = 'Simple Gem to use ACL in ruby (and especially in Rails) based on a role given. Great use with Devise.'
  gem.summary       = 'Simple Gem to implement ACL in Rails based on a role given.'
  gem.homepage      = 'https://github.com/ifeelgoods/simple_acl'
  gem.files         = Dir['RELEASENOTES', 'README.md', 'lib/**/*']
  gem.require_path = 'lib'

  gem.add_development_dependency 'rspec', '~> 2.14'
end
