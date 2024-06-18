variable "statements" {
  type = list(object({
    actions   = list(string)
    effect    = string
    resources = list(string)
    sid       = string
  }))
}
