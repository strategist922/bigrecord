# Generated by jeweler
# DO NOT EDIT THIS FILE DIRECTLY
# Instead, edit Jeweler::Tasks in Rakefile, and run the gemspec command
# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{bigrecord}
  s.version = "0.1.1"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["openplaces.org"]
  s.date = %q{2010-05-05}
  s.description = %q{BigRecord is built from ActiveRecord, and intended to seamlessly integrate into your Ruby on Rails applications.}
  s.email = %q{bigrecord@openplaces.org}
  s.extra_rdoc_files = [
    "LICENSE",
     "README.rdoc",
     "guides/bigrecord_specs.rdoc",
     "guides/cassandra_install.rdoc",
     "guides/deployment.rdoc",
     "guides/getting_started.rdoc",
     "guides/hbase_install.rdoc",
     "guides/storage-conf.rdoc"
  ]
  s.files = [
    "Rakefile",
     "VERSION",
     "examples/bigrecord.yml",
     "generators/bigrecord/bigrecord_generator.rb",
     "generators/bigrecord/templates/bigrecord.rake",
     "generators/bigrecord_migration/bigrecord_migration_generator.rb",
     "generators/bigrecord_migration/templates/migration.rb",
     "generators/bigrecord_model/bigrecord_model_generator.rb",
     "generators/bigrecord_model/templates/migration.rb",
     "generators/bigrecord_model/templates/model.rb",
     "generators/bigrecord_model/templates/model_spec.rb",
     "guides/bigrecord_specs.rdoc",
     "guides/cassandra_install.rdoc",
     "guides/deployment.rdoc",
     "guides/getting_started.rdoc",
     "guides/hbase_install.rdoc",
     "guides/storage-conf.rdoc",
     "init.rb",
     "install.rb",
     "lib/big_record.rb",
     "lib/big_record/action_view_extensions.rb",
     "lib/big_record/ar_associations.rb",
     "lib/big_record/ar_associations/association_collection.rb",
     "lib/big_record/ar_associations/association_proxy.rb",
     "lib/big_record/ar_associations/belongs_to_association.rb",
     "lib/big_record/ar_associations/belongs_to_many_association.rb",
     "lib/big_record/ar_associations/has_and_belongs_to_many_association.rb",
     "lib/big_record/ar_associations/has_many_association.rb",
     "lib/big_record/ar_associations/has_one_association.rb",
     "lib/big_record/ar_reflection.rb",
     "lib/big_record/attribute_methods.rb",
     "lib/big_record/base.rb",
     "lib/big_record/br_associations.rb",
     "lib/big_record/br_associations/association_collection.rb",
     "lib/big_record/br_associations/association_proxy.rb",
     "lib/big_record/br_associations/belongs_to_association.rb",
     "lib/big_record/br_associations/belongs_to_many_association.rb",
     "lib/big_record/br_associations/cached_item_proxy.rb",
     "lib/big_record/br_associations/cached_item_proxy_factory.rb",
     "lib/big_record/br_associations/has_and_belongs_to_many_association.rb",
     "lib/big_record/br_associations/has_one_association.rb",
     "lib/big_record/br_reflection.rb",
     "lib/big_record/callbacks.rb",
     "lib/big_record/connection_adapters.rb",
     "lib/big_record/connection_adapters/abstract/connection_specification.rb",
     "lib/big_record/connection_adapters/abstract/database_statements.rb",
     "lib/big_record/connection_adapters/abstract/quoting.rb",
     "lib/big_record/connection_adapters/abstract_adapter.rb",
     "lib/big_record/connection_adapters/cassandra_adapter.rb",
     "lib/big_record/connection_adapters/column.rb",
     "lib/big_record/connection_adapters/hbase_adapter.rb",
     "lib/big_record/connection_adapters/hbase_rest_adapter.rb",
     "lib/big_record/connection_adapters/view.rb",
     "lib/big_record/deletion.rb",
     "lib/big_record/dynamic_schema.rb",
     "lib/big_record/embedded.rb",
     "lib/big_record/embedded_associations/association_proxy.rb",
     "lib/big_record/family_span_columns.rb",
     "lib/big_record/fixtures.rb",
     "lib/big_record/migration.rb",
     "lib/big_record/model.rb",
     "lib/big_record/routing_ext.rb",
     "lib/big_record/timestamp.rb",
     "lib/big_record/validations.rb",
     "lib/big_record/version.rb",
     "lib/bigrecord.rb",
     "rails/init.rb",
     "spec/adapter_benchmark.rb",
     "spec/connections/bigrecord.yml",
     "spec/connections/cassandra/connection.rb",
     "spec/connections/hbase/connection.rb",
     "spec/integration/br_associations_spec.rb",
     "spec/lib/animal.rb",
     "spec/lib/book.rb",
     "spec/lib/broken_migrations/duplicate_name/20090706182535_add_animals_table.rb",
     "spec/lib/broken_migrations/duplicate_name/20090706193019_add_animals_table.rb",
     "spec/lib/broken_migrations/duplicate_version/20090706190623_add_books_table.rb",
     "spec/lib/broken_migrations/duplicate_version/20090706190623_add_companies_table.rb",
     "spec/lib/company.rb",
     "spec/lib/embedded/web_link.rb",
     "spec/lib/employee.rb",
     "spec/lib/migrations/20090706182535_add_animals_table.rb",
     "spec/lib/migrations/20090706190623_add_books_table.rb",
     "spec/lib/migrations/20090706193019_add_companies_table.rb",
     "spec/lib/migrations/20090706194512_add_employees_table.rb",
     "spec/lib/migrations/20090706195741_add_zoos_table.rb",
     "spec/lib/novel.rb",
     "spec/lib/zoo.rb",
     "spec/spec.opts",
     "spec/spec_helper.rb",
     "spec/unit/adapters/abstract_adapter_spec.rb",
     "spec/unit/adapters/adapter_shared_spec.rb",
     "spec/unit/adapters/hbase_adapter_spec.rb",
     "spec/unit/ar_associations_spec.rb",
     "spec/unit/attributes_spec.rb",
     "spec/unit/br_associations_spec.rb",
     "spec/unit/columns_spec.rb",
     "spec/unit/deletion_spec.rb",
     "spec/unit/embedded_spec.rb",
     "spec/unit/find_spec.rb",
     "spec/unit/hash_helper_spec.rb",
     "spec/unit/migration_spec.rb",
     "spec/unit/model_spec.rb",
     "spec/unit/scanner_spec.rb",
     "spec/unit/validations_spec.rb",
     "tasks/bigrecord_tasks.rake",
     "tasks/data_store.rb",
     "tasks/gem.rb",
     "tasks/rdoc.rb",
     "tasks/spec.rb"
  ]
  s.homepage = %q{http://www.bigrecord.org}
  s.rdoc_options = ["--charset=UTF-8"]
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.3.6}
  s.summary = %q{Object mapper for supporting column-oriented data stores (supports hbase, cassandra) in Ruby on Rails.}

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
      s.add_development_dependency(%q<rspec>, [">= 0"])
      s.add_runtime_dependency(%q<uuidtools>, [">= 2.0.0"])
      s.add_runtime_dependency(%q<activesupport>, [">= 0"])
      s.add_runtime_dependency(%q<activerecord>, [">= 0"])
    else
      s.add_dependency(%q<rspec>, [">= 0"])
      s.add_dependency(%q<uuidtools>, [">= 2.0.0"])
      s.add_dependency(%q<activesupport>, [">= 0"])
      s.add_dependency(%q<activerecord>, [">= 0"])
    end
  else
    s.add_dependency(%q<rspec>, [">= 0"])
    s.add_dependency(%q<uuidtools>, [">= 2.0.0"])
    s.add_dependency(%q<activesupport>, [">= 0"])
    s.add_dependency(%q<activerecord>, [">= 0"])
  end
end

