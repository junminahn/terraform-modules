output "domain_name" {
  value = aws_acm_certificate.this.domain_name
}

output "load_balancer_dns_name" {
  value = data.aws_elb.this.dns_name
}
