require File.expand_path(File.join(File.dirname(__FILE__), '..', 'spec_helper'))
require 'uuidtools'

describe BigRecord::Base do

  describe "#find" do

    it "should dispatch properly to #find_every when given :first" do
      zoo = Zoo.new

      Zoo.should_receive(:find_every).with(hash_including(:limit => 1)).and_return([zoo])

      Zoo.find(:first).should == zoo
    end

    it "should dispatch properly to #find_every when given :all" do
      zoo = Zoo.new

      Zoo.should_receive(:find_every).and_return([zoo])

      Zoo.find(:all).should == [zoo]
    end

    it "should dispatch properly to #find_from_ids when given anything else" do
      zoo = Zoo.new
      id = UUID.timestamp_create.to_s

      Zoo.should_receive(:find_from_ids).with([id], an_instance_of(Hash)).and_return([zoo])

      Zoo.find(id).should == [zoo]
    end

  end

end