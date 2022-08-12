output "ecs_cluster" {
  value = aws_ecs_cluster.fargate-cluster.id
}

output "frontend_alb_arn" {
  value = aws_lb.front_end.arn
}

output "target_group_b_arn" {
  value =  aws_lb_target_group.demo-tgroup-b.arn
}