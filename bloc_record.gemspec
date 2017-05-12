Gem::Specification.new do |s|
  s.name          = 'bloc_record'
  s.version       = '0.0.0'
  s.license       = 'MIT'
  s.summary       = 'BlocRecord ORM'
  s.description   = 'An ActiveRecord-esque ORM adaptor'
  s.authors       = ['Jonathan Gonzales']
  s.email         = 'jd_gonzales@icloud.com'
  s.files         = Dir['lib/**/*.rb']
  s.require_paths = ['lib']
  s.homepage      = 'http://rubygems.org/gems/bloc_record'

  s.add_runtime_dependency 'sqlite3', '~>1.3'
  s.add_runtime_dependency 'pg'
  s.add_runtime_dependency 'activesupport'
  s.add_development_dependency 'minitest'
end
