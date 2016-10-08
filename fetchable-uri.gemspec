# frozen_string_literal: true
Gem::Specification.new do |s|
  s.name      = 'fetchable-uri'
  s.version   = '0.0.1'
  s.license   = 'MIT'
  s.summary   = 'URI fetching extension for Addressable::URI'
  s.author    = 'DragonMaus'
  s.homepage  = 'https://github.com/dragonmaus/fetchable-uri'
  s.files     = ['lib/addressable/uri/fetch.rb']

  s.add_runtime_dependency 'addressable', '~> 2.4'
end
