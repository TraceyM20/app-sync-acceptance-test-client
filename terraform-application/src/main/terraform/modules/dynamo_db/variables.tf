variable "name" {
  type = string
}

variable "attribute_list" {
  type = list(object({
    key_name = string
    key_type = string
  }))
}

variable "partition_key" {
  type = string
}

variable "sort_key" {
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

variable "kms_key" {
  type      = string
  sensitive = true
}
