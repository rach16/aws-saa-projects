resource "aws_cloudfront_distribution" "cdn" {
  enabled             = true
  is_ipv6_enabled     = true
  comment             = ""
  default_root_object = "index.html"
  aliases             = ["cedar.banik.dev"]
  price_class         = "PriceClass_All"
  http_version        = "http2"
  web_acl_id          = aws_wafv2_web_acl.cf.arn

  tags = {
    Name = "cedar-clinic-site"
  }

  origin {
    origin_id                = "cedar-clinic-site-7412.s3.us-west-2.amazonaws.com-mvq4gaostzs"
    domain_name              = "cedar-clinic-site-7412.s3.us-west-2.amazonaws.com"
    origin_access_control_id = aws_cloudfront_origin_access_control.site.id
    connection_attempts      = 3
    connection_timeout       = 10
  }

  default_cache_behavior {
    target_origin_id       = "cedar-clinic-site-7412.s3.us-west-2.amazonaws.com-mvq4gaostzs"
    viewer_protocol_policy = "redirect-to-https"
    allowed_methods        = ["GET", "HEAD"]
    cached_methods         = ["GET", "HEAD"]
    compress               = true
    cache_policy_id        = "658327ea-f89d-4fab-a63d-7e88639e58f6"
  }

  ordered_cache_behavior {
    path_pattern           = "/nocache/*"
    target_origin_id       = "cedar-clinic-site-7412.s3.us-west-2.amazonaws.com-mvq4gaostzs"
    viewer_protocol_policy = "redirect-to-https"
    allowed_methods        = ["GET", "HEAD"]
    cached_methods         = ["GET", "HEAD"]
    compress               = true
    cache_policy_id        = "4135ea2d-6df8-44a3-9df3-4b5a84be39ad"
  }

  viewer_certificate {
    acm_certificate_arn      = aws_acm_certificate.cedar.arn
    ssl_support_method       = "sni-only"
    minimum_protocol_version = "TLSv1.3_2025"
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }
}

import {
  to = aws_cloudfront_distribution.cdn
  id = "E3414HZ9GECD7Y"
}
