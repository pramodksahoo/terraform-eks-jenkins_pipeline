terraform {
  backend "s3" {
    # Replace this with your bucket name!

    #bucket         = "eks-tfstate-storage-testing"
    # Replace this with your DynamoDB table name!

    #dynamodb_table = "eks-tfstate-locks"
    encrypt        = true
  }
}
