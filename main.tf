variable "domain_name" {
  description = "The domain name for the website"
  type        = string
}

# Create S3 bucket for the static website


resource "aws_s3_bucket" "damir_website" {
  bucket = "your-bucket-name"

  # If you are trying to add tags, use the `tags` argument here:
  tags = {
    Name        = "damir_website"
    Environment = "production"
  }
}

# Configure the S3 bucket as a website
resource "aws_s3_bucket_website_configuration" "damir_website_config" {
  bucket = aws_s3_bucket.damir_website.id

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "error.html"
  }
}

# Upload index.html to the bucket
resource "aws_s3_object" "index" {
  bucket = aws_s3_bucket.damir_website.bucket
  key    = "index.html"
  source = "files/index.html"  # Ensure this file exists in the 'files' directory
}

# Upload error.html to the bucket
resource "aws_s3_object" "error" {
  bucket = aws_s3_bucket.damir_website.bucket
  key    = "error.html"
  source = "files/error.html"  # Ensure this file exists in the 'files' directory
}

# Route 53: Create a hosted zone for the domain
resource "aws_route53_zone" "damir_zone" {
  name = var.domain_name
}

# Route 53: Create a DNS record for the S3 website
resource "aws_route53_record" "damir_record" {
  zone_id = aws_route53_zone.damir_zone.zone_id
  name    = var.domain_name
  type    = "A"

  alias {
    name                   = aws_s3_bucket_website_configuration.damir_website_config.website_endpoint
    zone_id                = aws_s3_bucket.damir_website.hosted_zone_id
    evaluate_target_health = false
  }
}




