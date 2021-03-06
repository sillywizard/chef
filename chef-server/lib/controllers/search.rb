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

require 'chef' / 'search'
require 'chef' / 'queue'

class Search < Application
  
  provides :html, :json
    
  def index
    @s = Chef::Search.new
    @search_indexes = @s.list_indexes
    display @search_indexes
  end

  def show
    @s = Chef::Search.new
    @results = nil
    if params[:q]
      @results = @s.search(params[:id], params[:q] == "" ? "?*" : params[:q])
    else
      @results = @s.search(params[:id], "?*")
    end
    # Boy, this should move to the search function
    if params[:a]
      attributes = params[:a].split(",").collect { |a| a.to_sym }
      unless attributes.length == 0
        @results = @results.collect do |r|
          nr = Hash.new
          nr[:index_name] = r[:index_name]
          nr[:id] = r[:id]
          attributes.each do |attrib|
            if r.has_key?(attrib)
              nr[attrib] = r[attrib]
            end
          end
          nr
        end
      end
    end
    display @results
  end

  def destroy
    @s = Chef::Search.new
    @entries = @s.search(params[:id], "?*")
    @entries.each do |entry|
      Chef::Queue.send_msg(:queue, :remove, entry)
    end
    @status = 202
    if content_type == :html
      redirect url(:search)
    else
      display @entries
    end
  end
  
end
