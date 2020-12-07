locals {
  alarm-name = "${var.environment}-${var.app-name}"
  topic-name = "${var.environment}-${var.app-name}"
}
resource "aws_cloudwatch_metric_alarm" "foobar" {
  alarm_name                = local.alarm-name
  alarm_actions             = [aws_sns_topic.user_updates.arn]
  ok_actions                = [aws_sns_topic.user_updates.arn]
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = "2"
  metric_name               = "ECS/CPUUtilization"
  namespace                 = "AWS/ECS"
  period                    = "120"
  statistic                 = "Average"
  threshold                 = "1"
  alarm_description         = "This metric monitors ECS CPU utilization"
  insufficient_data_actions = [aws_sns_topic.user_updates.arn]
}

# SNS Topic to send alarms to
resource "aws_sns_topic" "user_updates" {
  name = local.topic-name
}

resource "aws_sns_topic_subscription" "user_updates_sqs_target" {
  topic_arn = aws_sns_topic.user_updates.arn
  protocol  = "sms"
  endpoint  = var.sms-number
}