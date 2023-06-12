$:.unshift File.expand_path('lib', __dir__)
require 'bidify/version'

Gem::Specification.new do |s|
  s.name          = 'bidify'
  s.version       = Bidify::VERSION
  s.authors       = ['Mostafa Ahangarha']
  s.email         = ['ahangarha@riseup.net']
  s.homepage      = 'https://github.com/dobidi/bidify-rb'
  s.licenses      = ['LGPL-3.0-or-later']
  s.summary       = '[Add bidi support to HTML]'
  s.description   = '[This gem help you to add bidirectional text support to any HTML partials]'

  s.files         = Dir.glob('{bin/*,lib/**/*,[A-Z]*}')
  s.platform      = Gem::Platform::RUBY
  s.require_paths = ['lib']

  s.add_dependency 'nokogiri', '~>1.10'

  s.add_development_dependency 'rspec', '~>3.10'
end
