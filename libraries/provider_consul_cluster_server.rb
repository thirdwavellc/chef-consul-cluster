#
# Cookbook:: consul-cluster
# Provider:: consul_cluster_server
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
    class ConsulClusterServer < Chef::Provider::LWRPBase
      include Chef::DSL::IncludeRecipe
      use_inline_resources if defined?(use_inline_resources)
      provides :consul_cluster_server

      def whyrun_supported?
        true
      end

      action :create do
        node.normal['consul']['config']['server'] = true
        node.normal['consul']['config']['bootstrap_expect'] = new_resource.bootstrap_expect
        node.normal['consul']['config']['retry_join'] = new_resource.servers
        node.normal['consul']['bind_interface'] = new_resource.bind_interface
        unless node['consul']['config']['bind_addr']
          node.normal['consul']['config']['bind_addr'] = new_resource.bind_addr
        end
        node.normal['consul']['config']['datacenter'] = new_resource.datacenter

        if new_resource.serve_ui
          node.normal['consul']['config']['ui'] = new_resource.serve_ui
        end

        if new_resource.acl_datacenter
          node.normal['consul']['config']['acl_datacenter'] = new_resource.acl_datacenter
        end

        if new_resource.acl_default_policy
          node.normal['consul']['config']['acl_default_policy'] = new_resource.acl_default_policy
        end

        if new_resource.acl_master_token
          node.normal['consul']['config']['acl_master_token'] = new_resource.acl_master_token
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
          notifies :reload, "service[dnsmasq]", :immediately
        end

        include_recipe 'consul-services::dnsmasq'
        include_recipe 'consul-services::consul-ui' if new_resource.serve_ui

        if new_resource.include_consul_alerts
          node.normal['consul_alerts']['consul_dc'] = new_resource.datacenter
          node.normal['consul_alerts']['consul_addr'] = "#{node['consul']['config']['bind_addr']}:#{node['consul']['config']['ports']['http']}"

          include_recipe 'consul-alerts::default'
          include_recipe 'consul-services::consul-alerts'
        end
      end
    end
  end
end
