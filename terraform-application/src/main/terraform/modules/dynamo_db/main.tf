resource "aws_dynamodb_table" "this" {
  name         = var.name
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = var.partition_key
  range_key    = var.sort_key

  server_side_encryption {
    enabled = true
    kms_key_arn = var.kms_key
  }

  dynamic "attribute" {
    for_each = var.attribute_list
    content {
      name = attribute.value.key_name
      type = attribute.value.key_type
    }
  }

  tags = merge(var.tags, {
    Name = var.name
  })
}