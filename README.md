# k8s-time-based-scaling
Based of the [EKS Cluster with Karpenter Cluster Autoscaler](https://github.com/aws-ia/terraform-aws-eks-blueprints/tree/main/examples/karpenter) example, this depoys a Horizontal Pod Autoscaler for NGINX and uses CronJobs to update the `minReplicas` for time based autoscaling with Karpenter, while still allowing load generated autoscaling.

Inspired by [Time Based Scaling for Kubernetes Deployments](https://medium.com/symbl-ai-engineering-and-data-science/time-based-scaling-for-kubernetes-deployments-9ef7ada93eb7).

# How to Deploy

## Prerequisites:

Ensure that you have installed the following tools in your Mac or Windows Laptop before start working with this module and run Terraform Plan and Apply

1. [aws cli](https://docs.aws.amazon.com/cli/latest/userguide/install-cliv2.html)
2. [kubectl](https://Kubernetes.io/docs/tasks/tools/)
3. [terraform](https://learn.hashicorp.com/tutorials/terraform/install-cli)

### AWSServiceRoleForEC2Spot
Amazon EC2 uses the service-linked role named [AWSServiceRoleForEC2Spot](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/spot-requests.html#service-linked-roles-spot-instance-requests) to launch and manage Spot Instances on your behalf. This needs to be created in advance, as there can only be a single instance per account, and it is not easily managed with [Terraform](https://github.com/hashicorp/terraform/issues/23178).

**Check for AWSServiceRoleForEC2Spot**
```sh
aws iam get-role --role-name AWSServiceRoleForEC2Spot
```

**Create AWSServiceRoleForEC2Spot**
```sh
aws iam create-service-linked-role --aws-service-name spot.amazonaws.com
```

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

**Note:** If you plan to interact with your resources using the AWS CLI when using an MFA device, then you must create a [temporary session](https://aws.amazon.com/premiumsupport/knowledge-center/authenticate-mfa-cli/).

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
kubectl run -i --tty load-generator --rm --image=busybox:1.28 --restart=Never -- /bin/sh -c "while true; do wget -q -O- http://nginx-demo.nginx-demo.svc.cluster.local; done"
```

## Destroy the Kubernetes Add-ons, EKS cluster with Node groups and VPC
Delete all of the images from the ECR repo, or it cannot be deleted.

Delete the nginx-demo:
```sh
kubectl delete deployment,service,hpa nginx-demo -n nginx-demo
```

Wait for all `karpenter.sh/provisioner-name/default` EC2 nodes to be terminated (~5 minutes).

```sh
kubectl get nodes -l type=karpenter
No resources found
```

Destroy all resources:
```sh
terraform destroy
```

### Troubleshooting Failure to Destroy
The `terraform destroy` may fail if there are resources remaining in the namespace. If the resources are not deleted from the namespace the destroy may fail because of [this issue](https://medium.com/@cristi.posoiu/this-is-not-the-right-way-especially-in-a-production-environment-190ff670bc62).

```sh
module.irsa.kubernetes_namespace_v1.irsa[0]: Still destroying... [id=nginx-demo, 14m0s elapsed]
module.irsa.kubernetes_namespace_v1.irsa[0]: Still destroying... [id=nginx-demo, 14m10s elapsed]
module.irsa.kubernetes_namespace_v1.irsa[0]: Still destroying... [id=nginx-demo, 14m20s elapsed]
module.irsa.kubernetes_namespace_v1.irsa[0]: Still destroying... [id=nginx-demo, 14m30s elapsed]
module.irsa.kubernetes_namespace_v1.irsa[0]: Still destroying... [id=nginx-demo, 14m40s elapsed]
module.irsa.kubernetes_namespace_v1.irsa[0]: Still destroying... [id=nginx-demo, 14m50s elapsed]
╷
│ Error: context deadline exceeded
│ 
│ 
╵
```

For example, CronJob pods in an error state:
```sh
kubectl get pods -l component=nginx-scale -n kubectl
NAME                            READY   STATUS   RESTARTS   AGE
nginx-scale-up-27841320-58lzt   0/1     Error    0          82s
nginx-scale-up-27841320-d2l7l   0/1     Error    0          96s
nginx-scale-up-27841320-plnxh   0/1     Error    0          92s
```
Force delete the pods:
```sh
kubectl delete pod -l component=nginx-scale -n kubectl --grace-period=0 --force
Warning: Immediate deletion does not wait for confirmation that the running resource has been terminated. The resource may continue to run on the cluster indefinitely.
pod "nginx-scale-up-27841320-58lzt" force deleted
pod "nginx-scale-up-27841320-d2l7l" force deleted
pod "nginx-scale-up-27841320-plnxh" force deleted
```

You can check for details of the namespace such as a finalizer that prevents deletion, and a reason:
```sh
kubectl get namespace karpenter -o yaml
apiVersion: v1
kind: Namespace
metadata:
  creationTimestamp: "2022-12-08T06:39:25Z"
  deletionTimestamp: "2022-12-08T06:48:26Z"
  labels:
    kubernetes.io/metadata.name: karpenter
  name: karpenter
  resourceVersion: "5561"
  uid: 9271d80c-4e0c-4714-857d-2d7768d1d7e3
spec:
  **finalizers:
  - kubernetes**
status:
  conditions:
  - lastTransitionTime: "2022-12-08T06:48:32Z"
    message: All resources successfully discovered
    reason: ResourcesDiscovered
    status: "False"
    type: NamespaceDeletionDiscoveryFailure
  - lastTransitionTime: "2022-12-08T06:48:32Z"
    message: All legacy kube types successfully parsed
    reason: ParsedGroupVersions
    status: "False"
    type: NamespaceDeletionGroupVersionParsingFailure
  - lastTransitionTime: "2022-12-08T06:49:10Z"
    message: **'Failed to delete all resource types, 1 remaining: unexpected items still
      remain in namespace: karpenter for gvr: /v1, Resource=pods'**
    reason: ContentDeletionFailed
    status: "True"
    type: NamespaceDeletionContentFailure
  - lastTransitionTime: "2022-12-08T06:48:32Z"
    message: **'Some resources are remaining: pods. has 2 resource instances'**
    reason: SomeResourcesRemain
    status: "True"
    type: NamespaceContentRemaining
  - lastTransitionTime: "2022-12-08T06:48:32Z"
    message: All content-preserving finalizers finished
    reason: ContentHasNoFinalizers
    status: "False"
    type: NamespaceFinalizersRemaining
  phase: Terminating
```

Force delete all pods in an terminating state:
```sh
for i in `kubectl get pods -A --no-headers | grep -i terminating | awk '{ print $2 ":" $1 }'`; do; POD=$(echo $i | cut -d ":" -f 1); NAMESPACE=$(echo $i | cut -d ":" -f 2); kubectl delete pods $POD -n $NAMESPACE --grace-period=0 --force; done
```

# ToDo
- [Update the aws-node daemonset to use IRSA](https://aws.github.io/aws-eks-best-practices/security/docs/iam/#update-the-aws-node-daemonset-to-use-irsa)
- [Enable Amazon Inspector for ec2 and ecr](https://aws.github.io/aws-eks-best-practices/security/docs/network/#log-network-traffic-metadata)