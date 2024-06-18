variable "name" {
  type = string
}

variable "path" {
  type = string
}

variable "value" {
  type = string
}

variable "type" {
  type    = string
  default = "String"
}

variable "tier" {
  type    = string
  default = "Standard"
}

variable "kms_key" {
  type      = string
  sensitive = true
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
