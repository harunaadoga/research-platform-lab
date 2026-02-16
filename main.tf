# Terraform configuration block - specifies required providers
terraform {
  required_providers {
    openstack = {
      source  = "terraform-provider-openstack/openstack"
      version = "~> 1.0"
    }
  }
}

# Data source: Query the external network by name
data "openstack_networking_network_v2" "external" {
  name = "external"
}

# Data source: Query the external subnet by name
data "openstack_networking_subnet_v2" "external" {
  name = "external"
}

# Data source: Query the Rocky Linux 9.6 image
data "openstack_images_image_v2" "rocky96" {
  name = "Rocky-9.6"
}

# Create network ports on the external network for each VM
# This creates 3 ports: hpc-dev1, hpc-dev2, hpc-dev3
resource "openstack_networking_port_v2" "external" {
  count      = 3
  name       = "hpc-dev${count.index + 1}"
  network_id = data.openstack_networking_network_v2.external.id
  admin_state_up = "true"

  # Allow all IP addresses for routing flexibility
  allowed_address_pairs {
     ip_address = "0.0.0.0/0"
  }

}

# Create compute instances (VMs) for Ansible lab environment
# This creates 3 VMs: hpc-dev1, hpc-dev2, hpc-dev3
resource "openstack_compute_instance_v2" "hpc-dev" {
  count = 3

  # VM configuration
  name        = "hpc-dev${count.index + 1}"
  flavor_name = "general.v1.4cpu.8gb"
  key_pair    = "slurm-admin-v1"

  # First network interface: slurm-data (internal network)
  network {
    name           = "slurm-data"
    access_network = false
  }

  # Second network interface: external network (using pre-created port)
  network {
    port = openstack_networking_port_v2.external[count.index].id
  }

  # Security groups for firewall rules
  security_groups = ["default", "artemis-cluster"]

  # Boot from volume configuration
  # Creates a 100GB volume from Rocky 9.6 image
  # Volume persists after VM deletion (delete_on_termination = false)
  block_device {
    uuid                  = data.openstack_images_image_v2.rocky96.id
    source_type           = "image"
    volume_size           = 100
    boot_index            = 0
    destination_type      = "volume"
    delete_on_termination = false
  }

  # Cloud-init configuration
  # Sets up SSH key and hostname on first boot
  user_data = <<-EOF
    #cloud-config
    ssh_authorized_keys:
      - ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDDlp66sJN/kSdBjPzomm+j6yb6Nlar4Lr20odJUJWK8t1p/SwPhDBBiNRKOcEHmRkae1uFXF638oF1WjdgoJEhuN2bdd9tvfTADHzQUNpbqgdeY7UQ+E6b4+oWga7rVFnk/YBKsiC9WB3d6G2lFTWSnvIqZCwi4ifYtB0LE3TdqW365bNqSc/wmCqGfoJejP9pdIg7ILQ/8sVLMqKd/b+0pEaJAJARNF4VltPcJwPtQokNTRU4Sugx5IH2syOhy1IAFj9WowyoubiGvl/xeWRKIMiZgrRaZiv64frEEogWyOVjF73VIWmZcGDJlNxTS+pON2gdDXfNUhFAXu+m+WD34jxP/5xkiAJZEjyj6gj3Caf9lkFfTdkwDSKZmclljSzJuOIReQ+TF+mn5Vw2n4GhDdTAMe7q2zXVQJFC20u/flZVLi0E9ly73JpVkxHxtK0t0z8ul1775E7Aiigr1Up6Y7nOqdPoClwHCXScJhDTgSk5qIUZTlsuOCdCiYzYPm0= h.adoga@sussex.ac.uk
    fqdn: hpc-dev${count.index + 1}.artemis.hrc.sussex.ac.uk
  EOF

}