# Standard EC2 metric (basic monitoring: 1-min or 5-min periods supported; default 300s).
# Static threshold (not anomaly detection): single fixed threshold on CPUUtilization.

resource "aws_cloudwatch_metric_alarm" "ec2_cpu_high" {
  count = var.create_ec2_cpu_utilization_alarm ? 1 : 0

  alarm_name          = "${var.instance_name}-cpu-utilization-high"
  alarm_description   = "Static threshold: Average CPUUtilization for ${var.instance_name} (${aws_instance.this.id}) is greater than or equal to ${var.cloudwatch_cpu_threshold_percent}%."
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = var.cloudwatch_cpu_evaluation_periods
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = var.cloudwatch_cpu_period_seconds
  statistic           = "Average"
  threshold           = var.cloudwatch_cpu_threshold_percent
  treat_missing_data  = "notBreaching"

  dimensions = {
    InstanceId = aws_instance.this.id
  }
}
