resource "aws_ecs_cluster" "service" {
  name = "${var.service_name}-${var.env}"
  tags = merge(local.default_tags, {})
}

resource "aws_ecs_service" "service" {
  name             = "${var.service_name}-${var.env}"
  cluster          = aws_ecs_cluster.service.id
  task_definition  = aws_ecs_task_definition.service.arn
  desired_count    = var.number_of_tasks
  launch_type      = "FARGATE"
  platform_version = "1.4.0"

  network_configuration {
    assign_public_ip = false
    security_groups  = [aws_security_group.service.id]
    subnets          = [for subnet in aws_subnet.private : subnet.id]
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.main.arn
    container_name   = "${var.service_name}-${var.env}"
    container_port   = 8000
  }

  depends_on = [
    aws_iam_role_policy.ecs_task,
    aws_lb_target_group.main
  ]
  tags = merge(local.default_tags, {})
}

data "template_file" "task_definition" {
  template = file("${path.module}/task_definition.json.tpl")

  vars = {
    service_name = var.service_name
    image        = var.image
    region       = var.region
    account      = data.aws_caller_identity.current.id
    #repo_credential = var.repo_credential
    dump_dir = var.dump_dir
    env      = var.env
    efs_id   = aws_efs_file_system.main.id
  }
}

resource "aws_ecs_task_definition" "service" {
  family                   = "${var.service_name}_${var.env}"
  container_definitions    = data.template_file.task_definition.rendered
  network_mode             = "awsvpc"
  task_role_arn            = aws_iam_role.ecs_task.arn
  execution_role_arn       = local.ecs_execution_role
  cpu                      = 256
  memory                   = 512
  requires_compatibilities = ["FARGATE"]

  volume {
    name = var.dump_dir
    efs_volume_configuration {
      file_system_id = aws_efs_file_system.main.id
      root_directory = "/"
    }
  }

  tags = merge(local.default_tags, {})
}