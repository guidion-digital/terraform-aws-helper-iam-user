variable "username" {
  description = "IAM username"

  type = string
}

variable "namespace" {
  description = "Namespace to create IAM user in"

  type    = string
  default = null
}

variable "policies" {
  description = "Map of policy names to JSON policies"

  type    = any
  default = {}
}

variable "policy_arns" {
  description = "List of policy ARNs to give the user"

  type    = list(string)
  default = []
}

variable "asm_storage" {
  description = "By default, the credentials are stored in AWS ASM"

  type = object({
    enabled         = optional(bool, true)
    recovery_window = optional(number, 0)
  })

  default = {
    enabled         = true
    recovery_window = 0
  }
}

variable "github" {
  description = "Will push credentials to Github secrets and variables if configured. Supplying only 'repo' will push to repository secrets, also supplying 'environment' will push to environment secrets"

  type = object({
    repository  = string
    environment = optional(string, null)
  })

  default = {
    repository  = null
    environment = null
  }
}

variable "region" {
  description = "AWS region to configure the credentials with"

  type    = string
  default = "eu-central-1"
}
