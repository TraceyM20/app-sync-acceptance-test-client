resource "aws_api_gateway_gateway_response" "unauthorized" {
  rest_api_id        = var.api_id
  response_type      = "UNAUTHORIZED"
  status_code        = "401"
  response_templates = {
    "application/json" = jsonencode({
      error = {
        code      = "401"
        reason    = "API_UNAUTHORISED"
        message   = "Request is not authorized for caller"
        messageId = "API_MIP_MSGEID_00002"
      }
    })
  }
}

resource "aws_api_gateway_gateway_response" "access_denied" {
  rest_api_id        = var.api_id
  response_type      = "ACCESS_DENIED"
  status_code        = "403"
  response_templates = {
    "application/json" = jsonencode({
      error = {
        code      = "403"
        reason    = "API_UNAUTHORISED"
        message   = "Request is not allowed for caller"
        messageId = "API_MIP_MSGEID_00003"
      }
    })
  }
}

resource "aws_api_gateway_gateway_response" "expired_token" {
  rest_api_id        = var.api_id
  response_type      = "EXPIRED_TOKEN"
  status_code        = "403"
  response_templates = {
    "application/json" = jsonencode({
      error = {
        code      = "403"
        reason    = "API_UNAUTHORISED"
        message   = "Request is not allowed for caller"
        messageId = "API_MIP_MSGEID_00003"
      }
    })
  }
}

resource "aws_api_gateway_gateway_response" "invalid_api_key" {
  rest_api_id        = var.api_id
  response_type      = "INVALID_API_KEY"
  status_code        = "403"
  response_templates = {
    "application/json" = jsonencode({
      error = {
        code      = "403"
        reason    = "API_UNAUTHORISED"
        message   = "Request is not allowed for caller"
        messageId = "API_MIP_MSGEID_00003"
      }
    })
  }
}

resource "aws_api_gateway_gateway_response" "missing_authentication_token" {
  rest_api_id        = var.api_id
  response_type      = "MISSING_AUTHENTICATION_TOKEN"
  status_code        = "403"
  response_templates = {
    "application/json" = jsonencode({
      error = {
        code      = "403"
        reason    = "API_UNAUTHORISED"
        message   = "Request is not allowed for caller"
        messageId = "API_MIP_MSGEID_00003"
      }
    })
  }
}

resource "aws_api_gateway_gateway_response" "waf_filtered" {
  rest_api_id        = var.api_id
  response_type      = "WAF_FILTERED"
  status_code        = "403"
  response_templates = {
    "application/json" = jsonencode({
      error = {
        code      = "403"
        reason    = "API_UNAUTHORISED"
        message   = "Request is not allowed for caller"
        messageId = "API_MIP_MSGEID_00003"
      }
    })
  }
}

resource "aws_api_gateway_gateway_response" "resource_not_found" {
  rest_api_id        = var.api_id
  response_type      = "RESOURCE_NOT_FOUND"
  status_code        = "404"
  response_templates = {
    "application/json" = jsonencode({
      error = {
        code      = "404"
        reason    = "API_NOT_FOUND"
        message   = "Requested resource is not defined"
        messageId = "API_MIP_MSGEID_00009"
      }
    })
  }
}

resource "aws_api_gateway_gateway_response" "request_too_large" {
  rest_api_id        = var.api_id
  response_type      = "REQUEST_TOO_LARGE"
  status_code        = "413"
  response_templates = {
    "application/json" = jsonencode({
      error = {
        code      = "413"
        reason    = "API_BAD_PARAM"
        message   = "Request content exceeds the maximum allowed size"
        messageId = "API_MIP_MSGEID_00010"
      }
    })
  }
}

resource "aws_api_gateway_gateway_response" "throttled" {
  rest_api_id        = var.api_id
  response_type      = "THROTTLED"
  status_code        = "429"
  response_templates = {
    "application/json" = jsonencode({
      error = {
        code      = "429"
        reason    = "API_THROTTLED"
        message   = "To many requests made"
        messageId = "API_MIP_MSGEID_00005"
      }
    })
  }
}

resource "aws_api_gateway_gateway_response" "quota_exceeded" {
  rest_api_id        = var.api_id
  response_type      = "QUOTA_EXCEEDED"
  status_code        = "429"
  response_templates = {
    "application/json" = jsonencode({
      error = {
        code      = "429"
        reason    = "API_THROTTLED"
        message   = "To many requests made"
        messageId = "API_MIP_MSGEID_00005"
      }
    })
  }
}

resource "aws_api_gateway_gateway_response" "default_request_error" {
  rest_api_id        = var.api_id
  response_type      = "DEFAULT_4XX"
  status_code        = "400"
  response_templates = {
    "application/json" = jsonencode({
      error = {
        code      = "400"
        reason    = "API_BAD_PARAM"
        message   = "Request contained bad or unexpected parameters"
        messageId = "API_MIP_MSGEID_00001"
      }
    })
  }
}

resource "aws_api_gateway_gateway_response" "default_service_error" {
  rest_api_id        = var.api_id
  response_type      = "DEFAULT_5XX"
  status_code        = "500"
  response_templates = {
    "application/json" = jsonencode({
      error = {
        code      = "500"
        reason    = "API_ERROR"
        message   = "The server encountered an unexpected condition which prevented it from fulfilling the request"
        messageId = "API_MIP_MSGEID_00018"
      }
    })
  }
}
