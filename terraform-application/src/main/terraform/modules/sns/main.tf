resource "aws_sns_topic" "this" {
  name = var.topic_name
}

data "aws_iam_policy_document" "this" {
  version = "2008-10-17"

  statement {
    sid       = "Publishing"
    effect    = "Allow"
    actions   = ["SNS:Publish"]
    resources = [aws_sns_topic.this.arn]

    principals {
      identifiers = ["s3.amazonaws.com"]
      type        = "Service"
    }
  }
}

