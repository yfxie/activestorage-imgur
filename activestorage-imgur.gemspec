$:.push File.expand_path("lib", __dir__)

# Maintain your gem's version:
require "active_storage/imgur/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "activestorage-imgur"
  s.version     = ActiveStorage::Imgur::VERSION
  s.authors     = ["Yi Feng"]
  s.email       = ["yfxie@me.com"]
  s.homepage    = "https://github.com/yfxie/activestorage-imgur"
  s.summary     = "An ActiveStorage driver for storing images on Imgur hosting."
  s.license     = "MIT"

  s.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.md"]

  s.add_dependency "rails", "~> 5.2"
  s.add_dependency "imgurapi", "~> 3.2"
  s.add_dependency "down", "~> 4.4"
  s.add_dependency "image_processing", "~> 1.2"

  s.add_development_dependency "sqlite3", "~> 1.3"
  s.add_development_dependency "pry", "~> 0.11"
  s.add_development_dependency "dotenv-rails", "~> 2.5"
  s.add_development_dependency "mocha", "~> 1.5"
end
