# encoding: utf-8

Gem::Specification.new do |s|
  s.name        = 'compassjs'
  s.version     = VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ['Andrey "A.I." Sitnik']
  s.email       = ['andrey@sitnik.ru']
  s.homepage    = 'http://ai.github.com/compass.js/'
  s.summary     = 'Compass.js allow you to get compass heading in JavaScript'
  s.description = 'Compass.js allow you to get compass heading in JavaScript ' +
                  'by PhoneGap, iOS API or GPS hack.'

  s.add_dependency 'sprockets', '>= 2'

  s.files            = ['lib/assets/javascripts/compass.js', 'lib/compassjs.rb',
                        'LICENSE', 'README.md', 'ChangeLog']
  s.extra_rdoc_files = ['LICENSE', 'README.md', 'ChangeLog']
  s.require_path     = 'lib'
end
