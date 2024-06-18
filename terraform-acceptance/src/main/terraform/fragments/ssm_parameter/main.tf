resource "aws_ssm_parameter" "this" {
  name      = var.path
  value     = var.value
  type      = var.type
  tier      = var.tier
  key_id    = var.type == "SecureString" ? var.kms_key : null
  overwrite = true

  tags = merge(var.tags, {
    Name = var.name
  })
}
