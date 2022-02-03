EJBCA Packer template
=====================

Introduction
------------

This is a Hashicorp packer file to build an EJBCA Community edition (docker-file) on Ubuntu with a Utimaco SecurityServer HSM (simulator is supported).
You nee to use the Utimaco HSM simulator or Utimaco PCI driver. It uses pre-configure docker containers based on container of ejbca and Utimaco HSM simulator.

Setup
-----

1) Verify the template variables to change the settings of your instance.
2) Also change the setting (authorized-keys, default user) in the user-data, under http/[proxmox|vmware]/linux/ubuntu/20.04/ 

###Docker container Utimaco simulator:

1) Install the Utimaco simulator files (linux) in the sim5_linux directory
2) create /docker-hsm/admin_key directory and install the ADMIN.key and ADMIN_EC.key in the directory from the Utimaco CD
3) create /docker-hsm/Administration directory and install the csadm, cxitool and p11tool (all linux versions) in the directory from the Utimaco CD

Then you should be able to build the container image.

###Docker container EJBCA:
For the Utimaco HSM integration you need to copy the PKCS11 library (libcs_pkcs11_R3.so) into docker-ejbca/utimaco directory

TODO
----
- Make the setting for cloud init configuration more automatic.
- Stop the project and migrate to Ansible

Notes
-----
