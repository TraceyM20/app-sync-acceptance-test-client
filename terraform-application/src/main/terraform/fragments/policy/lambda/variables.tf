variable "statements" {
  type = list(object({
    actions   = list(string)
    effect    = string
    sid       = string
    principals = object({
      identifiers = list(string)
      type = string
    })
  }))
}
