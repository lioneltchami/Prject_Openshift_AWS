## Getting Started

To begin, follow these steps:

### Integrate with Your Tools

1. Clone the Git repository.
2. Update the access_key and secret_key in the "openshift.tf" file.
3. Execute the following commands:
```shell
docker build -t my-terraform-image .
docker run my-terraform-image
```

4. If the Docker container shows as exited, restart it with:
```shell
docker container start <container_name>
```

5. Once completed, proceed to AWS to verify EC2 instance creation and SSH into the EC2 instance.

```shell
./openshift-install create cluster --dir=cluster
export KUBECONFIG=cluster/auth/kubeconfig
export CLUSTER_NAME=my-cluster
export BASE_DOMAIN=sandbox.acme.com
./adjust-single-node.sh
```
