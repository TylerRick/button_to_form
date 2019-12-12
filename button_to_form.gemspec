
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "button_to_form/version"

Gem::Specification.new do |spec|
  spec.name          = "button_to_form"
  spec.version       = ButtonToForm::Version
  spec.authors       = ["Tyler Rick"]
  spec.email         = ["tyler@tylerrick.com"]

  spec.summary       = %q{A button_to helper that can be used inside a form tag (unlike Rails's own button_to)}
  spec.description   = spec.summary
  spec.homepage      = "https://github.com/TylerRick/button_to_form"

  spec.metadata["homepage_uri"]    = spec.homepage
  spec.metadata["source_code_uri"] = spec.homepage
  spec.metadata["changelog_uri"] = "#{spec.metadata["source_code_uri"]}/blob/master/Changelog.md"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files         = Dir.chdir(File.expand_path('..', __FILE__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.required_ruby_version = ">= 2.3.0"
  spec.add_dependency "actionpack", ">= 4.2"
end
