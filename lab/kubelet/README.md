# kubelet

## Deploy an instance in the Cloud

You can skip this step if you are running everything locally.

### Deploy the instance with terraform in Azure

- Command

```bash
tf apply -auto-approve
```

- Expected output

```bash
❯ tf apply -auto-approve
azurerm_resource_group.kubelet: Creating...
azurerm_resource_group.kubelet: Creation complete after 1s [id=/subscriptions/c825038c-1551-4ccf-8ddd-24b49f8e14b4/resourceGroups/kubelet-lab-rg]
module.master.azurerm_public_ip.main: Creating...
module.net.azurerm_virtual_network.main: Creating...
module.master.azurerm_network_security_group.main: Creating...
module.master.azurerm_public_ip.main: Creation complete after 3s [id=/subscriptions/c825038c-1551-4ccf-8ddd-24b49f8e14b4/resourceGroups/kubelet-lab-rg/providers/Microsoft.Network/publicIPAddresses/kubelet-public-ip]
module.net.azurerm_virtual_network.main: Still creating... [10s elapsed]
module.master.azurerm_network_security_group.main: Still creating... [10s elapsed]
module.net.azurerm_virtual_network.main: Creation complete after 11s [id=/subscriptions/c825038c-1551-4ccf-8ddd-24b49f8e14b4/resourceGroups/kubelet-lab-rg/providers/Microsoft.Network/virtualNetworks/kubelet-net]
module.net.azurerm_subnet.compute: Creating...
module.master.azurerm_network_security_group.main: Creation complete after 11s [id=/subscriptions/c825038c-1551-4ccf-8ddd-24b49f8e14b4/resourceGroups/kubelet-lab-rg/providers/Microsoft.Network/networkSecurityGroups/kubelet-nsg]
module.net.azurerm_subnet.compute: Still creating... [10s elapsed]
module.net.azurerm_subnet.compute: Creation complete after 12s [id=/subscriptions/c825038c-1551-4ccf-8ddd-24b49f8e14b4/resourceGroups/kubelet-lab-rg/providers/Microsoft.Network/virtualNetworks/kubelet-net/subnets/compute]
module.master.azurerm_network_interface.main: Creating...
module.master.azurerm_network_interface.main: Creation complete after 6s [id=/subscriptions/c825038c-1551-4ccf-8ddd-24b49f8e14b4/resourceGroups/kubelet-lab-rg/providers/Microsoft.Network/networkInterfaces/kubelet-nic]
module.master.azurerm_virtual_machine.main: Creating...
module.master.azurerm_virtual_machine.main: Still creating... [10s elapsed]
module.master.azurerm_virtual_machine.main: Still creating... [20s elapsed]
module.master.azurerm_virtual_machine.main: Still creating... [30s elapsed]
module.master.azurerm_virtual_machine.main: Still creating... [40s elapsed]
module.master.azurerm_virtual_machine.main: Still creating... [50s elapsed]
module.master.azurerm_virtual_machine.main: Still creating... [1m0s elapsed]
module.master.azurerm_virtual_machine.main: Still creating... [1m10s elapsed]
module.master.azurerm_virtual_machine.main: Still creating... [1m20s elapsed]
module.master.azurerm_virtual_machine.main: Still creating... [1m30s elapsed]
module.master.azurerm_virtual_machine.main: Still creating... [1m40s elapsed]
module.master.azurerm_virtual_machine.main: Creation complete after 1m42s [id=/subscriptions/c825038c-1551-4ccf-8ddd-24b49f8e14b4/resourceGroups/kubelet-lab-rg/providers/Microsoft.Compute/virtualMachines/kubelet-vm]

Apply complete! Resources: 7 added, 0 changed, 0 destroyed.

The state of your infrastructure has been saved to the path
below. This state is required to modify and destroy your
infrastructure, so keep it safe. To inspect the complete state
use the `terraform show` command.

State path: .terraform/state/kubelet.tfstate

Outputs:

master_public_ip = 40.91.214.174
```

### Connect to the `kubelet` instance

```bash
rgarcia@L001110:~/gh/raelga/nodeless-kubernetes/lab/kubelet
$ ssh 52.236.177.161
```

- Expected output

