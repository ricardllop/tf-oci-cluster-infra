# Free Kubernetes Cluster on Oracle Cloud with Terraform

This repository contains a Terraform script to create a fully functional Kubernetes cluster on Oracle Cloud.

## Quick Setup Guide

1. Retrieve the following information from your Oracle Cloud account:
    - User OCID
    - Tenancy OCID
    - Compartment OCID
2. Export a the following environment variables in your shell... (This will be used by the terraform vars) variables.tf
    ```
    export TF_VAR_compartment_id=ocid1.tenancy.oc1..etc...
    export TF_VAR_region=eu-madrid-1
    export TF_VAR_ssh_public_key="ssh-rsa etc..."
    ```
3. Open a terminal in the `tf-oci-cluster-infra` directory.
4. Initialize Terraform:
    ```bash
    terraform init
    ```
5. Apply the Terraform configuration:
    ```bash
    terraform apply
    ```
6. Generate your Kubernetes configuration file:
    ```bash
    oci ce cluster create-kubeconfig --cluster-id <cluster OCID> --file ~/.kube/free-k8s-config --region <region> --token-version 2.0.0 --kube-endpoint PUBLIC_ENDPOINT
    ```
7. Set the KUBECONFIG environment variable for kubectl:
    ```bash
    export KUBECONFIG=~/.kube/free-k8s-config
    ```
8. Verify access to your cluster:
    ```bash
    kubectl get nodes
    ```
9. Enjoy your free Kubernetes cluster on Oracle Cloud!

## Extra notes

You might find the classical Oracle Cloud problem: Oracle Cloud “Out of Capacity” issue, not allowing you to request the free free VPS with 4 ARM cores / 24GB of memory (In our case the nodepool)

To overcome this you have 2 options:
- Simply retrying constantly until some capacity is freed and you can provision some with you free account. This can be done by running this script: ```oci_nodepool_spam_create_script.sh```
That basically will run the tf apply on a loop. Until it succeds.

- Upgrade your account to Pay as you go. With this account type you can still enjoy the free resources normally, and only be charged if you request some resource out of the free offering. (This is what I did)