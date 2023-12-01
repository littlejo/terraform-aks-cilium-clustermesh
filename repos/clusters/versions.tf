data "azurerm_kubernetes_cluster" "this" {
  name                = var.aks.mesh1.name
  resource_group_name = var.resource_group_name
}


terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "3.82.0"
    }
    local = {
      source  = "hashicorp/local"
      version = "2.4.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "2.11.0"
    }
    kubectl = {
      source  = "gavinbunney/kubectl"
      version = "1.14.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "2.24.0"
    }
  }
  required_version = ">= 1.3"
}

provider "azurerm" {
  skip_provider_registration = true
  features {}
}

provider "helm" {
  alias = "mesh1"
  kubernetes {
    host                   = data.azurerm_kubernetes_cluster.this.kube_config[0].host
    username               = data.azurerm_kubernetes_cluster.this.kube_config[0].username
    password               = data.azurerm_kubernetes_cluster.this.kube_config[0].password
    client_certificate     = base64decode(data.azurerm_kubernetes_cluster.this.kube_config[0].client_certificate)
    client_key             = base64decode(data.azurerm_kubernetes_cluster.this.kube_config[0].client_key)
    cluster_ca_certificate = base64decode(data.azurerm_kubernetes_cluster.this.kube_config[0].cluster_ca_certificate)
  }
}

provider "helm" {
  alias = "mesh2"
  kubernetes {
    host                   = module.aks.host
    client_certificate     = module.aks.client_certificate
    client_key             = module.aks.client_key
    cluster_ca_certificate = module.aks.cluster_ca_certificate
  }
}

provider "kubernetes" {
  alias                  = "mesh1"
  host                   = data.azurerm_kubernetes_cluster.this.kube_config[0].host
  username               = data.azurerm_kubernetes_cluster.this.kube_config[0].username
  password               = data.azurerm_kubernetes_cluster.this.kube_config[0].password
  client_certificate     = base64decode(data.azurerm_kubernetes_cluster.this.kube_config[0].client_certificate)
  client_key             = base64decode(data.azurerm_kubernetes_cluster.this.kube_config[0].client_key)
  cluster_ca_certificate = base64decode(data.azurerm_kubernetes_cluster.this.kube_config[0].cluster_ca_certificate)
}

provider "kubernetes" {
  alias                  = "mesh2"
  host                   = module.aks.host
  client_certificate     = module.aks.client_certificate
  client_key             = module.aks.client_key
  cluster_ca_certificate = module.aks.cluster_ca_certificate
}
