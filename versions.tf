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
    host                   = module.cluster_1.host
    client_certificate     = module.cluster_1.client_certificate
    client_key             = module.cluster_1.client_key
    cluster_ca_certificate = module.cluster_1.cluster_ca_certificate
  }
}

provider "helm" {
  alias = "mesh2"
  kubernetes {
    host                   = module.cluster_2.host
    client_certificate     = module.cluster_2.client_certificate
    client_key             = module.cluster_2.client_key
    cluster_ca_certificate = module.cluster_2.cluster_ca_certificate
  }
}

#provider "kubectl" {
#  host                   = azurerm_kubernetes_cluster.this.kube_config[0].host
#  client_certificate     = base64decode(azurerm_kubernetes_cluster.this.kube_config[0].client_certificate)
#  client_key             = base64decode(azurerm_kubernetes_cluster.this.kube_config[0].client_key)
#  cluster_ca_certificate = base64decode(azurerm_kubernetes_cluster.this.kube_config[0].cluster_ca_certificate)
#  load_config_file       = false
#}
