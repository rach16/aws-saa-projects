resource "aws_route53_record" "cert_validation" {
  zone_id = aws_route53_zone.cedar.zone_id
  name    = tolist(aws_acm_certificate.cedar.domain_validation_options)[0].resource_record_name
  type    = tolist(aws_acm_certificate.cedar.domain_validation_options)[0].resource_record_type
  records = [tolist(aws_acm_certificate.cedar.domain_validation_options)[0].resource_record_value]
  ttl     = 300
}

import {
  to = aws_route53_record.cert_validation
  id = "Z0627005XIHDA6RJMHJP__3130570843658baf5139fc27b37f0e15.cedar.banik.dev_CNAME"
}
