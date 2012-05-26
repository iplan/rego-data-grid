# Generated by jeweler
# DO NOT EDIT THIS FILE DIRECTLY
# Instead, edit Jeweler::Tasks in Rakefile, and run 'rake gemspec'
# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = "rego-data-grid"
  s.version = "0.0.5"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Alex Tkachev"]
  s.date = "2012-05-26"
  s.description = "Ajax data grid with pagination"
  s.email = "tkachev.alex@gmail.com"
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
    "app/views/ajax_data_grid/_no_filter_results.html.haml",
    "app/views/ajax_data_grid/_table_row_create_error.html.haml",
    "app/views/ajax_data_grid/_table_row_destroy_error.html.haml",
    "config/locales/data_grid.en-US.yml",
    "config/locales/data_grid.he-IL.yml",
    "config/locales/will_paginate.en-US.yml",
    "config/locales/will_paginate.he-IL.yml",
    "lib/ajax_data_grid.rb",
    "lib/ajax_data_grid/builder.rb",
    "lib/ajax_data_grid/config.rb",
    "lib/ajax_data_grid/helpers.rb",
    "lib/ajax_data_grid/model.rb",
    "lib/ajax_data_grid/rails_engine.rb",
    "lib/ajax_data_grid/response_helpers.rb",
    "lib/ajax_data_grid/table_renderer.rb",
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
  s.homepage = "http://github.com/alextk/rego-data-grid"
  s.licenses = ["MIT"]
  s.require_paths = ["lib"]
  s.rubygems_version = "1.8.17"
  s.summary = "Ajax data grid with pagination"

  if s.respond_to? :specification_version then
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<will_paginate>, [">= 0"])
      s.add_development_dependency(%q<rdoc>, [">= 0"])
      s.add_development_dependency(%q<rspec>, [">= 0"])
      s.add_development_dependency(%q<bundler>, [">= 0"])
      s.add_development_dependency(%q<jeweler>, ["~> 1.8.3"])
      s.add_development_dependency(%q<rcov>, [">= 0"])
      s.add_development_dependency(%q<sqlite3>, [">= 0"])
      s.add_development_dependency(%q<factory_girl_rails>, [">= 0"])
      s.add_development_dependency(%q<database_cleaner>, [">= 0"])
    else
      s.add_dependency(%q<will_paginate>, [">= 0"])
      s.add_dependency(%q<rdoc>, [">= 0"])
      s.add_dependency(%q<rspec>, [">= 0"])
      s.add_dependency(%q<bundler>, [">= 0"])
      s.add_dependency(%q<jeweler>, ["~> 1.8.3"])
      s.add_dependency(%q<rcov>, [">= 0"])
      s.add_dependency(%q<sqlite3>, [">= 0"])
      s.add_dependency(%q<factory_girl_rails>, [">= 0"])
      s.add_dependency(%q<database_cleaner>, [">= 0"])
    end
  else
    s.add_dependency(%q<will_paginate>, [">= 0"])
    s.add_dependency(%q<rdoc>, [">= 0"])
    s.add_dependency(%q<rspec>, [">= 0"])
    s.add_dependency(%q<bundler>, [">= 0"])
    s.add_dependency(%q<jeweler>, ["~> 1.8.3"])
    s.add_dependency(%q<rcov>, [">= 0"])
    s.add_dependency(%q<sqlite3>, [">= 0"])
    s.add_dependency(%q<factory_girl_rails>, [">= 0"])
    s.add_dependency(%q<database_cleaner>, [">= 0"])
  end
end

