resource "aws_s3_bucket" "app-1-access-log" {
  bucket = "app-1-access-log-bucket"

  tags = {
    Name = "App 1 - Log"
  }
}

resource "aws_s3_bucket_policy" "app-1-access-log-policy" {
  bucket = aws_s3_bucket.app-1-access-log.id
  policy = data.aws_iam_policy_document.s3_bucket_lb_write.json
}

data "aws_elb_service_account" "main" {}
data "aws_iam_policy_document" "s3_bucket_lb_write" {
  policy_id = "s3_bucket_lb_logs"

  statement {
    actions = [
      "s3:PutObject",
    ]
    effect = "Allow"
    resources = [
      "${aws_s3_bucket.app-1-access-log.arn}/*",
    ]

    principals {
      identifiers = ["${data.aws_elb_service_account.main.arn}"]
      type        = "AWS"
    }
  }

  statement {
    actions = [
      "s3:PutObject"
    ]
    effect    = "Allow"
    resources = ["${aws_s3_bucket.app-1-access-log.arn}/*"]
    principals {
      identifiers = ["delivery.logs.amazonaws.com"]
      type        = "Service"
    }
  }


  statement {
    actions = [
      "s3:GetBucketAcl"
    ]
    effect    = "Allow"
    resources = ["${aws_s3_bucket.app-1-access-log.arn}"]
    principals {
      identifiers = ["delivery.logs.amazonaws.com"]
      type        = "Service"
    }
  }
}
