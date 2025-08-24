output "backend_bucket_name" {
  value = aws_s3_bucket.bucket.id
}

output "backend_bucket_region" {
  value = aws_s3_bucket.bucket.region
}

output "locking_dynamodb_table_name" {
  value = aws_dynamodb_table.table.id
}