# frozen_string_literal: true

require_relative "lib/activerecord-pg-format-db-structure/version"

Gem::Specification.new do |spec|
  spec.name = "activerecord-pg-format-db-structure"
  spec.version = ActiveRecordPgFormatDbStructure::VERSION
  spec.authors = ["Jell"]
  spec.email = ["rubygems@reify.se"]

  spec.summary = "Automatic formatting of Rails db/structure.sql file using pg_query"
  spec.description = "automatically runs after each db:schema:dump and formats the output"
  spec.homepage = "https://github.com/ReifyAB/activerecord-pg-format-db-structure"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 3.1.0"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = spec.homepage
  spec.metadata["changelog_uri"] = "https://github.com/ReifyAB/activerecord-pg-format-db-structure/blob/main/CHANGELOG.md"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  gemspec = File.basename(__FILE__)
  spec.files = IO.popen(%w[git ls-files -z], chdir: __dir__, err: IO::NULL) do |ls|
    ls.readlines("\x0", chomp: true).reject do |f|
      (f == gemspec) ||
        f.start_with?(*%w[bin/ test/ spec/ features/ .git .github appveyor Gemfile])
    end
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  # Uncomment to register a new dependency of your gem
  spec.add_dependency "pg_query", "~> 6.1"

  # For more information and examples about making a new gem, check out our
  # guide at: https://bundler.io/guides/creating_gem.html
  spec.metadata["rubygems_mfa_required"] = "true"
end
