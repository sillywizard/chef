#
# Author:: Adam Jacob (<adam@opscode.com>)
# Copyright:: Copyright (c) 2008 Opscode, Inc.
# License:: Apache License, Version 2.0
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
# 
#     http://www.apache.org/licenses/LICENSE-2.0
# 
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

require File.expand_path(File.join(File.dirname(__FILE__), "..", "spec_helper"))

describe Chef::Platform do
  before(:each) do
    Chef::Platform.platforms = {
      :darwin => {
        "9.2.2" => {
          :file => "darwinian",
          :else => "thing"
        },
        :default => {
          :file => "old school",
          :snicker => "snack"
        }
      },
      :mars_volta => {
      },
      :default => {
        :file => Chef::Provider::File,
        :pax => "brittania",
        :cat => "nice"
      }
    }
  end
  
  it "should allow you to look up a platform by name and version, returning the provider map for it" do
    pmap = Chef::Platform.find("Darwin", "9.2.2")
    pmap.should be_a_kind_of(Hash)
    pmap[:file].should eql("darwinian")
  end
  
  it "should use the default providers for an os if the specific version does not exist" do
    pmap = Chef::Platform.find("Darwin", "1")
    pmap.should be_a_kind_of(Hash)
    pmap[:file].should eql("old school")
  end
  
  it "should use the default providers if the os doesn't give me a default, but does exist" do
    pmap = Chef::Platform.find("mars_volta", "1")
    pmap.should be_a_kind_of(Hash)
    pmap[:file].should eql(Chef::Provider::File)
  end
  
  it "should use the default provider if the os does not exist" do
    pmap = Chef::Platform.find("AIX", "1")
    pmap.should be_a_kind_of(Hash)
    pmap[:file].should eql(Chef::Provider::File)
  end
  
  it "should merge the defaults for an os with the specific version" do
    pmap = Chef::Platform.find("Darwin", "9.2.2")
    pmap[:file].should eql("darwinian")
    pmap[:snicker].should eql("snack")
  end
  
  it "should merge the defaults for an os with the universal defaults" do
    pmap = Chef::Platform.find("Darwin", "9.2.2")
    pmap[:file].should eql("darwinian")
    pmap[:pax].should eql("brittania")
  end
  
  it "should allow you to look up a provider for a platform directly by symbol" do
    Chef::Platform.find_provider("Darwin", "9.2.2", :file).should eql("darwinian")
  end
  
  it "should raise an exception if a provider cannot be found for a resource type" do
    lambda { Chef::Platform.find_provider("Darwin", "9.2.2", :coffee) }.should raise_error(ArgumentError)
  end
  
  it "should look up a provider for a resource with a Chef::Resource object" do
    kitty = Chef::Resource::Cat.new("loulou")
    Chef::Platform.find_provider("Darwin", "9.2.2", kitty)
  end
  
  it "should look up a provider with a node and a Chef::Resource object" do
    kitty = Chef::Resource::Cat.new("loulou")    
    node = Chef::Node.new
    node.name("Intel")
    node.platform("mac_os_x")
    node.platform_version("9.2.2")
    Chef::Platform.find_provider_for_node(node, kitty).should eql("nice")
  end
  
  it "should update the provider map with map" do  
    Chef::Platform.set(
         :platform => :darwin,
         :version => "9.2.2",
         :resource => :file, 
         :provider => "masterful"
    )
    Chef::Platform.platforms[:darwin]["9.2.2"][:file].should eql("masterful")
    Chef::Platform.set(
         :platform => :darwin,
         :resource => :file,
         :provider => "masterful" 
    )
    Chef::Platform.platforms[:darwin][:default][:file].should eql("masterful")
    Chef::Platform.set(
         :resource => :file, 
         :provider => "masterful"
    )   
    Chef::Platform.platforms[:default][:file].should eql("masterful")
    
    Chef::Platform.set(
         :platform => :hero,
         :version => "9.2.2",
         :resource => :file, 
         :provider => "masterful"
    )
    Chef::Platform.platforms[:hero]["9.2.2"][:file].should eql("masterful")
    
    Chef::Platform.set(
         :resource => :file, 
         :provider => "masterful"
    )
    Chef::Platform.platforms[:default][:file].should eql("masterful")
    
    Chef::Platform.platforms = {}
    
    Chef::Platform.set(
         :resource => :file, 
         :provider => "masterful"
    )
    Chef::Platform.platforms[:default][:file].should eql("masterful")
    
  end
  
  
end