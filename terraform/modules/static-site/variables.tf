variable "project_name" {
    type = string
    description = "The name of the project"
  
}

variable "environment" {
    type = string
    description = "The environment to deploy to"    
  
}

variable "unique_prefix" {
    type = string
    description = "A unique prefix to ensure globally unique resource names"    
  
}

variable "index_document" {
    type    = string
    default = "index.html"
    description = "The index document for the S3 bucket"
  
}

variable "error_document" {
    type    = string
    default = "error.html"
    description = "The error document for the S3 bucket"    
  
}