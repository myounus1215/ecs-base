output "vpc_id" {
  value = module.networking.vpc_id
}

output "public_subnets" {
  value = module.networking.public_subnets
}

output "private_subnets" {
  value = module.networking.private_subnets
}

output "ecs_security_group" {
  value = module.security_group.ecs_security_group
}

output "execution_role_arn" {
  value = module.iam.execution_role_arn
}

output "task_role_arn" {
  value = module.iam.task_role_arn
}

output "ecs_cluster" {
  value = module.ecs.ecs_cluster
}

output "frontend_alb_arn" {
  value = module.ecs.frontend_alb_arn
}

output "target_group_b_arn" {
  value =  module.ecs.target_group_b_arn
}