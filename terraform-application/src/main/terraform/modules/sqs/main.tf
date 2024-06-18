locals {
  message_retention_seconds = 1209600 # max 14 days
  receive_wait_time_seconds = 20 # long polling
}

resource "aws_sqs_queue" "queue" {
  depends_on                         = [aws_sqs_queue.dlq_queue]
  name                               = var.name
  visibility_timeout_seconds         = var.polling_function_timeout + 10
  message_retention_seconds          = local.message_retention_seconds
  receive_wait_time_seconds          = local.receive_wait_time_seconds
  redrive_policy                     = jsonencode({
    deadLetterTargetArn = aws_sqs_queue.dlq_queue.arn
    maxReceiveCount     = var.max_retry_attempt
  })
  kms_master_key_id                 = var.kms_key
  kms_data_key_reuse_period_seconds = 3600

  tags                              = merge(var.tags, {
    Name = var.name
  })
}

resource "aws_sns_topic_subscription" "this" {
  topic_arn            = var.sns_topic_arn
  endpoint             = aws_sqs_queue.queue.arn
  protocol             = "sqs"
  raw_message_delivery = true
}

resource "aws_sqs_queue" "dlq_queue" {
  name                              = "${var.name}-dlq"
  message_retention_seconds         = local.message_retention_seconds
  receive_wait_time_seconds         = local.receive_wait_time_seconds
  kms_master_key_id                 = var.kms_key
  kms_data_key_reuse_period_seconds = 3600

  tags                              = merge(var.tags, {
    Name = var.name
  })
}