```bash
The authenticity of host '52.236.177.161 (52.236.177.161)' can't be established.
ECDSA key fingerprint is SHA256:aF6uRwATZUzQLucR+FYOyDR8uxRdz8e24Ot0mVIkVlE.
Are you sure you want to continue connecting (yes/no)? yes
Warning: Permanently added '52.236.177.161' (ECDSA) to the list of known hosts.
Welcome to Ubuntu 18.04.3 LTS (GNU/Linux 5.0.0-1018-azure x86_64)

 * Documentation:  https://help.ubuntu.com
 * Management:     https://landscape.canonical.com
 * Support:        https://ubuntu.com/advantage

  System information as of Wed Oct  9 15:57:17 UTC 2019

  System load:  1.3               Processes:           186
  Usage of /:   6.0% of 28.90GB   Users logged in:     0
  Memory usage: 4%                IP address for eth0: 10.1.0.4
  Swap usage:   0%

50 packages can be updated.
39 updates are security updates.



The programs included with the Ubuntu system are free software;
the exact distribution terms for each program are described in the
individual files in /usr/share/doc/*/copyright.

Ubuntu comes with ABSOLUTELY NO WARRANTY, to the extent permitted by
applicable law.

To run a command as administrator (user "root"), use "sudo <command>".
See "man sudo_root" for details.

rael@kubelet
~
$
```

## Docker

### Check docker service

The bootstrap of the instance install Docker.

```bash
root@kubelet
~
$ docker ps
CONTAINER ID        IMAGE               COMMAND             CREATED             STATUS              PORTS               NAMES
```

### Run a container

- Command

```bash
docker run --tty --interactive --rm --name hello-docker raelga/hello
```

- Expected output

```bash
$ docker run --rm --tty --interactive --name hello-docker raelga/hello
Unable to find image 'raelga/hello:latest' locally
latest: Pulling from raelga/hello
e7c96db7181b: Pull complete 
34c10b69cd5f: Pull complete 
2dc682800300: Pull complete 
Digest: sha256:6fd46eb83ac3e0d4422bf450261a8a0a3117b5afc145884a21c8cfdcba33638e
Status: Downloaded newer image for raelga/hello:latest
Hello from 51db54eacb20 at Sun Oct 13 21:08:20 UTC 2019
Hello from 51db54eacb20 at Sun Oct 13 21:08:30 UTC 2019
^C
```


### Run a container in the background

- Command

```bash
docker run --rm --detach --name hello-docker raelga/hello
```

- Expected output

A docker container full id.

```bash
c967ef8f994de29904958296d6132acff03a308ca42c0d43403f420a51a6dc5d
```

### Check the status of the container

```bash
docker ps
```

- Expected output

```bash
CONTAINER ID        IMAGE               COMMAND                  CREATED             STATUS              PORTS               NAMES
c967ef8f994d        raelga/hello        "bash -c 'while true…"   3 seconds ago       Up 1 second                             hello-docker
```

## Kubernetes Node





## Kubernetes Master

### Connect to the master instance

### Install kubeadm


<!-- ## Download the kubectl binaries

- Command

```bash
curl -sqL go.rael.dev/k8s1-16-0 | tar -zxvf -
```

- Expected output

```
kubernetes/
kubernetes/server/
kubernetes/server/bin/
kubernetes/server/bin/kube-scheduler.tar
kubernetes/server/bin/mounter
kubernetes/server/bin/kube-scheduler.docker_tag
kubernetes/server/bin/kubeadm
kubernetes/server/bin/kube-controller-manager.docker_tag
kubernetes/server/bin/hyperkube
kubernetes/server/bin/kube-apiserver.docker_tag
kubernetes/server/bin/kube-apiserver
kubernetes/server/bin/kubectl
kubernetes/server/bin/kube-proxy.docker_tag 
kubernetes/server/bin/kube-apiserver.tar
kubernetes/server/bin/kube-proxy.tar
kubernetes/server/bin/kubelet
kubernetes/server/bin/apiextensions-apiserver
kubernetes/server/bin/kube-controller-manager.tar
kubernetes/server/bin/kube-proxy
kubernetes/server/bin/kube-scheduler
kubernetes/server/bin/kube-controller-manager
kubernetes/kubernetes-src.tar.gz
kubernetes/LICENSES
kubernetes/addons/
``` -->

