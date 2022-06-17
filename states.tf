terraform {
  backend "s3" {
    bucket  = "tf-micro-services-bucket"
    key     = "terraform.tfstate"
    encrypt = true

    #    region         		= "eu-central-1"
    #    profile        		= "test_local"
    #    shared_credentiales_file 	= "THE_ID_OF_THE_DYNAMODB_TABLE"
  }

}

provider "aws" {
  region = "eu-west-1"
}
