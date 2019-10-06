resource "azurerm_public_ip" "main" {
  name                = "${var.name}-public-ip"
  location            = "${var.resource_group.location}"
  resource_group_name = "${var.resource_group.name}"
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "main" {
  name                = "${var.name}-nic"
  location            = "${var.resource_group.location}"
  resource_group_name = "${var.resource_group.name}"

  ip_configuration {
    name                          = "${var.name}-ip-cfg"
    subnet_id                     = "${var.subnet}"
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = "${azurerm_public_ip.main.id}"
  }
}

resource "azurerm_network_security_group" "main" {
  name                = "${var.name}-nsg"
  location            = "${var.resource_group.location}"
  resource_group_name = "${var.resource_group.name}"

  dynamic "security_rule" {
    for_each = var.tcp_allowed_ingress

    content {
      name                       = format("allow-%s", security_rule.value)
      description                = format("Allow %s Traffic", security_rule.value)
      priority                   = format("2%03d", security_rule.key)
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      source_port_range          = "*"
      destination_port_range     = security_rule.value
      source_address_prefix      = "Internet"
      destination_address_prefix = "*"
    }
  }

  security_rule {
    name                       = "allow-nodeport-ranges"
    description                = "Allow Kubernetes NodePort ranges"
    priority                   = 300
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "30000-32767"
    source_address_prefix      = "Internet"
    destination_address_prefix = "*"
  }
}

resource "azurerm_virtual_machine" "main" {
  name                  = "${var.name}-vm"
  location              = "${var.resource_group.location}"
  resource_group_name   = "${var.resource_group.name}"
  network_interface_ids = ["${azurerm_network_interface.main.id}"]
  vm_size               = "${var.vm_size}"

  delete_os_disk_on_termination    = true
  delete_data_disks_on_termination = true

  storage_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }

  storage_os_disk {
    name              = "${var.name}-boot-disk"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  os_profile {
    computer_name  = "${var.name}"
    admin_username = "${var.system_user}"
    custom_data = <<EOF
#!/bin/bash
# User configuration
curl -sq https://github.com/${var.github_user}.keys | tee -a /home/${var.system_user}/.ssh/authorized_keys
# Base package installation
sudo apt-get -y install apt-transport-https ca-certificates curl gnupg2 software-properties-common
## Add Kubernetes repo
curl -fsSL https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -
echo "deb https://apt.kubernetes.io/ kubernetes-xenial main" >/etc/apt/sources.list.d/kubernetes.list
## Add Docker repo
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo apt-key fingerprint 0EBFCD88
sudo add-apt-repository -y "deb [arch=amd64] https://download.docker.com/linux/ubuntu bionic stable"
## Add Golang repo
sudo add-apt-repository -y ppa:longsleep/golang-backports
## Install Docker, Golang and kubectl
sudo apt-get -y update
sudo apt-get -y install docker-ce=5:18.09.9~3-0~ubuntu-bionic golang-1.12-go git kubectl
## Add ${var.system_user} to Docker group
sudo usermod -aG docker ${var.system_user}
## Setup Golang Path
echo -e 'export GOROOT=/usr/lib/go-1.12\nexport PATH=$PATH:$GOROOT/bin' > /etc/profile.d/golang-1.12.sh
EOF
  }

  os_profile_linux_config {
    disable_password_authentication = true
    ssh_keys {
      path     = "/home/${var.system_user}/.ssh/authorized_keys"
      key_data = file("~/.ssh/id_rsa.pub")
    }
  }

}