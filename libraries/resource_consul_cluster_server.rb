#
# Cookbook:: consul-cluster
# Resource:: consul_cluster_server
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
    class ConsulClusterServer < Chef::Resource::LWRPBase
      self.resource_name = :consul_cluster_server
      actions :create
      default_action :create

      attribute :datacenter, kind_of: String, name_attribute: true
      attribute :bootstrap_expect, kind_of: Integer, default: 3
      attribute :servers, kind_of: Array, required: true
      attribute :bind_interface, kind_of: String, default: 'eth1'
      attribute :serve_ui, equal_to: [true, false], default: true
      attribute :acl_datacenter, kind_of: String, default: nil
      attribute :acl_default_policy, equal_to: ['allow', 'deny', nil], default: nil
      attribute :acl_master_token, kind_of: String, default: nil
      attribute :include_consul_alerts, equal_to: [true, false], default: true

      def bind_addr
        addresses = node['network']['interfaces']["#{bind_interface}"]['addresses']
                      .detect{|k,v| v['family'] == 'inet' } & servers
        unless addresses.length
          Chef::Application.fatal("Servers attribute must include an address assigned to this machine")
        end
        addresses.first # The array should really only be one item anyways
      end
    end
  end
end
