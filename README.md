# 🚀 Free Kubernetes Cluster on Oracle Cloud with Terraform

This repository contains the **Terraform code** to create a fully functional Kubernetes cluster on Oracle Cloud Infrastructure (OCI) using a modular approach. The infrastructure is organized into several Terraform modules that handle different aspects of the deployment:

## 🧩 Modules

- `oci-vcn`: Creates the Virtual Cloud Network (VCN), subnets, and security lists
- `oci-oke`: Sets up the Oracle Container Engine for Kubernetes (OKE) cluster and node pool
- `helm-releases`: Manages Helm releases for ArgoCD

## 📁 Project Structure

```
terraform/
├── tf-modules/
│   ├── helm-argocd/       # ArgoCD and ArgoCD-apps Helm chart deployments
│   ├── oci-oke/           # Kubernetes cluster and node pool
│   ├── oci-vcn/           # VCN and networking components
├── main.tf                # Main Terraform configuration
├── backend.tf             # Backend configuration
└── README.md              # This file
```

## ⚡ Quick Setup Guide

1. **Retrieve** the following information from your Oracle Cloud account:

   - User OCID
   - Tenancy OCID
   - Compartment OCID

2. **Export** the following environment variables in your shell:

   ```bash
   export TF_VAR_compartment_id=ocid1.tenancy.oc1..etc...
   export TF_VAR_region=eu-madrid-1
   ```

3. **State file backend configuration:**

   - If you want to use the **OCI backend** (similar to S3 backend), create the bucket manually from the Oracle Cloud Console UI [buckets](https://cloud.oracle.com/object-storage/buckets). Then set up the bucket name and namespace in the `backend.tf` file (both are provided when the bucket is created).
   - If you want to use **local backend**, simply delete the `backend.tf` file and continue.

4. **Initialize** Terraform:

   ```bash
   terraform init
   ```

5. **Apply** the Terraform configuration:

   ```bash
   terraform apply
   ```

6. **Generate** your Kubernetes configuration file (the command can also be found on the OCI console):

   ```bash
   oci ce cluster create-kubeconfig --cluster-id <cluster OCID> --file ~/.kube/free-k8s-config --region <region> --token-version 2.0.0 --kube-endpoint PUBLIC_ENDPOINT
   ```

7. **Set** the KUBECONFIG environment variable:

   ```bash
   export KUBECONFIG=~/.kube/free-k8s-config
   ```

8. **Verify** access to your cluster:
   ```bash
   kubectl get nodes
   ```

## 💰 Resource Configuration

The default configuration uses the following resources from the **Oracle Always Free tier**:

- **2 nodes** with 1 OCPU and 6GB memory each (total: 2 OCPUs, 12GB memory)
- This is half of the maximum free resources (4 OCPUs, 24GB memory total)

## ⚠️ Handling "Out of Capacity" Issues

If you encounter the _"Out of Capacity"_ issue when trying to create resources:

1. **Use the provided script** to retry automatically:

   ```bash
   ./oci_nodepool_spam_create_script.sh
   ```

2. Or **upgrade** to a Pay-as-you-go account while still using free resources

## 🔄 ArgoCD Deployment (Optional)

The `helm-argocd` module is responsible for deploying [**Argo CD**](https://argo-cd.readthedocs.io/) and the [**argocd-apps**](https://github.com/argoproj/argo-helm/tree/main/charts/argocd-apps) Helm chart into your Kubernetes cluster using Terraform and the Helm provider. This enables **GitOps workflows** for managing your Kubernetes resources.

### **Features:**

- ✅ Installs Argo CD in the `argo-cd` namespace
- ✅ Installs the `argocd-apps` chart for managing multiple Argo CD Applications declaratively
- ✅ Uses values files for custom configuration

If you choose to deploy argoCD and argoCD-apps, change the:
`applications.app-of-apps.source.repoURL` from `tf-modules\helm-argocd\helm-values\argocd-apps_values.yaml` to your app of apps git repository url. My repo that you can use as refetence is [this one](https://github.com/ricardllop/argocd-app-of-apps).

On the values.yml of the argocd-app-of-apps you can add the list of argo-cd apps (kubernetes deployments) that you want Argo-cd to manage.

## 🔄 Cluster Update Guidelines

As the setup is **completely declarative** and everything gets **practically auto-deployed** with a `terraform apply`, the best way to perform cluster updates is **recreating the cluster entirely**.

The changes needed to perform the update are the following:

1. **Destroy** the cluster and the ArgoCD Helm deployment. The easiest way is commenting out from the `main.tf` file both: `module "oke" {}` and `module "helm-argocd" {}`. Make sure no leftovers are up on the Oracle Cloud console - normally the NLB is not deleted automatically.

2. **Change** in the `oci-oke` module, the `local.kubernetes_version` to the desired target version.

3. **Update** the node image:
   ```hcl
   node_source_details {
     image_id = "ocid1.image.oc1.eu-madrid-1.xxxxxxxxxxx"
   }
   ```
   Choose one from: https://docs.oracle.com/en-us/iaas/images/oke-worker-node-oracle-linux-8x/index.htm that has the target Kubernetes version and **aarch64 / ARM** architecture.
