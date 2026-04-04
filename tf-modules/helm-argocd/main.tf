

data "oci_containerengine_cluster_kube_config" "k8s_cluster_kube_config" {
	cluster_id =  var.cluster_id
}

locals {
  kubeconfig_content = replace(data.oci_containerengine_cluster_kube_config.k8s_cluster_kube_config.content, "\\n", "\n")
  kubeconfig         = yamldecode(local.kubeconfig_content)
}

provider "kubernetes" {
  host                   = local.kubeconfig.clusters[0].cluster.server
  cluster_ca_certificate = base64decode(local.kubeconfig.clusters[0].cluster.certificate-authority-data)

  exec {
    api_version = local.kubeconfig.users[0].user.exec.apiVersion
    command     = local.kubeconfig.users[0].user.exec.command
    args        = local.kubeconfig.users[0].user.exec.args
  }
  
}

provider "helm" {
  kubernetes = {
    host                   = local.kubeconfig.clusters[0].cluster.server
    cluster_ca_certificate = base64decode(local.kubeconfig.clusters[0].cluster.certificate-authority-data)

    exec = {
      api_version = local.kubeconfig.users[0].user.exec.apiVersion
      command     = local.kubeconfig.users[0].user.exec.command
      args        = local.kubeconfig.users[0].user.exec.args
    }
  }
}

# Creation of secret for tailscale
resource "kubernetes_namespace_v1" "tailscale" {
  count = var.create && var.tailscale_oauth_clientid != null && var.tailscale_oauth_secret != null ? 1 : 0
  metadata {
    name = "tailscale-operator"
  }
}

resource "kubernetes_secret_v1" "tailscale_operator_oauth" {
  count = var.create && var.tailscale_oauth_clientid != null && var.tailscale_oauth_secret != null ? 1 : 0
  metadata {
    name      = "operator-oauth"
    namespace = kubernetes_namespace_v1.tailscale[0].metadata[0].name
  }

  data = {
    client_id     = var.tailscale_oauth_clientid
    client_secret = var.tailscale_oauth_secret
  }
}

resource "helm_release" "argo-cd" {
  count   = var.create ? 1 : 0
  name             = "argo-cd"
  chart            = "argo-cd"
  repository       = "https://argoproj.github.io/argo-helm"
  version          = "9.4.17"
  # https://github.com/argoproj/argo-helm/tree/main/charts/argo-cd
  
  create_namespace  = true
  namespace         = "argo-cd"
  
  values = [
    templatefile("${path.module}/helm-values/argo-cd_values.yaml", {
      namespace                 = "argo-cd"
    })
  ]
}

resource "helm_release" "argocd-apps" {
  count   = var.create ? 1 : 0
  name             = "argocd-apps"
  chart            = "argocd-apps"
  repository       = "https://argoproj.github.io/argo-helm"
  version          = "2.0.4"
  #https://github.com/argoproj/argo-helm/tree/main/charts/argocd-apps
  
  create_namespace  = true
  namespace         = "argo-cd"

  values = [
    templatefile("${path.module}/helm-values/argocd-apps_values.yaml", {
      namespace                 = "argo-cd"
    })
  ]

  depends_on = [helm_release.argo-cd]
}