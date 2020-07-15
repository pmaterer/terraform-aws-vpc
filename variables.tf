variable "tags" {
  type = object({
    environment = string
    owner = string
    project = string
  })

  default = {
    environment = "dev"
    owner = "acme/devops"
    project = "manhattan"
  }
}

variable "default_tags" {
  type = object({
    component = string
    name = string
    version = string
  })

  default = {
    component = "infrastructure"
    name = "vpc"
    version = "0.0.1"
  }
}

variable "vpc_cidr_block" {
  type = string

  default = "10.0.0.0/20"
}

variable "public_subnet_cidr_blocks" {
  type = list(string)

  default = [
    "10.0.6.0/25",
    "10.0.6.128/25",
    "10.0.7.0/25",
  ]
}

variable "private_subnet_cidr_blocks" {
  type = list(string)

  default = [
    "10.0.0.0/23",
    "10.0.2.0/23",
    "10.0.4.0/23",
  ]
}