
Terraform module for deploying [external-dns](https://artifacthub.io/packages/helm/bitnami/external-dns).

## Usage
```hcl
module "external_dns" {
  source               = "./<PATH_TO_MODULE>"
  dns_zone             = ["example.com", "example2.com"]
  cluster_name         = "eks-cluster-name"
  # optionals
  cloudflare_enabled   = true
  cloudflare_api_key   = "cloudflare-api-key" 
  cloudflare_api_email = "cloudflare-api-email" 
  node_selector = {
    "node-role.kubernetes.io/worker": "true"
  }
}
```
<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 0.13.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | 5.0.1 |
| <a name="requirement_kubectl"></a> [kubectl](#requirement\_kubectl) | >= 1.10.0 |
| <a name="requirement_kubernetes"></a> [kubernetes](#requirement\_kubernetes) | 2.12.1 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 5.0.1 |
| <a name="provider_kubernetes"></a> [kubernetes](#provider\_kubernetes) | 2.12.1 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_iam_policy.external_dns_iam_policy](https://registry.terraform.io/providers/hashicorp/aws/5.0.1/docs/resources/iam_policy) | resource |
| [aws_iam_role.external_dns_iam_role](https://registry.terraform.io/providers/hashicorp/aws/5.0.1/docs/resources/iam_role) | resource |
| [aws_iam_role_policy_attachment.external_dns_attach_policy](https://registry.terraform.io/providers/hashicorp/aws/5.0.1/docs/resources/iam_role_policy_attachment) | resource |
| [kubernetes_cluster_role_binding_v1.external_dns](https://registry.terraform.io/providers/hashicorp/kubernetes/2.12.1/docs/resources/cluster_role_binding_v1) | resource |
| [kubernetes_cluster_role_v1.external_dns](https://registry.terraform.io/providers/hashicorp/kubernetes/2.12.1/docs/resources/cluster_role_v1) | resource |
| [kubernetes_deployment_v1.cloudflare_external_dns](https://registry.terraform.io/providers/hashicorp/kubernetes/2.12.1/docs/resources/deployment_v1) | resource |
| [kubernetes_deployment_v1.route53_external_dns](https://registry.terraform.io/providers/hashicorp/kubernetes/2.12.1/docs/resources/deployment_v1) | resource |
| [kubernetes_namespace_v1.external_dns](https://registry.terraform.io/providers/hashicorp/kubernetes/2.12.1/docs/resources/namespace_v1) | resource |
| [kubernetes_service_account_v1.external_dns](https://registry.terraform.io/providers/hashicorp/kubernetes/2.12.1/docs/resources/service_account_v1) | resource |
| [kubernetes_service_v1.cloudflare_external_dns](https://registry.terraform.io/providers/hashicorp/kubernetes/2.12.1/docs/resources/service_v1) | resource |
| [kubernetes_service_v1.route53_external_dns](https://registry.terraform.io/providers/hashicorp/kubernetes/2.12.1/docs/resources/service_v1) | resource |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/5.0.1/docs/data-sources/caller_identity) | data source |
| [aws_eks_cluster.eks](https://registry.terraform.io/providers/hashicorp/aws/5.0.1/docs/data-sources/eks_cluster) | data source |
| [aws_iam_policy_document.external_dns_assume_role_policy](https://registry.terraform.io/providers/hashicorp/aws/5.0.1/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.external_dns_policy](https://registry.terraform.io/providers/hashicorp/aws/5.0.1/docs/data-sources/iam_policy_document) | data source |
| [aws_partition.current](https://registry.terraform.io/providers/hashicorp/aws/5.0.1/docs/data-sources/partition) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_cloudflare_api_email"></a> [cloudflare\_api\_email](#input\_cloudflare\_api\_email) | Cloudflare API Email | `string` | `null` | no |
| <a name="input_cloudflare_api_key"></a> [cloudflare\_api\_key](#input\_cloudflare\_api\_key) | Cloudflare API Key | `string` | `null` | no |
| <a name="input_cloudflare_enabled"></a> [cloudflare\_enabled](#input\_cloudflare\_enabled) | Enable Cloudflare DNS | `bool` | `false` | no |
| <a name="input_cluster_name"></a> [cluster\_name](#input\_cluster\_name) | Cluster Name | `string` | n/a | yes |
| <a name="input_dns_zone"></a> [dns\_zone](#input\_dns\_zone) | DNS Zone | `list(string)` | n/a | yes |
| <a name="input_external_dns_name"></a> [external\_dns\_name](#input\_external\_dns\_name) | External DNS Name | `string` | `"external-dns"` | no |
| <a name="input_namespace"></a> [namespace](#input\_namespace) | Namespace for the External DNS deployment | `string` | `"external-dns-system"` | no |
| <a name="input_node_selector"></a> [node\_selector](#input\_node\_selector) | Node labels for K8S Pod assignment of the Deployments/StatefulSets/DaemonSets | `string` | `null` | no |
| <a name="input_role_tags"></a> [role\_tags](#input\_role\_tags) | Role Tags | `map(any)` | `{}` | no |
| <a name="input_service_account_name"></a> [service\_account\_name](#input\_service\_account\_name) | Service Account Name | `string` | `"external-dns-sa"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_external_dns_iam_role_arn"></a> [external\_dns\_iam\_role\_arn](#output\_external\_dns\_iam\_role\_arn) | The Amazon Resource Name (ARN) specifying the role |
| <a name="output_external_dns_iam_role_name"></a> [external\_dns\_iam\_role\_name](#output\_external\_dns\_iam\_role\_name) | The name of the role |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
