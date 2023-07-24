
Terraform module for deploying [external-dns](https://artifacthub.io/packages/helm/bitnami/external-dns), this enables to use AWS Secrets Manager and SSM Parameters inside a pre-existing EKS cluster.

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
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
