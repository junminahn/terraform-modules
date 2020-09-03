variable "hosted_zone_id" {
  description = "The Hosted Zone id of the desired Hosted Zone"
}

variable "subdomain_name" {
  description = "The name of the Sub-domain for the new Route53 Record"
}

variable "load_balancer_name" {
  description = "The name of the AWS load balancer"
}
