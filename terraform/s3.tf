resource "aws_s3_bucket" "kops" {
  bucket = "infra-k8s-aws"
  acl    = "private"

  tags = {
    Name    = "Kops Cluster State"
    project = "petstore"
  }

  versioning {
    enabled = true
  }
}
