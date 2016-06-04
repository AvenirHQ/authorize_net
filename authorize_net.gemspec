Gem::Specification.new do |spec|
  spec.name = 'authorize_net'
  spec.version = '0.1.1'
  spec.date = '2016-06-04'
  spec.summary = 'API interface for Authorize.net payment gateway'
  spec.description = 'A RubyGem that interfaces with the Authorize.net payment gateway'
  spec.authors = ['Avenir Interactive LLC']
  spec.email = ['info@avenirhq.com']
  spec.homepage = 'https://github.com/AvenirHQ/authorize_net'
  spec.license = 'MIT'

  spec.require_path = 'lib'
  spec.files = Dir["lib/**/*.rb"]

  spec.add_runtime_dependency 'nokogiri', '= 1.6.7.2', '>= 1.6.7.2'

end
