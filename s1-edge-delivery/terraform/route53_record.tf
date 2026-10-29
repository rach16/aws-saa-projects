resource "aws_route53_record" "apex" {
  zone_id = aws_route53_zone.cedar.zone_id
  name    = "cedar.banik.dev"
  type    = "A"

  alias {
    name                   = "d37aucrxis75gt.cloudfront.net"
    zone_id                = "Z2FDTNDATAQYW2"
    evaluate_target_health = false
  }
}

import {
  to = aws_route53_record.apex
  id = "Z0627005XIHDA6RJMHJP_cedar.banik.dev_A"
}
