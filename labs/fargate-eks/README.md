# Nodeless Kubernetes on AWS

This lab is based on several resources you can find splitted into different directories:

* k8s: directory that contains different yaml files used at some point of the lab
* docker: directory with resources to build yoursef the Docker images used in the lab
* terraform: terraform resources used to deploy the AWS components used in the lab. To keep things simple, everything is deployed in the same terraform configuration but splitted into several files. To deploy things in the proper order everything is commented out and you will need to uncomment it to deploy each separate component at each step of the lab.

## Assumptions

* You have AWS credentials either in your environment or in a shared credentials file
* You need to edit the terraform `provider.tf` file to either point to your own shared state or to use a local state file

## Create base resources

```bash
cd labs/fargate-eks/terraform
terraform init
terraform apply -auto-approve
```

This will create:

* A simple VPC with 2 public subnets
* An EKS cluster, which we will use as the control plane of our Nodeless Kubernetes Cluster, using the subnets created in that VPC. EKS also requires a security group for the control plane and an IAM role to let EKS service to perform calls to several AWS APIs on your behalf.
* A couple of ECR repositories that we will use later on. You could also use any other container registry, just take into account that you will need to update the references to the images in the lab's resources if you do so.

Retrieve the cluster credentials using the AWS CLI: `aws eks update-kubeconfig --region eu-west-1 --name eks-lab`

Now that we have a Kubernetes control plane, we need somewhere to run our workloads. As you can see, the cluster can't run pods anywhere:

```bash
kubectl -n kube-system get pods
```

Question: EKS deploys coredns, aws-node and kube-proxy for you so you when creating the cluster, why are we only seeing the coredens pod?

## Create an Elastic Container Service cluster to run workload in it

Uncomment the whole block of resources contained in the file `03-ecs.tf`. Then apply the terraform config again with `terraform apply -auto-approve`. The following resources will get created:

* An ECS cluster. It's just a logical cluster where we will create fargate backed containers.
* Default resources to be used by the containers created inside the ECS cluster:
  * An IAM role: this is what AWS calls the `execution role`, which is used to grant the ECS service running the container to call other AWS services on your behalf. In this case we grant the containers access to CloudWatch Logs and to our ECR registries to be able to pull images.
  * A default security group which grants access from the internet to the container.

## Enter virtual-kubelet

### Deploy virtual-kubelet

We need something that creates pods in the cluster by using ECS tasks (backed by the Fargate provider). To do so, we create an ECS service that will run the virtual-kubelet "outside-of-cluster". By this, we mean that this container is not managed by Kubernetes but directly by the ECS service that we are going to create.

1. Go to `labs/fargate-eks/docker/virtual-kubelet` and issue a `make build && make push` command to build and push the virtual-kubelet docker image to out ECR registry.
1. Go back to `labs/fargate-eks/terraform`. Uncomment the terraform resources located in `04-virtual-kubelet.tf` and apply againt using `terraform apply -auto-approve`.

The following resources will get created:

* An ECS service. You can think of it as the (somehow) equivalent of a Kubernetes Deployment. The service will maintain an ECS a single task (somehow equivalent to a pod) running the virtual-kubelet
* An IAM role that we will use as the `task_role` which will grant the virtual-kubelet container full access to the ECS service so it can create containers in our ECS cluster (using the Fargate provider).

Question: Will virtual-kubelet be able to register itself as a Kubernetes "node"?

### Register virtuall-kubelet with the Kubernetes cluster

We are going to take advantage of the native integration of EKS with IAM for the management of the Kubernetes API access. This allows to map IAM users/roles to Kubernetes RBAC groups.

Go to `labs/fargate-eks/k8s` and issue the following command:

```bash
kubectl apply -f aws-iam-auth-config.yaml
```

If you check the contents of this file, you will see that it is a ConfigMap with a mapping between an IAM role and a k8s rbac group. The IAM role is the one we just have created for the virtual-kubelet container, so we are in fact granting the virtual-kubelet container with permissions to access the Kubernetes API. 

Wait for virtual-kubelet to register with the k8s API (you can speed up the process by stopping the virtual-kubelet task in the ECS console and waiting for a new virtual-kubelet task to pop up). You should see something like this after a while:

```bash
$ kubectl get nodes
NAME              STATUS   ROLES   AGE    VERSION
virtual-kubelet   Ready    agent   160m   v1.13.1-vk-v0.9.1
```

### Deploy a workload

Go to `lab/fargate-eks/k8s` and deploy the `nginx.yaml` file located there using `kubectl`:

```bash
kubectl apply -f nginx.yaml
```

Wait for the pod to be ready

```bash
kubectl get pods --watch
```

You can now get the pod public IP from the ECS console (go to the list of cluster tasks) from one of the 3 nginx we have just deployed. Open a browser and navigate to that IP, you should see your nginx.

Question: how do we create some kind of load balancing to distribute requests to the 3 nginx pods?

### Publishing the nginx deployment

We are going to use a new ECS service to deploy a traefik container in Fargate. This traefik will work as an ingress controller so it will need some kind of permissions to access the Kubernetes API. What we are going to do is to create a custom trafik image with the hardcoded credentials inside and deploy that image to Fargate.

1. First of all we create a k8s service account with the permissions required by traefik to work as an ingress controller 

```bash
cd labs/eks-fargate/k8s
kubecl apply -f traefik.yaml
```

2. To create the traefik image with the credentials:

```bash
cd labs/eks-fargate/docker/traefik
make build && make push
```

Once we have the image with the traefik and the k8s cluster credentians in our registry, we can deploy the traefik, which will also have an ALB in front of it. To do so, got to the file `05-traefik.tf` and uncomment all resources. Then apply the terraform configuration again.

```bash
terraform apply -auto-approve
```

Go to the EC2 console and get the endpoint of the load balancer and open it in a brouser. You should now se that each one of your request is answered by a different nginx container, we have load balancing! :)

Question: how can we avoid generating a custom traefin image with hardcoded credentials?

