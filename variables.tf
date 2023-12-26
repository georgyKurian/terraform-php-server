variable "AWS_REGION" {
  type    = string
  default = "ca-central-1"
}

variable "AWS_ACCESS_KEY_ID" {
  type      = string
  sensitive = true
}

variable "AWS_SECRET_ACCESS_KEY" {
  type      = string
  sensitive = true
}

variable "vpc_cidr" {
  type    = string
  default = "10.0.0.0/16"

  validation {
    condition     = can(cidrhost(var.vpc_cidr, 0))
    error_message = "Must be valid IPv4 CIDR."
  }
}

variable "subnet_cidrs" {
  type    = list(string)
  default = ["10.0.1.0/24", "10.0.2.0/24"]

  validation {
    condition = alltrue([
      for value in var.subnet_cidrs : can(cidrhost(value, 0))
    ])
    error_message = "Must be valid IPv4 CIDR."
  }
}

variable "availability_zones" {
  type    = list(string)
  default = ["ca-central-1a", "ca-central-1b"]

  validation {
    condition = alltrue([
      for value in var.availability_zones : can(regex("^[A-Za-z0-9-]+$", value))
    ])
    error_message = "Must be valid IPv4 CIDR."
  }
}
