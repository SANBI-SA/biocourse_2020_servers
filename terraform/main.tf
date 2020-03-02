resource "openstack_compute_instance_v2" "biocourse-headnode" {
  name        = "biocourse-headnode"
  flavor_name = "m1.xlarge"
  key_pair    = "pvhebmkey"
  image_name  = "ubuntu-18.04-server"
  security_groups = [
    "public_server_secgroup",
    "slurm_controller_secgroup",
    "slurm_submit_secgroup",
    "nfs_server_secgroup"
  ]

  network {
    name = "masters_net_1"
  }

  network {
    name = "ceph-net"
  }

  # provisioner "local-exec" {
  #   command = "python ~/terraform/dns/update_dns.py -a -n ${self.name} -i ${openstack_compute_floatingip_v2.nextcloud_fip.address}"
  # }

  # provisioner "local-exec" {
  #   command = "python ~/terraform/dns/update_dns.py -r -n ${self.name}"
  #   when = "destroy"
  # }  
}

resource "openstack_compute_instance_v2" "biocourse-worker" {
  count = var.worker_count
  name        = "biocourse-worker-${count.index}"
  flavor_name = "m1.xlarge"
  key_pair    = "pvhebmkey"
  image_name  = "ubuntu-18.04-server"
  security_groups = [
    "ssh_secgroup",
    "slurm_worker_secgroup"
  ]

  network {
    name = "masters_net_1"
  }
  
  network {
    name = "ceph-net"
  }

  # provisioner "local-exec" {
  #   command = "python ~/terraform/dns/update_dns.py -a -n ${self.name} -i ${openstack_compute_floatingip_v2.nextcloud_fip.address}"
  # }

  # provisioner "local-exec" {
  #   command = "python ~/terraform/dns/update_dns.py -r -n ${self.name}"
  #   when = "destroy"
  # }  
}

resource "openstack_compute_keypair_v2" "pvhebmkey" {
  name = "pvhebmkey"
}

resource "openstack_compute_floatingip_associate_v2" "b_hn_floatingip_associate" {
  floating_ip = openstack_compute_floatingip_v2.b_hn_floatingip.address
  instance_id = openstack_compute_instance_v2.biocourse-headnode.id
}

resource "openstack_compute_floatingip_associate_v2" "b_wn1_floatingip_associate" {
  floating_ip = openstack_compute_floatingip_v2.b_wn1_floatingip.address
  instance_id = openstack_compute_instance_v2.biocourse-worker[0].id
}

resource "openstack_compute_floatingip_associate_v2" "b_wn2_floatingip_associate" {
  floating_ip = openstack_compute_floatingip_v2.b_wn2_floatingip.address
  instance_id = openstack_compute_instance_v2.biocourse-worker[1].id
}

resource "openstack_blockstorage_volume_v2" "b_hn_store" {
  name = "b_hn_store"
  size = 160
}

resource "openstack_compute_volume_attach_v2" "b_hn_store_attach" {
  instance_id = openstack_compute_instance_v2.biocourse-headnode.id
  volume_id = openstack_blockstorage_volume_v2.b_hn_store.id
}

resource "openstack_compute_floatingip_v2" "b_hn_floatingip" {
  pool = "public1"
}

resource "openstack_compute_floatingip_v2" "b_wn1_floatingip" {
  pool = "public1"
}

resource "openstack_compute_floatingip_v2" "b_wn2_floatingip" {
  pool = "public1"
}

resource "openstack_compute_secgroup_v2" "public_server_secgroup" {
  name = "public_server_secgroup"
  description = "public server security group: SSH and HTTP/S"

  # rule {
  #   from_port = 0
  #   to_port   = 0
  #   ip_protocol = "tcp"
  #   self      = true
  # }

  # rule {
  #   from_port = -1
  #   to_port = -1
  #   ip_protocol = "icmp"
  #   cidr = "0.0.0.0/0"
  # }

  rule {
    from_port   = 22
    to_port     = 22
    ip_protocol = "tcp"
    cidr        = "0.0.0.0/0"
  }

  rule {
    from_port   = 80
    to_port     = 80
    ip_protocol = "tcp"
    cidr        = "0.0.0.0/0"
  }

  rule {
    from_port   = 443
    to_port     = 443
    ip_protocol = "tcp"
    cidr        = "0.0.0.0/0"
  }
}

resource "openstack_compute_secgroup_v2" "ssh_secgroup" {
  name = "ssh_secgroup"
  description = "ssh server security group: SSH and HTTP/S"

  rule {
    from_port   = 22
    to_port     = 22
    ip_protocol = "tcp"
    cidr        = "0.0.0.0/0"
  }
}

resource "openstack_compute_secgroup_v2" "slurm_controller_secgroup" {
  name = "slurm_controller_secgroup"
  description = "slurm controller server security group: slurmctld(6817)"

  rule {
    from_port   = 6817
    to_port     = 6817
    ip_protocol = "tcp"
    cidr        = "0.0.0.0/0"
  }
}

resource "openstack_compute_secgroup_v2" "slurm_worker_secgroup" {
  name = "slurm_worker_secgroup"
  description = "slurm worker node security group: slurmd(6818)"

  rule {
    from_port   = 6818
    to_port     = 6818
    ip_protocol = "tcp"
    cidr        = "0.0.0.0/0"
  }
}

resource "openstack_compute_secgroup_v2" "slurm_submit_secgroup" {
  name = "slurm_submit_secgroup"
  description = "slurm submit host security group: SrunPortRange (60000-61000)"

  rule {
    from_port   = 60000
    to_port     = 61000
    ip_protocol = "tcp"
    cidr        = "0.0.0.0/0"
  }
}

resource "openstack_compute_secgroup_v2" "nfs_server_secgroup" {
  name = "nfs_server_secgroup"
  description = "NFS server host security group: As per https://serverfault.com/questioans/377170/which-ports-do-i-need-to-open-in-the-firewall-to-use-nfs"

  rule {
    from_port   = 111
    to_port     = 111
    ip_protocol = "tcp"
    cidr        = "0.0.0.0/0"
  }

  rule {
    from_port   = 111
    to_port     = 111
    ip_protocol = "udp"
    cidr        = "0.0.0.0/0"
  }

  rule {
    from_port   = 2049
    to_port     = 2049
    ip_protocol = "tcp"
    cidr        = "0.0.0.0/0"
  }

  rule {
    from_port   = 2049
    to_port     = 2049
    ip_protocol = "udp"
    cidr        = "0.0.0.0/0"
  }

  rule {
    from_port   = 32767
    to_port     = 32768
    ip_protocol = "tcp"
    cidr        = "0.0.0.0/0"
  }

  rule {
    from_port   = 32767
    to_port     = 32768
    ip_protocol = "udp"
    cidr        = "0.0.0.0/0"
  }
}

resource "openstack_networking_network_v2" "masters_net_1" {
  name = "masters_net_1"
}

resource "openstack_networking_network_v2" "ceph-net" {
  name = "ceph-net"
}
