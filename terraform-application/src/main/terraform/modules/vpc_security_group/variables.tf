variable "name" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "tags" {
  type = object({
    costgroup   = string
    env         = string
    application = string
    created-by  = string
    owner       = string
  })
}
