output "sqs_arn" {
  value = aws_sqs_queue.queue.arn
}

output "sqs_dlq_url" {
  value = aws_sqs_queue.dlq_queue.url
}

output "sqs_queue_url" {
  value = aws_sqs_queue.queue.url
}

output "sqs_dlq_arn" {
  value = aws_sqs_queue.dlq_queue.arn
}
