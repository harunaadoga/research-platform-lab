terraform {
  required_providers {
    openstack = {
      source  = "terraform-provider-openstack/openstack"
      version = "~> 1.0"
    }
  }
}

data "openstack_networking_network_v2" "external" {
  name = "external"
}

data "openstack_networking_subnet_v2" "external" {
  name = "external"
}

data "openstack_images_image_v2" "rocky96" {
  name = "Rocky-9.6"
}

resource "openstack_networking_port_v2" "external" {
  name = "hpc-dev1"
  network_id = data.openstack_networking_network_v2.external.id
  admin_state_up = "true"

  allowed_address_pairs {
     ip_address = "0.0.0.0/0"
  }

}

resource "openstack_compute_instance_v2" "hpc-dev1" {

  name = "hpc-dev1"
  flavor_name = "general.v1.8cpu.16gb"
  key_pair = "slurm-admin-v1"

  network {
    name = "slurm-data"
    access_network = false
  }


  network {
    port = openstack_networking_port_v2.external.id
  }

  security_groups = ["prd-cluster", "default", "artemis-cluster"]

  # volume-backed instance:
  block_device {
    uuid = data.openstack_images_image_v2.rocky96.id
    source_type = "image"
    volume_size = 100
    boot_index = 0
    destination_type = "volume"
    delete_on_termination = false
  }

  user_data = <<-EOF
    #cloud-config
    ssh_authorized_keys:
      - ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDDlp66sJN/kSdBjPzomm+j6yb6Nlar4Lr20odJUJWK8t1p/SwPhDBBiNRKOcEHmRkae1uFXF638oF1WjdgoJEhuN2bdd9tvfTADHzQUNpbqgdeY7UQ+E6b4+oWga7rVFnk/YBKsiC9WB3d6G2lFTWSnvIqZCwi4ifYtB0LE3TdqW365bNqSc/wmCqGfoJejP9pdIg7ILQ/8sVLMqKd/b+0pEaJAJARNF4VltPcJwPtQokNTRU4Sugx5IH2syOhy1IAFj9WowyoubiGvl/xeWRKIMiZgrRaZiv64frEEogWyOVjF73VIWmZcGDJlNxTS+pON2gdDXfNUhFAXu+m+WD34jxP/5xkiAJZEjyj6gj3Caf9lkFfTdkwDSKZmclljSzJuOIReQ+TF+mn5Vw2n4GhDdTAMe7q2zXVQJFC20u/flZVLi0E9ly73JpVkxHxtK0t0z8ul1775E7Aiigr1Up6Y7nOqdPoClwHCXScJhDTgSk5qIUZTlsuOCdCiYzYPm0= h.adoga@sussex.ac.uk
    fqdn: nfs-smb.artemis.hrc.sussex.ac.uk
  EOF

}


