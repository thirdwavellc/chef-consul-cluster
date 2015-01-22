require 'chef/provider/lwrp_base'

class Chef
  class Provider
    class ConsulClusterClient < Chef::Provider::LWRPBase
      include Chef::DSL::IncludeRecipe
      use_inline_resources if defined?(use_inline_resources)

      def whyrun_supported?
        true
      end

      action :create do
        node.normal['consul']['service_mode'] = 'client'
        node.normal['consul']['service_user'] = 'root'
        node.normal['consul']['service_group'] = 'root'
        node.normal['consul']['servers'] = new_resource.servers
        node.normal['consul']['bind_interface'] = new_resource.bind_interface
        node.normal['consul']['bind_addr'] = new_resource.bind_addr
        node.normal['consul']['datacenter'] = new_resource.datacenter

        if new_resource.acl_datacenter
          node.normal['consul']['acl_datacenter'] = new_resource.acl_datacenter
        end

        if new_resource.acl_token
          node.normal['consul']['acl_token'] = new_resource.acl_token
        end

        include_recipe 'consul::default'

        package 'dnsmasq' do
          action :install
        end

        service 'dnsmasq' do
          action :start
        end

        file '/etc/dnsmasq.d/dnsmasq.conf' do
          content "server=/consul/127.0.0.1##{node['consul']['ports']['dns']}"
          notifies :restart, "service[dnsmasq]", :immediately
        end

        include_recipe 'consul-services::dnsmasq'
      end
    end
  end
end
