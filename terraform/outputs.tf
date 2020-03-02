output "b_hn_floatingip_address" {
  value = openstack_compute_floatingip_associate_v2.b_hn_floatingip_associate.floating_ip
}

output "b_wn_ip_address" {
    value = {
        for instance in openstack_compute_instance_v2.biocourse-worker:
            instance.name => instance.network[0].fixed_ip_v4
    }
}

output "b_wn1_floatingip_associate" {
  value = openstack_compute_floatingip_associate_v2.b_wn1_floatingip_associate.floating_ip
}

output "b_wn2_floatingip_associate" {
  value = openstack_compute_floatingip_associate_v2.b_wn2_floatingip_associate.floating_ip
}