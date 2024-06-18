data "aws_iam_policy_document" "this" {
  version = "2012-10-17"
  dynamic statement {
    for_each = var.statements
    content {
      actions   = statement.value["actions"]
      effect    = statement.value["effect"]
      resources = statement.value["resources"]
      sid       = statement.value["sid"]
      principals {
        identifiers = statement.value["principals"].identifiers
        type = statement.value["principals"].type
      }

    }
  }
}

resource "aws_api_gateway_rest_api_policy" "this" {
  rest_api_id = var.api_id
  policy      = data.aws_iam_policy_document.this.json
}
