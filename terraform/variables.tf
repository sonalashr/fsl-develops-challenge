variable "aws_region" {
  type    = string
  default = "us-east-1"

}
variable "environment" {
  type        = string
  description = "The environment to deploy to"
}

variable "project_name" {
  type        = string
  description = "The name of the project"
  default     = "rdicidr"
}

variable "unique_prefix" {
  type        = string
  description = "A unique prefix to ensure globally unique resource names"
  default     = "youruniqueprefix" # Change this to something unique for your deployment      

}