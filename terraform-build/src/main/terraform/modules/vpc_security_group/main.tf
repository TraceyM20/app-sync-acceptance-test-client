resource "aws_security_group" "this" {
  name        = "${var.name}-sg"
  description = var.description
  vpc_id      = var.vpc_id

  tags = var.tags
}

resource "aws_security_group_rule" "outbound" {
  type              = "egress"
  from_port         = 0
  to_port           = 65535
  protocol          = "tcp"
  cidr_blocks       = [
    "0.0.0.0/0"
  ]
  ipv6_cidr_blocks  = [
    "::/0"
  ]
  security_group_id = aws_security_group.this.id
}
