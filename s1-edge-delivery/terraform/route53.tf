resource "aws_route53_zone" "cedar" {
  name    = "cedar.banik.dev"
  comment = ""
}

import {
  to = aws_route53_zone.cedar
  id = "Z0627005XIHDA6RJMHJP"
}
