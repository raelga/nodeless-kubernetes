terraform {
  backend "local" {
    path = ".terraform/state/kubelet.tfstate"
  }
}

provider "azurerm" {
  version = "=1.34.0"
}

resource "azurerm_resource_group" "kubelet" {
  name     = "kubelet-lab-rg"
  location = "West Europe"
}

module "net" {
  source              = "../../infra/tf/modules/azure/network/virtual-network"
  resource_group      = "${azurerm_resource_group.kubelet}"
  name                = "kubelet"
}

module "vm" {
  source              = "../../infra/tf/modules/azure/compute/virtual-machine"
  resource_group      = "${azurerm_resource_group.kubelet}"
  network             = "${module.net.network_id}"
  subnet              = "${module.net.subnet_id}"
  name                = "kubelet"
  vm_size             = "Standard_F8s_v2"
  system_user         = "rael"
  github_user         = "raelga"
  tcp_allowed_ingress = [ 22, 80 ]
}

output "public_ip" {
  value = "${module.vm.public_ip}"
}
