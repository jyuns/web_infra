provider "aws" {
	access_key = var.access_key
	secret_key = var.secret_key
	region = var.az_name
}

terraform {
	required_version = "1.1.2"
	required_providers {
		aws = ">= 2.53.0"
	}
}
