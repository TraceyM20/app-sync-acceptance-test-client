data "aws_iam_policy_document" "this" {
  version = "2012-10-17"
  dynamic statement {
    for_each = var.statements
    content {
      actions   = statement.value["actions"]
      effect    = statement.value["effect"]
      resources = statement.value["resources"]
      sid       = statement.value["sid"]
    }
  }

}
