###Terraform and Ansible HPC dev VM

Terraform infra for test VM on Artemis.

Currently deployed from `ceres` at `/home/ha535`.

Terraform authentication keys and state files are at /home/slurm-deploy/artemis-arc-ce on ceres.


# Start lab
cd ~/Git_Repos/ansible-lab-infra
source activate
terraform apply -auto-approve

# Practice...

# When finished
terraform destroy -auto-approve
