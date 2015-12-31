#
# Cookbook Name:: rackspace
# Provider:: cloudfile
# Author:: Julian C. Dunn (<jdunn@opscode.com>)
#
# Copyright 2013, Opscode, Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

require 'tempfile'
require 'chef/digester'

include Opscode::Rackspace::Storage

def whyrun_supported?
  true
end

def load_current_resource
  @current_resource = Chef::Resource::RackspacecloudFile.new(@new_resource.name)
  @current_resource.filename(@new_resource.filename)

  if ::File.exist?(@current_resource.filename)
    @current_resource.exists = true
    @current_resource.checksum = Chef::Digester.generate_md5_checksum_for_file(@current_resource.filename)
  else
    @current_resource.exists = false
  end
  @current_resource
end

action :create do
  f = Tempfile.new('download')

  if new_resource.binmode
    f.binmode
  end

  directory = get_directory(new_resource.directory)
  if new_resource.cloudfile_uri
    cloudfile_uri = new_resource.cloudfile_uri
  else
    cloudfile_uri = ::File.basename(new_resource.filename)
  end

  directory.files.get(cloudfile_uri) do |data, remaining, content_length|
    f.syswrite data
  end

  new_resource.checksum = Chef::Digester.generate_md5_checksum_for_file(f.path)
  if !current_resource.exists || (current_resource.checksum != new_resource.checksum)
    converge_by("Moving new file with checksum to #{new_resource.filename}") do
      move_file(f.path, new_resource.filename)
    end
  else
    f.unlink
  end
end

action :create_if_missing do # ~FC017
  unless current_resource.exists
    action_create
  end
end

action :upload do
  if current_resource.exists
    # Use md5 checksums because CloudFiles etag is md5
    new_resource.checksum = Chef::Digester.generate_md5_checksum_for_file(new_resource.filename)
    directory = get_directory(new_resource.directory)

    if new_resource.cloudfile_uri
      cloudfile_uri = new_resource.cloudfile_uri
    else
      cloudfile_uri = ::File.basename(new_resource.filename)
    end

    remote_file = directory.files.get(cloudfile_uri)
    if remote_file.nil? || remote_file.etag != new_resource.checksum
      converge_by("Uploading new file #{::File.basename(new_resource.filename)} with
       checksum #{new_resource.checksum} to #{new_resource.directory} container") do
        directory.files.create key: cloudfile_uri,
                               body: ::File.open(new_resource.filename)
      end
    end
  end
end

private

def get_directory(n)
  storage.directories.get(n)
end

# Defining custom method to work around EACCESS errors on Windows when attempting to move across devices.
# Attrib to tknerr for workaround found in Berkshelf issue #140
def move_file(src, dest)
  FileUtils.mv(src, dest, force: false)
rescue Errno::EACCES
  FileUtils.cp_r(src, dest)
  FileUtils.rm_rf(src)
end
