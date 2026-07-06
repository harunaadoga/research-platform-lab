# Home Lab: Research Computing Platform as Code

A miniature research computing platform built on Proxmox VE, managed
entirely as code. Every component is reproducible from this repository:
virtual machines are provisioned with OpenTofu, configured with Ansible,
and validated by CI on every push.

The lab mirrors the architecture of a production university research
platform: an HPC scheduler, monitoring stack, Kubernetes cluster,
network fabric, and backup infrastructure, scaled down to a single node.

## Architecture

(diagram to follow: docs/architecture.md)

- **Hypervisor:** Proxmox VE 9, ZFS storage
- **Provisioning:** OpenTofu (bpg/proxmox provider), Rocky Linux 9
  cloud-init template
- **Configuration:** Ansible with dynamic inventory from the Proxmox API
- **CI:** GitHub Actions lints all Tofu and Ansible on every push

## Roadmap

| Phase | Focus | Status |
|-------|-------|--------|
| 1 | IaC foundation: template, OpenTofu, dynamic inventory | in progress |
| 2 | Slurm cluster + Prometheus/Grafana, Nagios migration study | planned |
| 3 | Kubernetes (kubeadm) + GitOps | planned |
| 4 | Firewall segmentation, backup/restore drills | planned |
| 5 | Cumulus VX leaf-spine fabric (BGP unnumbered) | planned |

## Layout

    tofu/        OpenTofu modules per environment
    ansible/     Roles, playbooks, dynamic inventory
    docs/        Architecture notes and ADRs
