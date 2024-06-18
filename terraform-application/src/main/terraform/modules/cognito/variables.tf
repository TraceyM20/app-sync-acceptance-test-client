variable "name" {
  type = string
}

variable "user_pool_id" {
  type = string
}

variable "identifier" {
  type = string
}

variable "scopes" {
  type = map(string)
}
