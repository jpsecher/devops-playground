resource "aws_s3_bucket" "remote-state" {
  bucket = "${var.bucket-name}"
  acl = "private"
  versioning {
    enabled = "false"
  }
}

resource "aws_s3_bucket_policy" "remote-state-bucket-access" {
  bucket = "${aws_s3_bucket.remote-state.id}"
  policy = "${data.aws_iam_policy_document.remote-state-bucket-access.json}"
}

# resource "aws_iam_policy" "remote-state-bucket-access" {
#   name = "remote-state-bucket-access"
#   policy = "${data.aws_iam_policy_document.remote-state-bucket-access.json}"
# }

data "aws_iam_policy_document" "remote-state-bucket-access" {
  statement {
    effect = "Allow"
    actions = [
      "s3:ListBucket",
      "s3:GetBucketLocation",
    ]
    resources = ["arn:aws:s3:::${aws_s3_bucket.remote-state.id}"]
    principals {
      type = "*"
      identifiers = ["*"]
    }
  }
  statement {
    effect = "Allow"
    actions = [
      "s3:PutObject",
      "s3:GetObject",
      "s3:DeleteObject",
    ]
    resources = ["arn:aws:s3:::${aws_s3_bucket.remote-state.id}/*"]
    principals {
      type = "*"
      identifiers = ["*"]
    }
  }
}
