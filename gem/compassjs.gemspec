# encoding: utf-8

Gem::Specification.new do |s|
  s.name        = 'compassjs'
  s.version     = '0.0.1'
  s.platform    = Gem::Platform::RUBY
  s.authors     = ['Andrey "A.I." Sitnik']
  s.email       = ['andrey@sitnik.ru']
  s.homepage    = 'https://github.com/ai/compass.js'
  s.summary     = ''
  s.description = ''

  s.add_dependency 'sprockets', '>= 2'

  s.files            = ['lib/assets/javascripts/compass.js', 'lib/compassjs.rb',
                        'LICENSE', 'README.md', 'ChangeLog']
  s.extra_rdoc_files = ['LICENSE', 'README.md', 'ChangeLog']
  s.require_path     = 'lib'
end
