resource "aws_cloudwatch_log_group" "springbootapp_log_group" {
  name = "${var.ecs_service_name}-LogGroup"
}

resource "aws_ecs_cluster" "fargate-cluster" {
  name = var.ecs_cluster_name
  setting {
    name  = "containerInsights"
    value = "enabled"
  }
}

data "template_file" "ecs_task_definition_template" {
  template = file("${path.module}/task_definition.json")
  vars = {
    task_definition_name  = "${var.ecs_service_name}-container"
    ecs_service_name      = var.ecs_service_name
    docker_image_url      = var.docker_image_url
    memory                = var.memory
    docker_container_port = var.docker_container_port
    region                = var.region
    message               = var.message
  }
}

resource "aws_ecs_task_definition" "ecs-task-definition" {
  container_definitions    = data.template_file.ecs_task_definition_template.rendered
  family                   = var.ecs_service_name
  cpu                      = var.cpu
  memory                   = var.memory
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  execution_role_arn       = var.execution_role_arn
  task_role_arn            = var.task_role_arn
}


resource "aws_ecs_service" "ecs_service" {
  name            = var.ecs_service_name
  task_definition = aws_ecs_task_definition.ecs-task-definition.arn
  desired_count   = var.desired_task_number
  cluster         = aws_ecs_cluster.fargate-cluster.id
  launch_type     = "FARGATE"
  deployment_controller {
    type = "ECS"
  }
  load_balancer {
    target_group_arn = aws_lb_target_group.demo-tgroup.arn
    container_name   = "${var.ecs_service_name}-container"
    container_port   = var.docker_container_port
  }
  network_configuration {
    subnets          = var.private_subnets
    security_groups  = [var.ecs_security_group]
    assign_public_ip = false
  }

  lifecycle {
    ignore_changes = [
      desired_count
      # task_definition
    ]
  }
}

resource "aws_lb" "front_end" {
  name               = "front-end-lb-tf"
  internal           = false
  load_balancer_type = "application"
  security_groups    = var.security_groups
  subnets            = var.subnets[0]
}

resource "aws_lb_target_group" "demo-tgroup" {
  name        = "tf-demo-lb-tg"
  port        = var.docker_container_port
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = var.vpc_id

  depends_on = [
    aws_lb.front_end
  ]
}

resource "aws_lb_target_group" "demo-tgroup-b" {
  name        = "tf-demo-lb-tg-b"
  port        = var.docker_container_port
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = var.vpc_id
  depends_on = [
    aws_lb.front_end
  ]
}

resource "aws_lb_listener" "front_end" {
  load_balancer_arn = aws_lb.front_end.arn
  port              = var.docker_container_port
  protocol          = "HTTP"
  # ssl_policy        = "ELBSecurityPolicy-2016-08"
  # certificate_arn   = "arn:aws:iam::187416307283:server-certificate/test_cert_rab3wuqwgja25ct3n4jdj2tzu4"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.demo-tgroup.arn
  }
}

resource "aws_lb_listener_rule" "static" {
  listener_arn = aws_lb_listener.front_end.arn
  priority     = 100

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.demo-tgroup-b.arn
  }

  # condition {
  #   path_pattern {
  #     values = ["/default/*"]
  #   }
  # }

  condition {
    http_header {
      http_header_name = "optional-header"
      values           = ["3559"]
    }
  }
}

