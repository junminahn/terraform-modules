data "aws_route53_zone" "this" {
  zone_id      = var.hosted_zone_id
  private_zone = false
}

resource "aws_acm_certificate" "this" {
  domain_name       = "${var.subdomain_name}.${data.aws_route53_zone.this.name}"
  validation_method = "DNS"

  tags = {
    Name = "${var.subdomain_name}.${data.aws_route53_zone.this.name} - Certificate"
  }

  lifecycle {
    create_before_destroy = true
  }
}

# Elastic Load Balancer resource, also known as a "Classic Load Balancer" 
data "aws_elb" "this" {
  name = var.load_balancer_name
}

resource "aws_route53_record" "www" {
  zone_id = data.aws_route53_zone.this.zone_id
  name    = aws_acm_certificate.this.domain_name
  type    = "A"

  alias {
    name                   = data.aws_elb.this.dns_name
    zone_id                = data.aws_elb.this.zone_id
    evaluate_target_health = false
  }
}

resource "aws_route53_record" "cert_validation" {
  zone_id         = data.aws_route53_zone.this.zone_id
  ttl             = 60
  name            = element(tolist(aws_acm_certificate.this.domain_validation_options), 0).resource_record_name
  type            = element(tolist(aws_acm_certificate.this.domain_validation_options), 0).resource_record_type
  records         = [element(tolist(aws_acm_certificate.this.domain_validation_options), 0).resource_record_value]
  allow_overwrite = true
}

resource "aws_acm_certificate_validation" "this" {
  certificate_arn         = aws_acm_certificate.this.arn
  validation_record_fqdns = [aws_route53_record.cert_validation.fqdn]
}
