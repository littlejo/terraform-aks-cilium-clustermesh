# terraform-aks-cilium-clustermesh
Create a clustermesh with cilium on AKS

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.3 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | 3.82.0 |
| <a name="requirement_helm"></a> [helm](#requirement\_helm) | 2.11.0 |
| <a name="requirement_kubectl"></a> [kubectl](#requirement\_kubectl) | 1.14.0 |
| <a name="requirement_local"></a> [local](#requirement\_local) | 2.4.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_local"></a> [local](#provider\_local) | 2.4.0 |
| <a name="provider_terraform"></a> [terraform](#provider\_terraform) | n/a |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_aks"></a> [aks](#module\_aks) | ./modules/aks | n/a |
| <a name="module_cilium_enable_mesh1"></a> [cilium\_enable\_mesh1](#module\_cilium\_enable\_mesh1) | ./modules/cilium-clustermesh | n/a |
| <a name="module_cilium_enable_mesh2"></a> [cilium\_enable\_mesh2](#module\_cilium\_enable\_mesh2) | ./modules/cilium-clustermesh | n/a |
| <a name="module_cilium_mesh1"></a> [cilium\_mesh1](#module\_cilium\_mesh1) | ./modules/cilium | n/a |
| <a name="module_cilium_mesh2"></a> [cilium\_mesh2](#module\_cilium\_mesh2) | ./modules/cilium | n/a |
| <a name="module_peering"></a> [peering](#module\_peering) | ./modules/peering | n/a |
| <a name="module_vnet"></a> [vnet](#module\_vnet) | ./modules/network | n/a |

## Resources

| Name | Type |
|------|------|
| [local_file.kubeconfig_aks_1](https://registry.terraform.io/providers/hashicorp/local/2.4.0/docs/resources/file) | resource |
| [local_file.kubeconfig_aks_2](https://registry.terraform.io/providers/hashicorp/local/2.4.0/docs/resources/file) | resource |
| [terraform_data.enable_mesh1_mesh2](https://registry.terraform.io/providers/hashicorp/terraform/latest/docs/resources/data) | resource |
| [terraform_data.kubeconfig_global](https://registry.terraform.io/providers/hashicorp/terraform/latest/docs/resources/data) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_aks"></a> [aks](#input\_aks) | Feature of aks | `any` | <pre>{<br>  "mesh1": {<br>    "kubeconfig": "kubeconfig-cluster1",<br>    "name": "cilium-clustermesh1",<br>    "network_profile": {<br>      "dns_service_ip": "10.11.0.10",<br>      "service_cidr": "10.11.0.0/16"<br>    },<br>    "version": "1.27"<br>  },<br>  "mesh2": {<br>    "kubeconfig": "kubeconfig-cluster2",<br>    "name": "cilium-clustermesh2",<br>    "network_profile": {<br>      "dns_service_ip": "10.21.0.10",<br>      "service_cidr": "10.21.0.0/16"<br>    },<br>    "version": "1.27"<br>  }<br>}</pre> | no |
| <a name="input_cilium"></a> [cilium](#input\_cilium) | Feature of cilium | <pre>map(object({<br>    type                   = string<br>    version                = optional(string, "1.14.3")<br>    kube-proxy-replacement = optional(bool, false)<br>    ebpf-hostrouting       = optional(bool, false)<br>    hubble                 = optional(bool, false)<br>    hubble-ui              = optional(bool, false)<br>    gateway-api            = optional(bool, false)<br>    preflight-version      = optional(string, null)<br>    upgrade-compatibility  = optional(string, null)<br>    set_values             = optional(list(object({ name = string, value = string })))<br>  }))</pre> | <pre>{<br>  "mesh1": {<br>    "ebpf-hostrouting": true,<br>    "hubble": true,<br>    "kube-proxy-replacement": true,<br>    "set_values": [<br>      {<br>        "name": "cluster.id",<br>        "value": "1"<br>      },<br>      {<br>        "name": "cluster.name",<br>        "value": "cilium-clustermesh1"<br>      },<br>      {<br>        "name": "ipam.operator.clusterPoolIPv4PodCIDRList",<br>        "value": "{10.10.0.0/16}"<br>      }<br>    ],<br>    "type": "cilium_custom",<br>    "version": "1.14.3"<br>  },<br>  "mesh2": {<br>    "ebpf-hostrouting": true,<br>    "hubble": true,<br>    "kube-proxy-replacement": true,<br>    "set_values": [<br>      {<br>        "name": "cluster.id",<br>        "value": "2"<br>      },<br>      {<br>        "name": "cluster.name",<br>        "value": "cilium-clustermesh2"<br>      },<br>      {<br>        "name": "ipam.operator.clusterPoolIPv4PodCIDRList",<br>        "value": "{10.20.0.0/16}"<br>      }<br>    ],<br>    "type": "cilium_custom",<br>    "version": "1.14.3"<br>  }<br>}</pre> | no |
| <a name="input_location"></a> [location](#input\_location) | Location | `string` | n/a | yes |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | Resource group name | `string` | n/a | yes |
| <a name="input_vnet"></a> [vnet](#input\_vnet) | Feature of vnet | `any` | <pre>{<br>  "mesh1": {<br>    "address_space": [<br>      "192.168.10.0/24"<br>    ],<br>    "name": "clustermesh1",<br>    "subnet_cidr": [<br>      "192.168.10.0/24"<br>    ],<br>    "subnet_name": "nodesubnet"<br>  },<br>  "mesh2": {<br>    "address_space": [<br>      "192.168.20.0/24"<br>    ],<br>    "name": "clustermesh2",<br>    "subnet_cidr": [<br>      "192.168.20.0/24"<br>    ],<br>    "subnet_name": "nodesubnet"<br>  }<br>}</pre> | no |

## Outputs

No outputs.
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->