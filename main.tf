terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
  }
}


provider "aws" {
  region  = "ap-northeast-2"
  profile = "YOUR_PROFILE" # 여기를 변경
}


resource "aws_iam_role" "lambda_ec2_role" {
  name = "lambda-ec2-role"

  assume_role_policy = jsonencode({
        Version = "2012-10-17"
        Statement = [
        {
            Action = "sts:AssumeRole"
            Effect = "Allow"
            Principal = {
            Service = ["lambda.amazonaws.com", "events.amazonaws.com"]
            }
        }
        ]
    })

    inline_policy {
        name = "lambda-access-policy"

        policy = jsonencode({
        Version = "2012-10-17"
        Statement = [
            {
            Action = ["ec2:*", "cloudwatch:*", "logs:*"]
            Effect = "Allow"
            Resource = ["*"]
            }
        ]
        })
    }

}

resource "aws_lambda_function" "ec2_bot_lambda" {
    filename         = "ec2_bot.zip"
    function_name    = "EC2-Auto-Stop-and-Start"
    role             = "${aws_iam_role.lambda_ec2_role.arn}"
    handler          = "ec2_bot.lambda_handler"
    runtime          = "python3.9"
    timeout          = "20"

    environment {
      variables = {
          id = var.ec2_ids
      }
    }
  
}

resource "aws_lambda_permission" "allow_eventbridge" {
  statement_id  = "AllowExecutionFromEventbridge"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.ec2_bot_lambda.function_name
  principal     = "events.amazonaws.com"
  source_arn    = module.eventbridge.eventbridge_rule_arns.crons
}


module "eventbridge" {
  source = "terraform-aws-modules/eventbridge/aws"

  create_bus = false


  rules = {
    crons = {
      name                = "Auto-EC2"
      description         = "Auto Stop and Run EC2"
      schedule_expression = "cron(0 0,10 ? * MON-FRI *)"
    #   schedule_expression = "cron(40 5 ? * MON-FRI *)"
    }
    
  }

  targets = {
    crons = [
      {
        name  = "Auto-EC2"
        arn   = "${aws_lambda_function.ec2_bot_lambda.arn}"
      }
    ]
  }
  
  tags = {
        Name= "Auto-EC2"
    }
}
