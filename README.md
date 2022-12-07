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
This will allow kubectl to connect to the EKS cluster. The command is listed in the Terraform output. The `~/.kube/config` file gets updated with cluster details and certificate from the below command:

```sh
aws eks --region <region> update-kubeconfig --name <cluster-name>
```

## Build kubectl Image
This will create a custom image with kubectl that authenticates using the IAM Roles for Service Accounts, which is then uploaded to ECR for deployment in CronJobs. The ECR repo URL and authentication command are in the Terraform output.

Authenticate to ECR. [Pushing a Docker image](https://docs.aws.amazon.com/AmazonECR/latest/userguide/docker-push-ecr-image.html).

```sh
aws ecr get-login-password --region <region> | docker login --username AWS --password-stdin <ECR FQDN>
```

Make sure Docker is running locally.

```sh
docker build -t <ECR repo URL> -t kubectl --build-arg aws_region=<region> --build-arg cluster_name=<cluster name> .
docker push <ECR repo URL>
```

## Watch Deployment Scaling
Watch the `minReplicas` being updated by the CronJob.
 
```sh
kubectl get hpa -n nginx-demo --watch      
NAME         REFERENCE               TARGETS         MINPODS   MAXPODS   REPLICAS   AGE
nginx-demo   Deployment/nginx-demo   0%/50%          2         20        2          40m
nginx-demo   Deployment/nginx-demo   0%/50%          10        20        2          40m
nginx-demo   Deployment/nginx-demo   <unknown>/50%   10        20        2          40m
nginx-demo   Deployment/nginx-demo   <unknown>/50%   10        20        10         40m
nginx-demo   Deployment/nginx-demo   0%/50%          2         20        10         50m
nginx-demo   Deployment/nginx-demo   0%/50%          2         20        2          50m
nginx-demo   Deployment/nginx-demo   0%/50%          10        20        2          60m
nginx-demo   Deployment/nginx-demo   <unknown>/50%   10        20        2          60m
nginx-demo   Deployment/nginx-demo   0%/50%          10        20        10         60m
```

## Generate Load
If you want to generate some load, but not required for autoscaling.

```sh
kubectl run -i --tty load-generator --rm --image=busybox:1.28 --restart=Never -- /bin/sh -c "while true; do wget -q -O- http://nginx-demo.nginx-demo.svc.cluster.local:8080; done"
```

## Destroy the Kubernetes Add-ons, EKS cluster with Node groups and VPC
Delete all of the images from the ECR repo, or it cannot be deleted.

```sh
terraform destroy -target="module.eks_blueprints_kubernetes_addons" -auto-approve
terraform destroy -target="module.eks_blueprints" -auto-approve
terraform destroy -target="module.vpc" -auto-approve
```

Finally, destroy any additional resources that are not in the above modules

```sh
terraform destroy -auto-approve
```

# ToDo
- Reduce permissions from eks:* in hpa_irsa_policy