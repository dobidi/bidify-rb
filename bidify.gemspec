# frozen_string_literal: true

$LOAD_PATH.unshift File.expand_path('lib', __dir__)
require 'bidify/version'

Gem::Specification.new do |s|
  s.name          = 'bidify'
  s.version       = Bidify::VERSION
  s.authors       = ['Mostafa Ahangarha']
  s.email         = ['ahangarha@riseup.net']
  s.homepage      = 'https://github.com/dobidi/bidify-rb'
  s.licenses      = ['LGPL-3.0-or-later']
  s.summary       = 'Add bidi support to HTML'
  s.description   = 'Bidify helps to add bidirectional text support to HTML document'

  s.files         = Dir.glob('{bin/*,lib/**/*,[A-Z]*}')
  s.platform      = Gem::Platform::RUBY
  s.require_paths = ['lib']
  s.required_ruby_version = '>= 2.7.0'

  s.add_dependency 'nokogiri', '~>1.14'

  s.metadata['rubygems_mfa_required'] = 'true'
end
