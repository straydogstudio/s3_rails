$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "s3_rails/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "s3_rails"
  s.version     = S3Rails::VERSION
  s.authors     = ["Noel Peden"]
  s.email       = ["noel@peden.biz"]
  s.homepage    = "https://github.com/straydogstudio/s3_rails"
  s.summary     = "A Rails resolver that retrieves templates from Amazon's S3 service."
  s.description = "A Rails resolver that retrieves templates from Amazon's S3 service."
  s.license     = "MIT"

  s.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.rdoc"]
  s.test_files = Dir["test/**/*"]

  s.add_dependency "rails", ">=3.2"
  s.add_dependency "aws-sdk"

  s.add_development_dependency "sqlite3"
  s.add_development_dependency "coveralls"
  s.add_development_dependency "pry"
  s.add_development_dependency "pry-nav"
  s.add_development_dependency "aws-sdk"
end
