terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}
module "s3-bucket" {
  source  = "terraform-aws-modules/s3-bucket/aws"
  version = "4.1.2"
}

# Configure the AWS Provider
provider "aws" {
  region = "eu-central-1"
}

# create an S3 bucket by using the aws_s3_bucket resource

resource "aws_s3_bucket" "cde_terraform_bkt_regional" { 
  bucket = "cde_joachim_bucket_regional" 
}  

# enable versioning on the S3 bucket 
resource "aws_s3_bucket_versioning" "enabled" { 
  bucket = aws_s3_bucket.cde_terraform_bkt_regional.id 
  versioning_configuration { 
    status = "Enabled" 
  } 
} 

# use the aws_s3_bucket_server_side_encryption_configuration resource  
# to turn server‐side encryption on by default for all data written to this S3 bucket

resource "aws_s3_bucket_server_side_encryption_configuration" "default" { 
  bucket = aws_s3_bucket.cde_terraform_bkt_regional.id 
  rule { 
    apply_server_side_encryption_by_default { 
      sse_algorithm = "AES256"
        }
      }
   }

resource "aws_dynamodb_table" "terraform_locks" { 
  name         = "joachimdynamodbregional" 
  billing_mode = "PAY_PER_REQUEST" 
  hash_key     = "LockID" 
   
  tags = { 
    Name = "DynamoDB Terraform State Lock Table" 
  } 
  attribute { 
    name = "LockID" 
    type = "S" 
  } 
  }

resource "aws_s3_bucket_public_access_block" "public_access" { 
  bucket                  = aws_s3_bucket.cde_terraform_bkt_regional.id 
  block_public_acls       = true 
  block_public_policy     = true 
  ignore_public_acls      = true 
  restrict_public_buckets = true 
} 
