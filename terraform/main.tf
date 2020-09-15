variable "region" {}
variable "profile" {}

provider "aws" {
  region  = var.region
  profile = var.profile
  version = "3.6.0"
}
