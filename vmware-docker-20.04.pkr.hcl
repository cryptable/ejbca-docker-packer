# VMware Section
# --------------

variable "vm_name" {
  type    = string
  default = "ejbca-test"
}

variable "cpu" {
  type    = string
  default = "2"
}

variable "ram_size" {
  type    = string
  default = "4096"
}

variable "disk_size" {
  type    = string
  default = "50000M"
}

variable "iso_checksum" {
  type    = string
  default = "f8e3086f3cea0fb3fefb29937ab5ed9d19e767079633960ccb50e76153effc98"
}

variable "iso_checksum_type" {
  type    = string
  default = "sha256"
}

# VMware Section
# --------------

variable "iso_url" {
  type    = string
  default = "https://releases.ubuntu.com/focal/ubuntu-20.04.3-live-server-amd64.iso"
}

variable "output_directory" {
  type    = string
  default = "output-ubuntu"
}

variable "eth_point" {
  type    = string
  default = "ens33"
}

# Proxmox Section
# ---------------

variable "pve_username" {
  type    = string
  default = "output-ubuntu"
}

variable "pve_token" {
  type    = string
  default = "secret"
}

variable "pve_url" {
  type    = string
  default = "https://127.0.0.1:8006/api2/json"
}

variable "iso_file"  {
  type    = string
  default = "local:iso/ubuntu-20.04.3-live-server-amd64.iso"
}

variable "eth_point" {
  type    = string
  default = "ens18"
}

# Ubuntu Section
# --------------

variable "ejbca_user_password" {
  type    = string
  default = "Ejbc4Us3r"  
}

variable "ejbca_hostname" {
  type    = string
  default = "ejbca"
}

# MySQL Section
# -------------

variable "mysql_root_password" {
  type    = string
  default = "toorlqsym"
}

variable "ejbca_mysql_password" {
  type    = string
  default = "Ejbc4Mysql"  
}

variable "ejbca_jdbc_mysql" {
  type    = string
  default = "jdbc:mysql://db:3306/ejbca?characterEncoding=UTF-8"  
}

# HSM Section
# -----------
variable "hsm_simulator" {
  type    = string
  default = "true"
}

variable "hsm_device" {
  type    = string
  default = "3001@127.0.0.1"
}

# VMWARE image section
# --------------------

source "vmware-iso" "ubuntu" {
  boot_command         = [
    "<wait>",
    " <wait>",
    " <wait>",
    " <wait>",
    " <wait>",
    "<esc><wait>",
    "<f6><wait>",
    "<esc><wait>",
    "<bs><bs><bs><bs><wait>",
    " autoinstall<wait5>",
    " ds=nocloud-net<wait5>",
    ";s=http://<wait5>{{.HTTPIP}}<wait5>:{{.HTTPPort}}/<wait5>",
    " hostname=temporary",
    " ---<wait5>",
    "<enter><wait5>",
  ]

  boot_wait            = "5s"
  communicator         = "ssh"
  cpus                 = "${var.cpu}"
  disk_size            = "${var.disk_size}"
  http_directory       = "./linux/ubuntu/http/20.04"
  iso_checksum         = "${var.iso_checksum_type}:${var.iso_checksum}"
  iso_url              = "${var.iso_url}"
  memory               = "${var.ram_size}"
  shutdown_command     = "echo 'vagrant' | sudo -S -E shutdown -P now"
  ssh_timeout          = "10m"
  ssh_username         = "vagrant"
  ssh_password         = "vagrant"
  vm_name              = "${var.vm_name}"
  guest_os_type        = "ubuntu-64"
  output_directory     = "${var.output_directory}"
  format = "ova"
}

# Proxmox image section
# ---------------------

source "proxmox-iso" "ubuntu" {
  proxmox_url = "${var.pve_url}"
  username = "${var.pve_username}"
  token = "${var.pve_token}"
  node =  "pve"
  iso_checksum = "${var.iso_checksum_type}:${var.iso_checksum}"
  iso_file = "${var.iso_file}"
  insecure_skip_tls_verify = true
  boot_command         = [
    "<wait>",
    " <wait>",
    " <wait>",
    " <wait>",
    " <wait>",
    "<esc><wait>",
    "<f6><wait>",
    "<esc><wait>",
    "<bs><bs><bs><bs><wait>",
    " autoinstall",
    " ds=nocloud-net",
    ";s=http://{{.HTTPIP}}:{{.HTTPPort}}/",
    " hostname=temporary",
    " ---",
    "<enter>",
  ]

  boot_wait            = "5s"
  communicator         = "ssh"
  cores                = "${var.cpu}"
  http_directory       = "./http/proxmox/linux/ubuntu/20.04"
  memory               = "${var.ram_size}"
  ssh_timeout          = "30m"
  ssh_username         = "vagrant"
  ssh_password         = "vagrant"
  vm_name              = "${var.vm_name}"
  os        = "l26"
  network_adapters {
    model = "e1000"
    bridge = "vmbr0"
  }
  disks {
    type = "scsi"
    disk_size  = "${var.disk_size}"
    storage_pool = "local-lvm"
    storage_pool_type = "lvm-thin"
    format = "raw"
  }
}

build {
  sources = [
    "source.proxmox-iso.ubuntu"
  ]

  provisioner "file" {
    source = "assets/docker-config"
    destination = "/tmp"
  }  

  provisioner "shell" {
    execute_command = "{{ .Vars }} sudo -S -E sh {{ .Path }}"
    environment_vars = [
      "MSQL_ROOT_PASSWORD=${var.mysql_root_password}",
      "HSM_DEVICE=${var.hsm_device}",
      "HSM_SIMULATOR=${var.hsm_simulator}",
      "EJBCA_USER_PASSWORD=${var.ejbca_user_password}",
      "EJBCA_MYSQL_PASSWORD=${var.ejbca_mysql_password}",
      "EJBCA_JDBC_MYSQL=${var.ejbca_jdbc_mysql}",
      "HOSTNAME=${var.ejbca_hostname}"
      "ETH_POINT=${var.eth_point}"
    ]
    scripts         = [
      "./scripts/update.sh", 
      "./scripts/temp.sh",
      "./scripts/vmware.sh",
      "./scripts/docker-install.sh",
      "./scripts/ejbca-install.sh",
      "./scripts/hsm-install.sh",
      "./scripts/ejbca-config.sh",
      "./scripts/docker-config.sh",
      "./scripts/network-config.sh",
      "./scripts/hostname.sh",
      "./scripts/cleanup.sh",
      "./scripts/harden.sh",
    ]
  }
}
