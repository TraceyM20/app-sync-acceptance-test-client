resource "aws_s3_bucket" "this" {
  bucket        = var.name
  force_destroy = var.force_destroy

  tags = merge(var.tags, {
    Name = var.name
  })
}

resource "aws_s3_bucket_versioning" "this" {
  bucket = aws_s3_bucket.this.id

  versioning_configuration {
    status = var.versioning ? "Enabled" : "Disabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "this" {
  bucket = aws_s3_bucket.this.id

  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = var.kms_key
      sse_algorithm     = "aws:kms"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "this" {
  bucket                  = aws_s3_bucket.this.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_ownership_controls" "this" {
  bucket = aws_s3_bucket.this.id

  rule {
    object_ownership = "BucketOwnerEnforced"
  }
}

resource "aws_s3_bucket_policy" "this" {
  bucket = aws_s3_bucket.this.id
  policy = data.aws_iam_policy_document.this.json
}

resource "aws_s3_bucket_lifecycle_configuration" "this" {
  bucket = aws_s3_bucket.this.id

  rule {
    id     = "AbortIncompleteMultipartUploads"
    status = "Enabled"

    abort_incomplete_multipart_upload {
      days_after_initiation = var.abort_incomplete_multipart_upload_days
    }
  }

  rule {
    id     = "ExpireObjects"
    status = "Enabled"

    expiration {
      days = var.expiration_days
    }
  }

  dynamic "rule" {
    for_each = var.versioning ? ["ExpireNonCurrentVersions"] : []

    content {
      id     = "ExpireNonCurrentVersions"
      status = "Enabled"

      noncurrent_version_expiration {
        noncurrent_days = var.noncurrent_version_expiration_days
      }
    }
  }
}

data "aws_iam_policy_document" "this" {
  statement {
    sid       = "SecureTransport"
    effect    = "Deny"
    actions   = ["s3:*"]
    resources = [
      aws_s3_bucket.this.arn,
      "${aws_s3_bucket.this.arn}/*"
    ]

    principals {
      identifiers = ["*"]
      type        = "AWS"
    }

    condition {
      test     = "Bool"
      values   = ["false"]
      variable = "aws:SecureTransport"
    }
  }
}
