require 'chef/resource/lwrp_base'

class Chef
  class Resource
    class ConsulClusterServer < Chef::Resource::LWRPBase
      self.resource_name = :consul_cluster_server
      actions :create
      default_action :create

      attribute :datacenter, kind_of: String, name_attribute: true
      attribute :bootstrap_expect, kind_of: String, default: 3
      attribute :servers, kind_of: Array, required: true
      attribute :bind_interface, kind_of: String, default: 'eth1'
      attribute :serve_ui, equal_to: [true, false], default: true

      def bind_addr
        node['network']['interfaces']["#{bind_interface}"]['addresses']
          .detect{|k,v| v['family'] == 'inet' }.first
      end
    end
  end
end
