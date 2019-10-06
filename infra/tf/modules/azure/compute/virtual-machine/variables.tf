variable "resource_group" {
  description = "Azure Resource Group"
}

variable "network" {
  description = "Virtual Machine virtual network"
  type        = "string"
}
variable "subnet" {
  description = "Virtual Machine subnetwork"
  type        = "string"
}

variable "name" {
  description = "Virtual Machine name"
  type        = "string"
}

variable "tcp_allowed_ingress" {
  description = "Network Security Group TCP allowed ports"
  type        = "list"
  default     = [22]
}

variable "vm_size" {
  description = "VM size"
  type        = "string"
  default     = "Standard_B1ls"
}

variable "system_user" {
  description = "VM instance user"
  type        = "string"
  default     = "rael"
}

variable "github_user" {
  description = "GitHub user, to retrieve the public ssh keys"
  type        = "string"
  default     = "raelga"
}
