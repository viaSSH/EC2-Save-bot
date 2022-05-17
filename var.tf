variable "ec2_ids" {
  type        = string
  description = "Your EC2 ID. ex)i-00947d5781febb052, i-07eea10d9ab11f537"
    # description = "Your EC2 ID. ex)i-087f706171882d2db, i-00947d5781febb055"

# i-087f706171882d2db, i-00947d5781febb055
#   validation {
#     condition     = var.iam_user_count < 5
#     error_message = "IAM user count must be less than 5."
#   }
}