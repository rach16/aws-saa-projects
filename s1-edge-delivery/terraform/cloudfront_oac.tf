resource "aws_cloudfront_origin_access_control" "site" {
  name                              = "oac-cedar-clinic-site-7412.s3.us-west-2.amazonaws.co-mvq4isf5ekx"
  description                       = "Created by CloudFront"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

import {
  to = aws_cloudfront_origin_access_control.site
  id = "E38XUW1LGAFOUC"
}
