require 'chef/provider/lwrp_base'

class Chef
  class Provider
    class ConsulClusterServer < Chef::Provider::LWRPBase
      include Chef::DSL::IncludeRecipe
      use_inline_resources if defined?(use_inline_resources)

      def whyrun_supported?
        true
      end

      action :create do
        node.normal['consul']['service_mode'] = 'cluster'
        node.normal['consul']['bootstrap_expect'] = new_resource.bootstrap_expect
        node.normal['consul']['servers'] = new_resource.servers
        node.normal['consul']['bind_interface'] = new_resource.bind_interface
        node.normal['consul']['bind_addr'] = new_resource.bind_addr
        node.normal['consul']['datacenter'] = new_resource.datacenter
        node.normal['consul']['serve_ui'] = new_resource.serve_ui

        if new_resource.acl_datacenter
          node.normal['consul']['acl_datacenter'] = new_resource.acl_datacenter
        end

        if new_resource.acl_default_policy
          node.normal['consul']['acl_default_policy'] = new_resource.acl_default_policy
        end

        if new_resource.acl_master_token
          node.normal['consul']['acl_master_token'] = new_resource.acl_master_token
        end

        include_recipe 'consul::default'
        include_recipe 'consul::ui' if new_resource.serve_ui

        package 'dnsmasq' do
          action :install
        end

        service 'dnsmasq' do
          action :start
        end

        file '/etc/dnsmasq.d/dnsmasq.conf' do
          content "server=/consul/127.0.0.1##{node['consul']['ports']['dns']}"
          notifies :reload, "service[dnsmasq]", :immediately
        end
      end
    end
  end
end
