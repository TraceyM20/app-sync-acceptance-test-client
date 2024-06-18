variable "name" {
  type = string
}

variable "versioning" {
  type    = bool
  default = false
}

variable "force_destroy" {
  type    = bool
  default = true
}

variable "expiration_days" {
  type    = number
  default = 7
}

variable "noncurrent_version_expiration_days" {
  type    = number
  default = 7
}

variable "abort_incomplete_multipart_upload_days" {
  type    = number
  default = 1
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
