# -----------------------------------------------------------------------------
# ECS Service Module — Amazon ECS Fargate
# Creates an ECS task definition and service with rolling deployment
# and circuit breaker rollback.
#
# Features:
#   - Fargate task definition with secrets and environment injection
#   - Optional EFS volume mount with transit encryption
#   - Rolling deployment with configurable min/max healthy percent
#   - Circuit breaker with automatic rollback
#   - ALB target group integration for health checks
#
# Requirements: 3.1, 3.2, 3.3, 3.4, 4.1, 4.2, 4.3, 8.1, 8.2
# -----------------------------------------------------------------------------

locals {
  has_efs = var.efs_file_system_id != ""

  container_definition = {
    name      = var.name
    image     = var.container_image
    essential = true

    portMappings = [
      {
        containerPort = var.container_port
        protocol      = "tcp"
      }
    ]

    environment = var.environment
    secrets     = var.secrets

    mountPoints = local.has_efs ? [
      {
        sourceVolume  = "efs-volume"
        containerPath = var.efs_container_path
        readOnly      = false
      }
    ] : []

    logConfiguration = {
      logDriver = "awslogs"
      options = {
        "awslogs-group"         = var.log_group
        "awslogs-region"        = var.aws_region
        "awslogs-stream-prefix" = "ecs"
      }
    }
  }
}

# =============================================================================
# Task Definition
# =============================================================================

resource "aws_ecs_task_definition" "this" {
  family                   = var.name
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = var.cpu
  memory                   = var.memory
  execution_role_arn       = var.task_execution_role_arn
  task_role_arn            = var.task_role_arn

  container_definitions = jsonencode([local.container_definition])

  # EFS volume (conditional)
  dynamic "volume" {
    for_each = local.has_efs ? [1] : []
    content {
      name = "efs-volume"

      efs_volume_configuration {
        file_system_id     = var.efs_file_system_id
        transit_encryption = "ENABLED"
      }
    }
  }

  tags = var.tags
}

# =============================================================================
# ECS Service
# =============================================================================

resource "aws_ecs_service" "this" {
  name            = var.name
  cluster         = var.cluster_id
  task_definition = aws_ecs_task_definition.this.arn
  desired_count   = var.desired_count
  launch_type     = "FARGATE"

  # Rolling deployment configuration
  deployment_minimum_healthy_percent = var.deployment_minimum_healthy_percent
  deployment_maximum_percent         = var.deployment_maximum_percent
  health_check_grace_period_seconds  = var.health_check_grace_period_seconds

  # Circuit breaker with rollback
  deployment_circuit_breaker {
    enable   = var.enable_circuit_breaker
    rollback = var.enable_rollback
  }

  # Network configuration
  network_configuration {
    subnets          = var.subnet_ids
    security_groups  = var.security_group_ids
    assign_public_ip = var.assign_public_ip
  }

  # ALB target group
  load_balancer {
    target_group_arn = var.target_group_arn
    container_name   = var.name
    container_port   = var.container_port
  }

  # Ignore changes to task_definition and desired_count since CodePipeline
  # manages deployments and autoscaling may adjust count
  lifecycle {
    ignore_changes = [task_definition, desired_count]
  }

  tags = var.tags
}
