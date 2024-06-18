variable "name" {
  type = string
}

variable "description" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "tags" {
  type = object({
    costgroup  = string
    env        = string
    owner      = string
    created-by = string
  })
}
