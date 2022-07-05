resource "aws_cloudwatch_metric_alarm" "nlb_healthyhosts" {
  alarm_name          = "Critical count of nodes"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = "1"
  threshold           = 6
  metric_name         = "Nodes count"
  namespace           = "CoolApp"
  period              = "300"
  statistic           = "Average"
  actions_enabled     = "true"
  alarm_actions       = [data.aws_sns_topic.http_checker_error.arn]
}
