variable "name" {
  type = string
}

variable "domain_name" {
  type = string
  validation {
    condition     = can(regex("^(([A-Za-z0-9-]{0,62}[A-Za-z0-9])\\.)+([A-Za-z0-9-]{0,62}[A-Za-z0-9])$", var.domain_name))
    error_message = "Invalid Domain Name."
  }
}

variable "api_id" {
  type = string
}

variable "api_stage_name" {
  type = string
}

variable "hosted_zone_id" {
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
