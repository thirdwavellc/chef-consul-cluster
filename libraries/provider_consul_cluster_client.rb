#
# Cookbook:: consul-cluster
# Provider:: consul_cluster_client
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

require 'chef/provider/lwrp_base'

class Chef
  class Provider
    class ConsulClusterClient < Chef::Provider::LWRPBase
      include Chef::DSL::IncludeRecipe
      use_inline_resources if defined?(use_inline_resources)
      provides :consul_cluster_client

      def whyrun_supported?
        true
      end

      action :create do
        node.normal['consul']['config']['start_join'] = new_resource.servers
        node.normal['consul']['bind_interface'] = new_resource.bind_interface
        unless node['consul']['config']['bind_addr']
          node.normal['consul']['config']['bind_addr'] = new_resource.bind_addr
        end
        node.normal['consul']['config']['datacenter'] = new_resource.datacenter

        if new_resource.acl_datacenter
          node.normal['consul']['config']['acl_datacenter'] = new_resource.acl_datacenter
        end

        if new_resource.acl_token
          node.normal['consul']['config']['acl_token'] = new_resource.acl_token
        end

        include_recipe 'consul::default'

        package 'dnsmasq' do
          action :install
        end

        service 'dnsmasq' do
          action :start
        end

        file '/etc/dnsmasq.d/dnsmasq.conf' do
          content "server=/consul/127.0.0.1##{node['consul']['config']['ports']['dns']}"
          notifies :restart, "service[dnsmasq]", :immediately
        end

        include_recipe 'consul-services::dnsmasq'
      end
    end
  end
end
