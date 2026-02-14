###Terraform and Ansible for GridPP ARC-CE VM

Terraform infra for grid-arcce VM on Artemis.

Currently deployed from `ceres` at `/home/slurm-deploy/artemis-arc-ce`.

Terraform authentication keys and state files are at /home/slurm-deploy/artemis-arc-ce on ceres.

###Arc-ce Install and Config (can be deployed on any secured ansible host on Sussex Campus/VPN)

cd ansible-install

Open install_arcce.yml

Update the IPs of the NFS shares for slurm binaries and session dirs. 

Update the authorized_keys.txt file as needed.

Update the inventory file as needed.

10.3.0.213:/exports/grid-sessions and 10.3.0.248:/exports/slurm-binaries nfs shares (replace correct IP in playbook)

Eventually to be converted into Ansible roles :)

run: ansible-playbook -i inventory playbooks/install_arcce.yml

**Here's a breakdown of the tasks in install_arcce.yml so far:**

**1. System Updates:**

* Updates all system packages using `dnf`.

**2. Key Import and Repository Configuration:**

* Imports the NorduGrid GPG key to verify package authenticity.
* Installs the `nordugrid-release` package to access ARC-CE repositories.
* Updates package cache after adding the new repository.

**3. Enable Additional Repositories:**

* Enables the CRB (Community RPM Build) repository for additional tools.
* Installs EPEL (Extra Packages for Enterprise Linux) and EPEL Next for broader package availability.

**4. Package Installation:**

* Installs `yum-utils` for additional package management utilities.
* Enables the NorduGrid Testing repository for access to development packages.
* Installs ARC-CE core packages (`nordugrid-arc-arex`), plugins (`nordugrid-arc-plugins-*`), gridftp server (`nordugrid-arc-gridftpd`), LDAP information system (`nordugrid-arc-infosys-ldap`), bash completion (`bash-completion`), and Python argument completion (`python-argcomplete`).

**5. ARC-CE Service Management:**

* Starts the A-REX service using `arcctl`.
* Enables the `arc-arex` and `arc-arex-ws` services to automatically start at boot.

**6. User Management:**

* Creates a user named `arc-user` for ARC-CE operations.
* Installs a user certificate for the `arc-user` with `arcctl`.

**7. ARC Client Tools:**

* Installs the `nordugrid-arc-client` package to provide ARC client tools.

**8. Time Synchronization:**

* Installs and enables the `chrony` time synchronization service.
* Sets the system time zone to Europe/London (adjust if needed).

**9. NFS Server and Client Setup:**

* Installs the `nfs-utils` package to enable NFS functionality.
* Starts the NFS server service (`nfs-server`).

**10. Shared Directory Mounting:**

* Creates a directory named `/mnt/shared` to mount the session directory.
* Mounts the session directory from an NFS server at `192.168.0.19:/exports/grid-sessions` using `nfs`.
* Adds an entry to `/etc/fstab` to ensure the mount persists across reboots.

**11. Slurm Binaries Mount (Optional):**

* Creates a directory named `/mnt/slurm-binaries` to mount the Slurm binaries directory (uncomment tasks if needed).
* Mounts the Slurm binaries directory from an NFS server at `192.168.0.19:/exports/slurm-binaries` using `nfs` (uncomment tasks if needed).
* Adds an entry to `/etc/fstab` for persistent mounting of the Slurm binaries directory (uncomment tasks if needed).

**12. Configures IPv6 address with default gateway on active interface:**
* The IPv6 will be updated 
