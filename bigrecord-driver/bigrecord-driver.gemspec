# Generated by jeweler
# DO NOT EDIT THIS FILE
# Instead, edit Jeweler::Tasks in Rakefile, and run `rake gemspec`
# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{bigrecord-driver}
  s.version = "0.0.4"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["openplaces.org"]
  s.date = %q{2009-10-14}
  s.default_executable = %q{hbase-driver}
  s.description = %q{Bigrecord drivers that use JRuby DRb servers to connect with databases through their native Java APIs. Currently supported databases are HBase and Cassandra.}
  s.email = %q{bigrecord@openplaces.org}
  s.executables = ["hbase-driver", "cassandra-driver", "launcher"]
  s.extra_rdoc_files = [
    "MIT-LICENSE",
     "README.rdoc"
  ]
  s.files = [
    "MIT-LICENSE",
     "README.rdoc",
     "VERSION",
     "bin/cassandra-driver",
     "bin/hbase-driver",
     "bin/launcher",
     "conf/log4j.properties",
     "lib/big_record_driver.rb",
     "lib/big_record_driver/bigrecord_server.rb",
     "lib/big_record_driver/cassandra_driver/server.rb",
     "lib/big_record_driver/client.rb",
     "lib/big_record_driver/column_descriptor.rb",
     "lib/big_record_driver/driver_manager.rb",
     "lib/big_record_driver/exceptions.rb",
     "lib/big_record_driver/hbase_driver/server.rb",
     "lib/bigrecord_driver.rb",
     "test/abstract_test_client.rb",
     "test/test_client_cassandra.rb",
     "test/test_client_hbase.rb",
     "test/test_driver_manager.rb",
     "vendor/java/cassandra/cassandra-0.3.0-dev.jar",
     "vendor/java/cassandra/libthrift.jar",
     "vendor/java/cassandra/log4j-1.2.15.jar",
     "vendor/java/hbase/commons-logging-1.0.4.jar",
     "vendor/java/hbase/commons-logging-api-1.0.4.jar",
     "vendor/java/hbase/hadoop-0.20.1-core.jar",
     "vendor/java/hbase/hbase-0.20.1.jar",
     "vendor/java/hbase/log4j-1.2.13.jar",
     "vendor/java/hbase/zookeeper-3.2.1.jar"
  ]
  s.homepage = %q{http://www.bigrecord.org}
  s.rdoc_options = ["--charset=UTF-8"]
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.3.5}
  s.summary = %q{Bigrecord drivers implemented as JRuby DRb servers}

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
    else
    end
  else
  end
end
