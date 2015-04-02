# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'password_expiration_notifier/version'

Gem::Specification.new do |spec|
  spec.name          = "password_expiration_notifier"
  spec.version       = PasswordExpirationNotifier::VERSION
  spec.authors       = ["ISOBE Kazuhiko"]
  spec.email         = ["muramasa64@gmail.com"]
  spec.summary       = %q{Notify the password expiration date of the Active Directory account}
  spec.description   = %q{Notify the password expiration date of the Active Directory account}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.7"
  spec.add_development_dependency "rake", "~> 10.0"

  spec.add_dependency "thor"
  spec.add_dependency "activeldap"
  spec.add_dependency "net-ldap"
  spec.add_dependency "slack-notify"
end
