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

        include_recipe 'consul::default'

        package 'dnsmasq' do
          action :install
        end

        service 'dnsmasq' do
          action :start
        end

        file '/etc/dnsmasq.conf' do
          content "server=/consul/127.0.0.1##{node['consul']['ports']['dns']}"
          notifies :reload, "service[dnsmasq]", :immediately
        end
      end
    end
  end
end
