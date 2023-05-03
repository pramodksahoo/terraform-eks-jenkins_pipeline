resource "aws_s3_bucket" "velero_backup_bucket" {
    provider=aws.sourced
    bucket = var.bucket_name
    


  tags = {
    Name        = var.bucket_name
    Purpose="To store backup of k8 resources using velero"
  }

}

resource "aws_s3_bucket_acl" "velero_backup_bucket_acl"{
    provider=aws.sourced
  bucket = aws_s3_bucket.velero_backup_bucket.id
  acl    = var.acl
  
}

resource "aws_s3_bucket_versioning" "velero_backup_bucket_versioning" {
    provider=aws.sourced
  bucket = aws_s3_bucket.velero_backup_bucket.id
  
  versioning_configuration {
    status = var.versioning
  }
  
}


resource "aws_s3_bucket_public_access_block" "block_public" {
    provider=aws.sourced
  bucket = aws_s3_bucket.velero_backup_bucket.id
  
  block_public_acls = true
  ignore_public_acls = true
  block_public_policy = true
  restrict_public_buckets = true
}
