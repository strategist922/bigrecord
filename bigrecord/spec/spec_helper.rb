require 'rubygems'
require 'spec'

bigrecord_driver_path = File.expand_path(File.dirname(__FILE__)+'/../../bigrecord-driver/lib')
$:.unshift(bigrecord_driver_path) if File.directory?(bigrecord_driver_path) && !$:.include?(bigrecord_driver_path)

SPEC_ROOT = File.expand_path(File.dirname(__FILE__))
require SPEC_ROOT + '/../lib/big_record'

if ENV["HBASE_REST_ADDRESS"]
  config = YAML::load(File.open(File.join(File.dirname(__FILE__), "connections", "bigrecord.yml")))
  config["hbase"]["api_address"] = ENV["HBASE_REST_ADDRESS"]
  BigRecord::Base.configurations = config
else
  BigRecord::Base.configurations = YAML::load(File.open(File.join(File.dirname(__FILE__), "connections", "bigrecord.yml")))
end
BigRecord::Base.logger = Logger.new(File.join(File.dirname(__FILE__), "debug.log"))

begin
  require 'connection'
rescue LoadError
  BigRecord::Base.logger.info "No data store defined. Using Hbase..."
  require File.join(File.dirname(__FILE__), 'connections', 'cassandra', 'connection')
end

# Load the various helpers for the spec suite
Dir.glob( File.join(File.dirname(__FILE__), "lib", "**", "*.rb") ).each do |model|
  require model
end


# Redefine the Hash class to include two helper methods used only in the specs.
class Hash
  # Helper method to determine if a hash is completely contained within other_hash (order is not important).
  # Matches each key/value pair, and returns false as soon as a mismatch occurs. The other_hash might have
  # more pairs, but those aren't considered.
  #
  #   hash1 = { :key1 => "value1", :key2 => "value2", :key3 => "value3" }
  #
  #   hash2 = { :key1 => "value1", :key2 => "value2", :key3 => "value3", :key4 => "value4" }
  #
  #   hash3 = { :key1 => "value4", :key2 => "value3", :key3 => "value1", :key4 => "value2" }
  #
  #   hash1.subset_of?(hash2) # => true
  #   hash2.subset_of?(hash1) # => false
  #   hash3.subset_of?(hash1) # => false
  #   hash3.subset_of?(hash2) # => false
  #
  def subset_of?(other_hash)
    self.each_pair do |key, value|
      return false if !other_hash.has_key?(key) || !(other_hash[key] == value)
    end

    true
  end

  def superset_of?(other_hash)
    other_hash.subset_of?(self)
  end

end
