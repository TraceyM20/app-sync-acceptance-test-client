locals {
  pipeline_secrets            = sensitive(jsondecode(data.aws_secretsmanager_secret_version.pipeline_secrets.secret_string))
  vpc_id                      = data.aws_ssm_parameter.vpc_id.value
  vpc_private_subnets_ids     = [for id in jsondecode(data.aws_ssm_parameter.vpc_private_subnet_ids.value) : id]
  vpc_public_subnets_ids      = [for id in jsondecode(data.aws_ssm_parameter.vpc_public_subnet_ids.value) : id]
  vpc_id_ssm_path             = var.vpc_id_ssm_path == null ? "/${var.service_name}/${var.environment}/vpc" : var.vpc_id_ssm_path
  vpc_private_subnet_ssm_path = var.vpc_private_subnet_ssm_path == null ? "/${var.service_name}/${var.environment}/vpc/subnet/private" : var.vpc_private_subnet_ssm_path
  vpc_public_subnet_ssm_path  = var.vpc_public_subnet_ssm_path == null ? "/${var.service_name}/${var.environment}/vpc/subnet/private": var.vpc_public_subnet_ssm_path
}

data "aws_secretsmanager_secret" "pipeline_secrets" {
  arn = var.pipeline_secret_arn
}

data "aws_secretsmanager_secret_version" "pipeline_secrets" {
  secret_id = data.aws_secretsmanager_secret.pipeline_secrets.id
}

data "aws_ssm_parameter" "vpc_id" {
  name = local.vpc_id_ssm_path
}

data "aws_ssm_parameter" "vpc_private_subnet_ids" {
  name = local.vpc_private_subnet_ssm_path
}

data "aws_ssm_parameter" "vpc_public_subnet_ids" {
  name = local.vpc_public_subnet_ssm_path
}
