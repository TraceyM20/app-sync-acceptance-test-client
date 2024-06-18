locals {
  tags = merge(var.tags, {
    Name = var.name
  })
}

resource "aws_api_gateway_domain_name" "this" {
  depends_on = [aws_acm_certificate_validation.this]

  domain_name              = var.domain_name
  security_policy          = "TLS_1_2"
  regional_certificate_arn = aws_acm_certificate.this.arn

  endpoint_configuration {
    types = ["REGIONAL"]
  }

  tags = local.tags
}

resource "aws_api_gateway_base_path_mapping" "this" {
  api_id      = var.api_id
  domain_name = aws_api_gateway_domain_name.this.domain_name
  stage_name  = var.api_stage_name
}

resource "aws_route53_record" "alias" {
  zone_id = var.hosted_zone_id
  name    = var.domain_name
  type    = "A"

  alias {
    zone_id                = aws_api_gateway_domain_name.this.regional_zone_id
    name                   = aws_api_gateway_domain_name.this.regional_domain_name
    evaluate_target_health = false
  }
}

resource "aws_acm_certificate" "this" {
  domain_name       = var.domain_name
  validation_method = "DNS"

  tags = local.tags
}

resource "aws_route53_record" "cnames" {
  for_each = {
    for dvo in aws_acm_certificate.this.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      type   = dvo.resource_record_type
      record = dvo.resource_record_value
    }
  }
  zone_id  = var.hosted_zone_id
  //noinspection HILUnresolvedReference
  name     = each.value.name
  //noinspection HILUnresolvedReference
  type     = each.value.type
  //noinspection HILUnresolvedReference
  records  = [each.value.record]
  ttl      = 300
}

resource "aws_acm_certificate_validation" "this" {
  certificate_arn         = aws_acm_certificate.this.arn
  validation_record_fqdns = [for record in aws_route53_record.cnames : record.fqdn]
}
