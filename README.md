# k8s-time-based-scaling
Based of the [EKS Cluster with Karpenter Cluster Autoscaler](https://github.com/aws-ia/terraform-aws-eks-blueprints/tree/main/examples/karpenter) example, this depoys a Horizontal Pod Autoscaler for NGINX and uses CronJobs to update the `minReplicas` for time based autoscaling with Karpenter, while still allowing load generated autoscaling.

Inspired by [Time Based Scaling for Kubernetes Deployments](https://medium.com/symbl-ai-engineering-and-data-science/time-based-scaling-for-kubernetes-deployments-9ef7ada93eb7).

# How to Deploy

## Prerequisites:

Ensure that you have installed the following tools in your Mac or Windows Laptop before start working with this module and run Terraform Plan and Apply

1. [aws cli](https://docs.aws.amazon.com/cli/latest/userguide/install-cliv2.html)
2. [kubectl](https://Kubernetes.io/docs/tasks/tools/)
3. [terraform](https://learn.hashicorp.com/tutorials/terraform/install-cli)

## Deployment Steps

#### Step 1: Clone the repo using the command below

```sh
git clone https://github.com/jamiemo/k8s-time-based-scaling.git
```

#### Step 2: Run Terraform INIT

to initialize a working directory with configuration files

```sh
terraform init
```

#### Step 3: Run Terraform PLAN

to verify the resources created by this execution

```sh
terraform plan
```

#### Step 4: Finally, Terraform APPLY

**Deploy the pattern**

```sh
terraform apply
```

Enter `yes` to apply.

### Configure kubectl and test cluster

EKS Cluster details can be extracted from terraform output or from AWS Console to get the name of cluster. This following command used to update the `kubeconfig` in your local machine where you run kubectl commands to interact with your EKS Cluster.

#### Step 5: Run update-kubeconfig command.

`~/.kube/config` file gets updated with cluster details and certificate from the below command

```sh
aws eks --region <region> update-kubeconfig --name <cluster-name>
```

## Update ~/.kube/config

 ```sh
aws eks --region <region> update-kubeconfig --name <cluster-name>    
```

## Build kubectl Image
The ECR repo URL is in the Terraform output.

Authenticate to ECR. [Pushing a Docker image](https://docs.aws.amazon.com/AmazonECR/latest/userguide/docker-push-ecr-image.html).

```sh
aws ecr get-login-password --region <region> | docker login --username AWS --password-stdin <ECR FQDN>
```

Make sure Docker is running locally.

```sh
docker build -t <ECR repo URL> -t kubectl --build-arg aws_region=<region> --build-arg cluster_name=<cluster name> .
docker push <ECR repo URL>
```

## Generate Load
If you want to generate some load, but not required for autoscaling.

```sh
kubectl run -i --tty load-generator --rm --image=busybox:1.28 --restart=Never -- /bin/sh -c "while true; do wget -q -O- http://nginx-demo; done"
```

## Destroy the Kubernetes Add-ons, EKS cluster with Node groups and VPC

    terraform destroy -target="module.eks_blueprints_kubernetes_addons" -auto-approve
    terraform destroy -target="module.eks_blueprints" -auto-approve
    terraform destroy -target="module.vpc" -auto-approve

Finally, destroy any additional resources that are not in the above modules

    terraform destroy -auto-approve

# ToDo
- Reduce permissions from eks:* in hpa_irsa_policy
- Reduce cluster-admin ClusterRole for kubectl-hpa service accounut