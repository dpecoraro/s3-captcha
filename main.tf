resource "aws_s3_bucket" "website" { 
    bucket = "captcha-ec0ec570-a253-2213-7cd4-194aa13aee93"
}

resource "aws_s3_bucket_website_configuration" "website" {
    bucket = aws_s3_bucket.website.id

    index_document {  
      suffix = "index.html"
    }

    error_document {
      key = "error.html"
    }
}

resource "aws_s3_bucket_versioning" "website" {
  bucket = aws_s3_bucket.website.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_ownership_controls" "website" {
  bucket = aws_s3_bucket.website.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_public_access_block" "website" {
  bucket = aws_s3_bucket.website.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_acl" "website" {
  depends_on = [
    aws_s3_bucket_ownership_controls.website,
    aws_s3_bucket_public_access_block.website,
    aws_s3_bucket_policy.website
  ]

  bucket = aws_s3_bucket.website.id
  acl    = "public-read"
}

resource "aws_s3_bucket_policy" "website" {
  bucket = aws_s3_bucket.website.bucket

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action    = ["s3:GetObject"],
        Effect    = "Allow",
        Resource  = "${aws_s3_bucket.website.arn}/*",
        Principal = "*"
      },
    ]
  })
}

output "website_url" {
  value = "http://${aws_s3_bucket.website.bucket}.s3-website-${var.region}.amazonaws.com"
}

