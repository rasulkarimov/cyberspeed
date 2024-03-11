# Full Stack MyBlog Application
This guide provides step-by-step instructions for provisioning a Kubernetes cluster using Terraform. Before you begin, ensure that you have the following tools installed locally: terraform, aws, docker, helm, kubectl

## Provisioning a Kubernetes Cluster using Terraform
To get started, follow these steps:

Inspect the variable-defined files in the `cyberspeed.tfvars` file. Note that the modules are under development, and it's not tested with other variables. To avoid issues, refrain from making changes to these variables:
~~~
cd terraform/project/cyberspeed
cat cyberspeed.tfvars
~~~

Install infrustructure:
~~~
terraform init
terraform plan
terraform apply -var-file=cyberspeed.tfvars
~~~

When EKS cluster installed, authenticate into EKS cluster:
~~~
aws eks update-kubeconfig --name cyberspeed --region eu-north-1
~~~

Inspect the cluster nodes and pods
~~~
kubectl get nodes
kubectl get pods -n kube-system
~~~

## Deploy application by Helm 
This part is already included in Terraform with `null_resource.docker_packaging_helm_install` Below allows for manual chart updates or troubleshooting in case of any problems during Terraform installation.

Inspect `values.yaml` File in "myblog-helm-charts" Directory. Make sure that the correct image repositories are defined in myblog.image.repository and myblog.image.repository:
~~~
cd ../../../myblog-helm-charts/
cat values.yaml
~~~
Deploy application with Helm:
~~~
helm upgrade --install --namespace=staging --create-namespace  cyberspeed ./
~~~

Inspect that pods were created:
~~~
kubectl get pods -n=staging
~~~

Get URL and heck availability:
~~~
echo "http://$(kubectl get svc nginx-lb -o jsonpath='{.status.loadBalancer.ingress[0].hostname}'  -n=staging):8090"
~~~

During the initial installation, the 'initDb' job runs to initialize the PostgreSQL database. Ensure that this job completes successfully. If any issues arise, to rerun the job, set "myblog.initDbJob.force" to "true" in the values.yaml file and then rerun the 'helm upgrade' command.
