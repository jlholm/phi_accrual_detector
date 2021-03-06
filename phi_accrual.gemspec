# frozen_string_literal: true

require_relative "lib/phi_accrual/version"

Gem::Specification.new do |spec|
  spec.name = "phi_accrual"
  spec.version = PhiAccrual::VERSION

  spec.authors = ["jlholm"]
  spec.email = ["jlholmz@gmail.com"]

  spec.summary = "Ruby implementation of Akka's Phi Accrual Failure Detector"
  spec.description = ""
  spec.homepage = "https://github.com/jlholm/phi_accrual_detector"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 2.6.0"

  spec.metadata["allowed_push_host"] = "TODO: Set to your gem server 'https://example.com'"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/jlholm/phi_accrual_detector"
  spec.metadata["changelog_uri"] = "https://github.com/jlholm/phi_accrual_detector/blob/master/CHANGELOG.md"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(__dir__) do
    `git ls-files -z`.split("\x0").reject do |f|
      (f == __FILE__) || f.match(%r{\A(?:(?:bin|test|spec|features)/|\.(?:git|travis|circleci)|appveyor)})
    end
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "rake", "~> 13.0"
  spec.add_development_dependency "rspec", "~> 3.0"
  spec.add_development_dependency "standard", "~> 1.0.0"
  spec.add_development_dependency "pry"
end
