# consul-cluster

Installs and configures consul for both server and client, as well as Dnsmasq
configured to use consul. This is a wrapper cookbook, primarily intended for
use in Thirdwave environments, and therefore makes some assumptions.

## LWRPs

This cookbook is intended to be consumed through its LWRPs, and therefore
doesn't include any recipes. Here is an overview of the LWRPs provided:

### consul_cluster_client

**Attributes:**

| Name           | Description                                 | Type   | Required | Default |
| -------------- | ------------------------------------------- | ------ | -------- | ------- |
| datacenter     | Consul datacenter to join                   | String | true     | N/A     |
| servers        | Consul servers to join                      | Array  | true     | N/A     |
| bind_interface | Interface to bind consul to                 | String | false    | 'eth1'  |
| acl_datacenter | Datacenter responsible for managing the ACL | String | false    | nil     |
| acl_token      | Token for ACL authentication                | String | false    | nil     |

**Example:**

```ruby
consul_cluster_client 'dc01' do
  servers ['192.168.10.1', '192.168.10.2', '192.168.10.3']
  bind_interface 'eth0'
end
```

### consul_cluster_server

**Attributes:**

| Name                  | Description                                                            | Type    | Required | Default |
| --------------------- | --------------------------------------------------------------------   | ------- | -------- | ------- |
| datacenter            | Consul datacenter to join                                              | String  | true     | N/A     |
| bootstrap_expect      | How many server to expect before bootstrapping                         | String  | false    | 3       |
| servers               | Consul server to join                                                  | Array   | true     | N/A     |
| bind_interface        | Interface to bind consul to                                            | String  | false    | 'eth1'  |
| serve_ui              | Whether or not to serve up the consul ui                               | Boolean | false    | true    |
| acl_datacenter        | Datacenter responsible for managing the ACL                            | String  | false    | nil     |
| acl_default_policy    | Default ACL policy for consul to follow                                | String  | false    | nil     |
| acl_master_token      | Master token for ACL authentication                                    | String  | false    | nil     |
| include_consul_alerts | Whether or not to include consul_alerts for alerting on consul changes | Boolean | false    | true    |

**Example:**

```ruby
consul_cluster_server 'dc01' do
  servers ['192.168.10.1', '192.168.10.2', '192.168.10.3', '192.168.10.4', '192.168.10.5']
  bind_interface 'eth0'
  include_consul_alerts false
end
```
