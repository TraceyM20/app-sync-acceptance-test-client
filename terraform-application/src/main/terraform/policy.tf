module "ssm_policy" {
  source = "./fragments/policy/common"

  statements = [
    {
      effect    = "Allow"
      actions   = [
        "ssm:GetParametersByPath",
        "ssm:GetParameters",
        "ssm:GetParameter"
      ],
      resources = ["${module.root_parameter.arn}/*"]
      sid       = "AllowSSM",
    },
    {
      effect    = "Allow"
      actions   = ["kms:Decrypt"]
      resources = [var.application_kms_arn]
      sid       = "AllowKMSDecrypt"
    }
  ]
}