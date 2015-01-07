require 'chef/resource/lwrp_base'

class Chef
  class Resource
    class ConsulClusterClient < Chef::Resource::LWRPBase
      self.resource_name = :consul_cluster_client
      actions :create
      default_action :create

      attribute :datacenter, kind_of: String, name_attribute: true
      attribute :servers, kind_of: Array, required: true
      attribute :bind_interface, kind_of: String, default: 'eth1'

      def bind_addr
        node['network']['interfaces']["#{bind_interface}"]['addresses']
          .detect{|k,v| v['family'] == 'inet' }.first
      end
    end
  end
end
