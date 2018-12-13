# Generated by jeweler
# DO NOT EDIT THIS FILE DIRECTLY
# Instead, edit Jeweler::Tasks in Rakefile, and run 'rake gemspec'
# -*- encoding: utf-8 -*-
# stub: rego-data-grid 0.0.27 ruby lib

Gem::Specification.new do |s|
  s.name = "rego-data-grid".freeze
  s.version = "0.0.27"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib".freeze]
  s.authors = ["Alex Tkachev".freeze]
  s.date = "2018-12-13"
  s.description = "Ajax data grid with pagination".freeze
  s.email = "tkachev.alex@gmail.com".freeze
  s.extra_rdoc_files = [
    "LICENSE.txt",
    "README",
    "README.rdoc"
  ]
  s.files = [
    ".document",
    ".rspec",
    "Gemfile",
    "LICENSE.txt",
    "README",
    "README.rdoc",
    "Rakefile",
    "VERSION",
    "app/views/ajax_data_grid/_grid_api.js.erb",
    "app/views/ajax_data_grid/_no_filter_results.html.haml",
    "app/views/ajax_data_grid/_table_row_create_error.html.haml",
    "app/views/ajax_data_grid/_table_row_destroy_error.html.haml",
    "config/locales/data_grid.en-US.yml",
    "config/locales/data_grid.he-IL.yml",
    "config/locales/will_paginate.en-US.yml",
    "config/locales/will_paginate.he-IL.yml",
    "lib/ajax_data_grid.rb",
    "lib/ajax_data_grid/config.rb",
    "lib/ajax_data_grid/helpers.rb",
    "lib/ajax_data_grid/model.rb",
    "lib/ajax_data_grid/rails_engine.rb",
    "lib/ajax_data_grid/response_helpers.rb",
    "lib/ajax_data_grid/table_builder.rb",
    "lib/ajax_data_grid/table_renderer.rb",
    "lib/ajax_data_grid/toolbar_builder.rb",
    "lib/rego-data-grid.rb",
    "public/images/ajax_data_grid/checked-19x20.png",
    "public/images/ajax_data_grid/delete-32x32.png",
    "public/images/ajax_data_grid/down-white-9x9.gif",
    "public/images/ajax_data_grid/edit-32x32.png",
    "public/images/ajax_data_grid/spinner-16x16.gif",
    "public/images/ajax_data_grid/table_header_bg.png",
    "public/images/ajax_data_grid/unchecked-19x20.png",
    "public/images/ajax_data_grid/up-white-9x9.gif",
    "public/javascripts/vendor/ajax_data_grid/ajax_data_grid.js",
    "public/javascripts/vendor/ajax_data_grid/combobox_editor.js",
    "public/javascripts/vendor/ajax_data_grid/editor.js",
    "public/javascripts/vendor/ajax_data_grid/text_editor.js",
    "public/stylesheets/sass/vendor/ajax_data_grid.sass",
    "rego-data-grid.gemspec",
    "spec/db/database.yml",
    "spec/db/schema.rb",
    "spec/db/schema_loader.rb",
    "spec/factories.rb",
    "spec/model_spec.rb",
    "spec/models/article.rb",
    "spec/rego-data-grid_spec.rb",
    "spec/spec_helper.rb"
  ]
  s.homepage = "http://github.com/alextk/rego-data-grid".freeze
  s.licenses = ["MIT".freeze]
  s.rubygems_version = "2.6.14".freeze
  s.summary = "Ajax data grid with pagination".freeze

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<logging>.freeze, [">= 1.6"])
      s.add_runtime_dependency(%q<will_paginate>.freeze, [">= 3.0.0"])
      s.add_runtime_dependency(%q<activesupport>.freeze, [">= 3.0.9"])
      s.add_development_dependency(%q<bundler>.freeze, [">= 0"])
      s.add_development_dependency(%q<jeweler>.freeze, [">= 0"])
      s.add_development_dependency(%q<database_cleaner>.freeze, [">= 0"])
    else
      s.add_dependency(%q<logging>.freeze, [">= 1.6"])
      s.add_dependency(%q<will_paginate>.freeze, [">= 3.0.0"])
      s.add_dependency(%q<activesupport>.freeze, [">= 3.0.9"])
      s.add_dependency(%q<bundler>.freeze, [">= 0"])
      s.add_dependency(%q<jeweler>.freeze, [">= 0"])
      s.add_dependency(%q<database_cleaner>.freeze, [">= 0"])
    end
  else
    s.add_dependency(%q<logging>.freeze, [">= 1.6"])
    s.add_dependency(%q<will_paginate>.freeze, [">= 3.0.0"])
    s.add_dependency(%q<activesupport>.freeze, [">= 3.0.9"])
    s.add_dependency(%q<bundler>.freeze, [">= 0"])
    s.add_dependency(%q<jeweler>.freeze, [">= 0"])
    s.add_dependency(%q<database_cleaner>.freeze, [">= 0"])
  end
end

