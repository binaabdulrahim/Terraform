# - - - loadbalancing/outputs.tf - - - 

output "lb_target_group_arn" {
  value = aws_lb_target_group.tf_tg.arn
}

output "lb_endpoint" {
  value = aws_lb.tf_lb.dns_name
}