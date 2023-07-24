data "aws_caller_identity" "current" {}
data "aws_partition" "current" {}
data "aws_eks_cluster" "eks" {
  name = var.cluster_name
}

locals {
  eks_oidc_issuer = trimprefix(data.aws_eks_cluster.eks.identity[0].oidc[0].issuer, "https://")
  account_id      = data.aws_caller_identity.current.account_id
  partition       = data.aws_partition.current.partition
  tags = {
    Terraform = "true"
    ManagedBy = "Terraform"
  }
}

#==============================================================================
# AWS IAM ROLES
#==============================================================================
data "aws_iam_policy_document" "external_dns_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    effect  = "Allow"
    principals {
      type        = "Federated"
      identifiers = ["arn:${local.partition}:iam::${local.account_id}:oidc-provider/${local.eks_oidc_issuer}"]
    }
    condition {
      test     = "StringEquals"
      variable = "${local.eks_oidc_issuer}:sub"
      values   = ["system:serviceaccount:${var.namespace}:${var.service_account_name}"]
    }
  }
}
data "aws_iam_policy_document" "external_dns_policy" {
  statement {
    actions   = ["route53:ListTagsForResource", "route53:ListResourceRecordSets", "route53:ListHostedZones"]
    effect    = "Allow"
    resources = ["*"]
  }
}
resource "aws_iam_policy" "external_dns_iam_policy" {
  name        = format("%s-policy", var.external_dns_name)
  description = "Policy for External Secrets"
  policy      = data.aws_iam_policy_document.external_dns_policy.json
}
resource "aws_iam_role" "external_dns_iam_role" {
  name               = format("%s-role", var.external_dns_name)
  description        = "Role for External Secrets"
  assume_role_policy = data.aws_iam_policy_document.external_dns_assume_role_policy.json
  tags               = merge(local.tags, var.role_tags)
}
resource "aws_iam_role_policy_attachment" "external_dns_attach_policy" {
  role       = aws_iam_role.external_dns_iam_role.name
  policy_arn = aws_iam_policy.external_dns_iam_policy.arn
}
#==============================================================================
# KUBERNETES NAMESPACE
#==============================================================================
resource "kubernetes_namespace_v1" "external_dns" {
  metadata {
    annotations = {
      name = var.namespace
    }
    name = var.namespace
  }
}
#==============================================================================
# KUBERNETES ROLES
#==============================================================================
resource "kubernetes_service_account_v1" "external_dns" {
  automount_service_account_token = true
  metadata {
    name      = var.service_account_name
    namespace = var.namespace
    labels = {
      "app.kubernetes.io/name" = var.service_account_name
    }
    annotations = {
      "eks.amazonaws.com/role-arn" = aws_iam_role.external_dns_iam_role.arn
    }
  }
}
resource "kubernetes_cluster_role_v1" "external_dns" {
  metadata {
    name = "external-dns"
  }

  rule {
    api_groups = [""]
    resources  = ["nodes"]
    verbs      = ["get", "watch", "list"]
  }

  rule {
    api_groups = ["extensions", "networking", "networking.k8s.io"]
    resources  = ["ingresses"]
    verbs      = ["get", "watch", "list"]
  }

  rule {
    api_groups = [""]
    resources  = ["services"]
    verbs      = ["get", "watch", "list"]
  }

  rule {
    api_groups = [""]
    resources  = ["endpoints"]
    verbs      = ["get", "watch", "list"]
  }

  rule {
    api_groups = [""]
    resources  = ["pods"]
    verbs      = ["get", "watch", "list"]
  }
}
resource "kubernetes_cluster_role_binding_v1" "external_dns" {
  metadata {
    name = "external-dns-viewer"
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = kubernetes_cluster_role_v1.external_dns.metadata[0].name
  }
  subject {
    kind      = "ServiceAccount"
    name      = kubernetes_service_account_v1.external_dns.metadata[0].name
    namespace = kubernetes_namespace_v1.external_dns.metadata[0].name
  }
}
#==============================================================================
# KUBERNETES DEPLOY ROUTE53 EXTERNAL DNS
#==============================================================================
resource "kubernetes_deployment_v1" "route53_external_dns" {
  depends_on = [
    kubernetes_cluster_role_binding_v1.external_dns
  ]
  metadata {
    name      = var.external_dns_name
    namespace = kubernetes_namespace_v1.external_dns.metadata[0].name
    labels = {
      "app.kubernetes.io/name" = var.external_dns_name
    }
  }
  spec {
    replicas = 1
    strategy {
      type = "RollingUpdate"
    }
    selector {
      match_labels = {
        "app.kubernetes.io/name" = var.external_dns_name
      }
    }
    template {
      metadata {
        labels = {
          "app.kubernetes.io/name" = var.external_dns_name
        }
      }
      spec {
        service_account_name = kubernetes_service_account_v1.external_dns.metadata[0].name
        container {
          name              = "external-dns"
          image             = "registry.k8s.io/external-dns/external-dns:v0.13.1"
          image_pull_policy = "IfNotPresent"
          args = [
            "--policy=sync",
            "--source=service",
            "--source=ingress",
            "--txt-owner-id=${var.cluster_name}",
            "--txt-prefix=edns-",
            "--registry=txt",
            "--provider=aws",
            "--aws-zone-type=public",
            "--domain-filter=${var.dns_zone[0]}"
          ]
          port {
            name           = "http"
            protocol       = "TCP"
            container_port = "7979"
          }
        }

        node_selector = {
          "kube/nodetype" = var.node_selector
        }
        restart_policy = "Always"
      }
    }
  }
}
resource "kubernetes_service_v1" "route53_external_dns" {
  depends_on = [kubernetes_deployment_v1.cloudflare_external_dns]

  metadata {
    name      = var.external_dns_name
    namespace = kubernetes_namespace_v1.external_dns.metadata[0].name
    labels = {
      "app.kubernetes.io/name" = var.external_dns_name
    }
  }

  spec {
    selector = {
      "app.kubernetes.io/name" = var.external_dns_name
    }

    type = "ClusterIP"
    port {
      name        = "http"
      protocol    = "TCP"
      port        = "7979"
      target_port = "http"
    }
  }
}
#==============================================================================
# KUBERNETES DEPLOY CLOUDFLARE EXTERNAL DNS
#==============================================================================
resource "kubernetes_deployment_v1" "cloudflare_external_dns" {
  count      = var.cloudflare_enabled == true ? 1 : 0
  depends_on = [kubernetes_cluster_role_binding_v1.external_dns]

  metadata {
    name      = "${var.external_dns_name}-cloudflare"
    namespace = kubernetes_namespace_v1.external_dns.metadata[0].name
    labels = {
      "app.kubernetes.io/name" = "${var.external_dns_name}-cloudflare"
    }
  }

  spec {
    replicas = 1
    strategy {
      type = "RollingUpdate"
    }

    selector {
      match_labels = {
        "app.kubernetes.io/name" = "${var.external_dns_name}-cloudflare"
      }
    }

    template {
      metadata {
        labels = {
          "app.kubernetes.io/name" = "${var.external_dns_name}-cloudflare"
        }
      }
      spec {
        service_account_name = kubernetes_service_account_v1.external_dns.metadata[0].name

        container {
          name              = "external-dns"
          image             = "registry.k8s.io/external-dns/external-dns:v0.13.1"
          image_pull_policy = "IfNotPresent"
          args = [
            "--policy=sync",
            "--source=service",
            "--source=ingress",
            "--txt-owner-id=${var.cluster_name}",
            "--txt-prefix=edns-",
            "--registry=txt",
            "--provider=cloudflare",
            "--domain-filter=${var.dns_zone[1]}"
          ]

          env {
            name  = "CF_API_KEY"
            value = var.cloudflare_api_key
          }
          env {
            name  = "CF_API_EMAIL"
            value = var.cloudflare_api_email
          }

          port {
            name           = "http"
            protocol       = "TCP"
            container_port = "7979"
          }
        }

        node_selector = {
          "kube/nodetype" = var.node_selector
        }

        restart_policy = "Always"
      }
    }
  }
}
resource "kubernetes_service_v1" "cloudflare_external_dns" {
  count      = var.cloudflare_enabled == true ? 1 : 0
  depends_on = [kubernetes_deployment_v1.cloudflare_external_dns]
  metadata {
    name      = var.external_dns_name
    namespace = kubernetes_namespace_v1.external_dns.metadata[0].name
    labels = {
      "app.kubernetes.io/name" = var.external_dns_name
    }
  }
  spec {
    selector = {
      "app.kubernetes.io/name" = var.external_dns_name
    }
    type = "ClusterIP"
    port {
      name        = "http"
      protocol    = "TCP"
      port        = "7979"
      target_port = "http"
    }
  }
}
