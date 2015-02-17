#
# Cookbook:: consul-cluster
# Resource:: consul_cluster_client
#
# Copyright 2014 Adam Krone <adam.krone@thirdwavellc.com>
# Copyright 2014 Thirdwave, LLC
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

require 'chef/resource/lwrp_base'

class Chef
  class Resource
    class ConsulClusterClient < Chef::Resource::LWRPBase
      self.resource_name = :consul_cluster_client
      actions :create
      default_action :create

      attribute :datacenter, kind_of: String, name_attribute: true
      attribute :servers, kind_of: Array, required: true
      attribute :acl_datacenter, kind_of: String, default: nil
      attribute :acl_token, kind_of: String, default: nil
      attribute :bind_interface, kind_of: String, default: 'eth1'

      def bind_addr
        node['network']['interfaces']["#{bind_interface}"]['addresses']
          .detect{|k,v| v['family'] == 'inet' }.first
      end
    end
  end
end
