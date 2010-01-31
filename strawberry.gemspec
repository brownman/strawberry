# Generated by jeweler
# DO NOT EDIT THIS FILE DIRECTLY
# Instead, edit Jeweler::Tasks in Rakefile, and run the gemspec command
# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{strawberry}
  s.version = "0.5.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Dmitry A. Ustalov of Peppery"]
  s.date = %q{2010-01-31}
  s.description = %q{Tree-Oriented Table Data Storage.}
  s.email = %q{eveel@peppery.me}
  s.extra_rdoc_files = [
    "README",
     "README.rdoc"
  ]
  s.files = [
    ".gitignore",
     "MIT-LICENSE",
     "README",
     "README.rdoc",
     "Rakefile",
     "VERSION",
     "examples/.gitignore",
     "examples/roll.rb",
     "examples/schedules.rb",
     "lib/strawberry.rb",
     "lib/strawberry/base.rb",
     "lib/strawberry/dao.rb",
     "lib/strawberry/node.rb",
     "lib/strawberry/tokyo.rb",
     "lib/strawberry/uuid.rb",
     "strawberry.gemspec",
     "test/.gitignore",
     "test/base_test.rb",
     "test/dao_test.rb",
     "test/node_test.rb",
     "test/test_helper.rb",
     "test/uuid_test.rb"
  ]
  s.homepage = %q{http://github.com/peppery/strawberry}
  s.rdoc_options = ["--charset=UTF-8"]
  s.require_paths = ["lib"]
  s.rubyforge_project = %q{strawberry}
  s.rubygems_version = %q{1.3.5}
  s.summary = %q{Tree-Oriented Table Data Storage.}
  s.test_files = [
    "test/test_helper.rb",
     "test/dao_test.rb",
     "test/node_test.rb",
     "test/uuid_test.rb",
     "test/base_test.rb",
     "examples/schedules.rb",
     "examples/roll.rb"
  ]

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
      s.add_development_dependency(%q<shoulda>, [">= 2.10.2"])
      s.add_runtime_dependency(%q<rufus-tokyo>, [">= 1.0.5"])
      s.add_runtime_dependency(%q<uuid>, [">= 2.1.1"])
    else
      s.add_dependency(%q<shoulda>, [">= 2.10.2"])
      s.add_dependency(%q<rufus-tokyo>, [">= 1.0.5"])
      s.add_dependency(%q<uuid>, [">= 2.1.1"])
    end
  else
    s.add_dependency(%q<shoulda>, [">= 2.10.2"])
    s.add_dependency(%q<rufus-tokyo>, [">= 1.0.5"])
    s.add_dependency(%q<uuid>, [">= 2.1.1"])
  end
end

