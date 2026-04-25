# Private S3 bucket; objects uploaded from repo ./koalas at apply time.

locals {
  koalas_dir = "${path.module}/koalas"
  # fileset() uses Go path.Match — no brace expansion; union common image extensions.
  koala_files = setunion(
    fileset(local.koalas_dir, "*.jpg"),
    fileset(local.koalas_dir, "*.JPG"),
    fileset(local.koalas_dir, "*.jpeg"),
    fileset(local.koalas_dir, "*.JPEG"),
    fileset(local.koalas_dir, "*.png"),
    fileset(local.koalas_dir, "*.PNG"),
  )
}

resource "aws_s3_bucket" "koalas" {
  bucket        = "${var.project_name}-${data.aws_caller_identity.current.account_id}-koalas"
  force_destroy = true

  tags = {
    Name = "${var.project_name}-koalas"
  }
}

resource "aws_s3_bucket_public_access_block" "koalas" {
  bucket = aws_s3_bucket.koalas.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_ownership_controls" "koalas" {
  bucket = aws_s3_bucket.koalas.id

  rule {
    object_ownership = "BucketOwnerEnforced"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "koalas" {
  bucket = aws_s3_bucket.koalas.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_object" "koalas" {
  for_each = local.koala_files

  bucket = aws_s3_bucket.koalas.id
  key    = "koalas/${each.value}"
  source = "${local.koalas_dir}/${each.value}"
  etag   = filemd5("${local.koalas_dir}/${each.value}")
  content_type = (
    endswith(lower(each.value), ".jpg") || endswith(lower(each.value), ".jpeg") ? "image/jpeg" : (
      endswith(lower(each.value), ".png") ? "image/png" : "application/octet-stream"
    )
  )

  depends_on = [
    aws_s3_bucket_public_access_block.koalas,
    aws_s3_bucket_ownership_controls.koalas,
  ]
}
