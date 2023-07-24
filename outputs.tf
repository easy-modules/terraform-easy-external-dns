output "external_dns_iam_role_name" {
  description = "The name of the role"
  value       = aws_iam_role.external_dns_iam_role.name
}

output "external_dns_iam_role_arn" {
  description = "The Amazon Resource Name (ARN) specifying the role"
  value       = aws_iam_role.external_dns_iam_role.arn
}
