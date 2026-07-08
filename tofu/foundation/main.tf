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

locals {
  nodes = {
    mon01 = {
      cores  = 2
      memory = 3072
      disk   = 30
      description = "Prometheus, Grafana, Alertmanager, Loki"
    }
    slurm-ctrl01 = {
      cores  = 2
      memory = 3072
      disk   = 40
      description = "Slurm controller, slurmdbd, MariaDB"
    }
    compute01 = {
      cores  = 2
      memory = 2048
      disk   = 20
      description = "Slurm compute node"
    }
    compute02 = {
      cores  = 2
      memory = 2048
      disk   = 20
      description = "Slurm compute node"
    }
  }
}

resource "proxmox_virtual_environment_vm" "node" {
  for_each  = local.nodes
  name      = each.key
  node_name = "gida"

  description = each.value.description

  clone {
    vm_id = 9000
    full  = true
  }

  cpu {
    cores = each.value.cores
    type  = "host"
  }

  memory {
    dedicated = each.value.memory
  }

  disk {
    interface    = "scsi0"
    datastore_id = "local-zfs"
    size         = each.value.disk
  }

  initialization {
    datastore_id = "local-zfs"

  dns {
    domain = "gida.lab"
    }
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

output "vm_ips" {
  value = {
    for name, vm in proxmox_virtual_environment_vm.node :
    name => try(vm.ipv4_addresses[1][0], "pending")
  }
}