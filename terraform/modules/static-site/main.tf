# Module to create a static website hosting in S3 with logging enabled

resource "aws_s3_bucket" "logs" {
    bucket = "${var.unique_prefix}-${var.project_name}-${var.environment}-logs"
    force_destroy = true
}

resource "aws_s3_bucket_versioning" "logs_v" {
    bucket = aws_s3_bucket.logs.id
    versioning_configuration {
        status = "Enabled"
    }
  
}

# static bucket (private, accessed only via CloudFront OAC)
resource "aws_s3_bucket" "site" {
    bucket = "${var.unique_prefix}-${var.project_name}-${var.environment}-site"
    force_destroy = true
}

resource "aws_s3_bucket_public_access_block" "site_pab" {
    bucket = aws_s3_bucket.site.id
    block_public_acls       = true
    block_public_policy     = true
    ignore_public_acls      = true
    restrict_public_buckets = true
  
}

resource "aws_s3_bucket_server_side_encryption_configuration" "site_sse" {
    bucket = aws_s3_bucket.site.id
    rule {
        apply_server_side_encryption_by_default {
            sse_algorithm = "AES256"
        }
    }
  
}

# Send s3 access logs to the logs bucket
resource "aws_s3_bucket_logging" "site_logs" {
    bucket = aws_s3_bucket.site.id
    target_bucket = aws_s3_bucket.logs.id
    target_prefix = "${var.environment}/s3/"
  
}

#clodfront OAC
resource "aws_cloudfront_origin_access_control" "oac" {
    name = "${var.unique_prefix}-${var.project_name}-${var.environment}-oac"
    description = "OAC for ${var.environment}"
    origin_access_control_origin_type = "s3"
    signing_behavior = "always"
    signing_protocol = "sigv4"
  
}

# CloudFront distribution
resource "aws_cloudfront_distribution" "cdn" {
    enabled = true
    comment ="${var.project_name}-${var.environment}"
    default_root_object = var.index_document
    
    origin {
        domain_name = aws_s3_bucket.site.bucket_regional_domain_name
        origin_id   = "s3-site"
        origin_access_control_id = aws_cloudfront_origin_access_control.oac.id
    }

    default_cache_behavior {
        allowed_methods = ["GET", "HEAD"]
        cached_methods  = ["GET", "HEAD"]
        target_origin_id = "s3-site"
        viewer_protocol_policy = "redirect-to-https"
        forwarded_values {
            query_string = false
            cookies {
                forward = "none"
            }
        }
    }

        custom_error_response {
            error_code = 404
            response_code = 200
            response_page_path = "/${var.error_document}"
        }

        custom_error_response {
            error_code = 403
            response_code = 200
            response_page_path = "/${var.error_document}"
        }

        price_class = "PriceClass_100"  
        
        logging_config {
            bucket = aws_s3_bucket.logs.bucket_domain_name
            include_cookies = false
            prefix = "${var.environment}/cloudfront/"
          
        }

        restrictions {
            geo_restriction {
                restriction_type = "none"
            }
        }

        viewer_certificate {
            cloudfront_default_certificate = true
        }   
}

# Allow Cloundfrount OAC to read from the S3 bucket
data "aws_caller_identity" "me" {}

data "aws_iam_policy_document" "site_policy" {
    statement {
       sid = "AllowCloudFrontServicePrincipalReadOnly"
       effect = "Allow"
       resources = [ aws_s3_bucket.site.arn,"${aws_s3_bucket.site.arn}/*"]
          principals {
            type = "service"
            identifiers = ["cloudfront.amazonaws.com"]
          }
          condition {
            test = "StringEquals"
            variable = "AWS:SourceArn"
            values = [aws_cloudfront_distribution.cdn.arn]
          }
    }
}

resource "aws_s3_bucket_policy" "site_bp" {
    bucket = aws_s3_bucket.site.id
    policy = data.aws_iam_policy_document.site_policy.json
}
