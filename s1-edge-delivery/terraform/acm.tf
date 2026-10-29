resource "aws_acm_certificate" "cedar" {
  provider = aws.use1

  domain_name       = "cedar.banik.dev"
  validation_method = "DNS"
}

import {
  provider = aws.use1
  to       = aws_acm_certificate.cedar
  id       = "arn:aws:acm:us-east-1:${var.account_id}:certificate/c06c8ba3-b888-43e2-9ebb-1cec2b4ca116"
}
