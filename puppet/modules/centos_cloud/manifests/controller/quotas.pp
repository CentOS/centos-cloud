# == Class: centos_cloud::controller::quotas
#
# Configures the default project quotas.
# These default project quotas are based the flavors that are provisioned.
# We have the tiny, small and medium flavors.
# The quotas are based around being able to provide:
#   - 5 medium instances, or
#   - 10 small instances, or
#   - 20 tiny instances
#
# These defaults can be overridden per-project by an administrator.
#
# === Parameters:
#
# ## Nova
#
# [*instances*]
#   (optional) Max amount of instances per project.
#   Defaults to 20.
#
# [*cores*]
#   (optional) Max amount of vCPUs per project.
#   Defaults to 20.
#
# [*ram*]
#   (optional) Max amount of RAM per project.
#   Defaults to 40960MB.
#
# [*fixed_ips*]
#   (optional) Max amount of fixed IPs per project.
#   Defaults to 20 (number of instances)
#
# [*security_groups*]
#   (optional) Max amount of security groups per project.
#   Defaults to 0 (security groups are not enabled on this deployment)
#
# [*security_group_rules*]
#   (optional) Max amount of security group rules per project.
#   Defaults to 0 (security groups are not enabled on this deployment)
#
# ## Neutron
#
# [*ports*]
#   (optional) Max amount of ports per project.
#   Defaults to 20 (number of instances)
#
# [*network*]
#   (optional) Max amount of networks per project.
#   Defaults to 0 (projects are not allowed to create their own networks)
#
# [*subnet*]
#   (optional) Max amount of subnets per project.
#   Defaults to 0 (projects are not allowed to create their own subnets)
#
# [*network_gateway*]
#   (optional) Max amount of network gateways per project.
#   There are no L3 agents on this deployment, it uses flat provider networks.
#   Defaults to 0
#
# [*router*]
#   (optional) Max amount of routers per project.
#   There are no L3 agents on this deployment, it uses flat provider networks.
#   Defaults to 0
#
# [*floating_ip*]
#   (optional) Max amount of floating IPs per project.
#   There are no L3 agents on this deployment, it uses flat provider networks.
#   Defaults to 0
#
# ## Glance
#
# [*image_storage*]
#   (optional) Max size of image storage (images and snapshots) per project.
#   Defaults to '5GB'

class centos_cloud::controller::quotas (
  # Nova
  $instances            = 20,
  $cores                = 20,
  $ram                  = 40960,
  $fixed_ips            = 20,
  $security_groups      = 0,
  $security_group_rules = 0,
  # Neutron
  $ports                = 20,
  $network              = 0,
  $subnet               = 0,
  $network_gateway      = 0,
  $router               = 0,
  $floatingip           = 0,
  # Glance
  $image_storage        = '5GB'
){
  class { '::nova::quota':
    quota_instances            => $instances,
    quota_cores                => $cores,
    quota_ram                  => $ram,
    quota_fixed_ips            => $fixed_ips,
    quota_security_groups      => $security_groups,
    quota_security_group_rules => $security_group_rules,
  }

  class { '::neutron::quota':
    quota_ports           => $ports,
    quota_network         => $network,
    quota_subnet          => $subnet,
    quota_network_gateway => $network_gateway,
    quota_router          => $router,
    quota_floatingip      => $floatingip
  }

  glance_api_config { 'DEFAULT/user_storage_quota':
    value => $image_storage;
  }
}
