terraform {
  required_providers {
    proxmox = {
      source  = "bpg/proxmox"
      version = "~> 0.66"
    }
  }
}

provider "proxmox" {
  endpoint  = "https://192.168.0.50:8006"
  api_token = var.pve_api_token
  insecure  = true
}

variable "pve_api_token" {
  type      = string
  sensitive = true
}

resource "proxmox_virtual_environment_vm" "node" {
  count     = 3
  name      = "lab0${count.index + 1}"
  node_name = "gida"

  clone {
    vm_id = 9000
    full  = true
  }

  cpu {
    cores = 2
    type  = "host"
  }

  memory {
    dedicated = 2048
  }

  initialization {
    datastore_id = "local-zfs"

    ip_config {
      ipv4 {
        address = "dhcp"
      }
    }

    user_account {
      username = "rocky"
      keys     = [trimspace(file("~/.ssh/id_ed25519.pub"))]
    }
  }

  agent {
    enabled = true
    timeout = "3m"
  }
}

output "vm_ipv4" {
  value = {
    for vm in proxmox_virtual_environment_vm.node :
    vm.name => vm.ipv4_addresses
  }
}
