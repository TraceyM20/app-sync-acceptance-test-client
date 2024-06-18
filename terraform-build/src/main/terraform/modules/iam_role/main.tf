locals {
  inline_policies = var.can_assume_self ? merge(var.inline_policies, {
    "assume-self-access" = data.aws_iam_policy_document.assume_role_self.json
  }) : var.inline_policies
}

resource "aws_iam_role" "this" {
  name               = var.name
  assume_role_policy = var.assume_role_policy

  tags = merge(var.tags, {
    Name = var.name
  })
}

// Managed policies
resource "aws_iam_role_policy_attachment" "this" {
  for_each = toset(var.managed_policy_arns)

  role       = aws_iam_role.this.name
  policy_arn = each.value
}

// Inline policies
resource "aws_iam_role_policy" "this" {
  for_each = local.inline_policies

  role   = aws_iam_role.this.id
  name   = each.key
  policy = each.value
}

data "aws_iam_policy_document" "assume_role_self" {
  version = "2012-10-17"

  statement {
    effect    = "Allow"
    actions   = ["sts:AssumeRole"]
    resources = ["arn:aws:iam::${local.aws_account_id}:role/${var.name}"]
  }
}
