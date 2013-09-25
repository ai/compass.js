# encoding: utf-8

Gem::Specification.new do |s|
  s.platform    = Gem::Platform::RUBY
  s.name        = 'compassjs'
  s.version     = VERSION
  s.summary     = 'Compass.js allow you to get compass heading in JavaScript'
  s.description = 'Compass.js allow you to get compass heading in JavaScript ' +
                  'by PhoneGap, iOS API or GPS hack.'

  s.files            = ['lib/assets/javascripts/compass.js', 'lib/compassjs.rb',
                        'LICENSE', 'README.md', 'ChangeLog']
  s.extra_rdoc_files = ['LICENSE', 'README.md', 'ChangeLog']
  s.require_path     = 'lib'

  s.authors  = ['Andrey "A.I." Sitnik']
  s.email    = ['andrey@sitnik.ru']
  s.homepage = 'http://ai.github.io/compass.js/'
  s.license  = 'MIT'

  s.add_dependency 'sprockets', '>= 2'
end
