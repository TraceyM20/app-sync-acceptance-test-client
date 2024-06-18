variable "api_id" {
  type = string
}

variable "statements" {
  type = list(object({
    actions   = list(string)
    effect    = string
    resources = list(string)
    sid       = string
    principals = object({
      identifiers = list(string)
      type = string
    })
  }))
}

