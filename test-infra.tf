# -----------------------------------------------------------------------------
# Test Infrastructure
# Creates supporting resources for hello world testing in the sandbox account.
# REMOVE THIS FILE when deploying to the customer environment (where ECS cluster,
# ALB, VPC, and security groups already exist).
# -----------------------------------------------------------------------------

# =============================================================================
# VPC + Networking (for test only)
# =============================================================================

resource "aws_vpc" "test" {
  cidr_block           = "10.100.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = merge(local.common_tags, { Name = "${local.name_prefix}-test-vpc" })
}

resource "aws_internet_gateway" "test" {
  vpc_id = aws_vpc.test.id
  tags   = merge(local.common_tags, { Name = "${local.name_prefix}-igw" })
}

resource "aws_subnet" "public_a" {
  vpc_id                  = aws_vpc.test.id
  cidr_block              = "10.100.1.0/24"
  availability_zone       = "${var.aws_region}a"
  map_public_ip_on_launch = true
  tags                    = merge(local.common_tags, { Name = "${local.name_prefix}-public-a" })
}

resource "aws_subnet" "public_b" {
  vpc_id                  = aws_vpc.test.id
  cidr_block              = "10.100.2.0/24"
  availability_zone       = "${var.aws_region}b"
  map_public_ip_on_launch = true
  tags                    = merge(local.common_tags, { Name = "${local.name_prefix}-public-b" })
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.test.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.test.id
  }

  tags = merge(local.common_tags, { Name = "${local.name_prefix}-public-rt" })
}

resource "aws_route_table_association" "public_a" {
  subnet_id      = aws_subnet.public_a.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "public_b" {
  subnet_id      = aws_subnet.public_b.id
  route_table_id = aws_route_table.public.id
}

# =============================================================================
# ECS Cluster
# =============================================================================

resource "aws_ecs_cluster" "this" {
  name = "${local.name_prefix}-cluster"
  tags = local.common_tags
}

# =============================================================================
# Security Group — ECS Tasks
# =============================================================================

resource "aws_security_group" "ecs_tasks" {
  name        = "${local.name_prefix}-ecs-tasks-sg"
  description = "Security group for ECS tasks"
  vpc_id      = aws_vpc.test.id

  ingress {
    description     = "Allow traffic from ALB"
    from_port       = var.librechat_container_port
    to_port         = var.librechat_container_port
    protocol        = "tcp"
    security_groups = [aws_security_group.alb.id]
  }

  egress {
    description = "Allow all outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = local.common_tags
}

# =============================================================================
# Security Group — ALB
# =============================================================================

resource "aws_security_group" "alb" {
  name        = "${local.name_prefix}-alb-sg"
  description = "Security group for Application Load Balancer"
  vpc_id      = aws_vpc.test.id

  ingress {
    description = "Allow HTTP from my IP only"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["128.119.53.98/32"]
  }

  egress {
    description = "Allow all outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = local.common_tags
}

# =============================================================================
# Application Load Balancer
# =============================================================================

resource "aws_lb" "this" {
  name               = "${local.name_prefix}-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb.id]
  subnets            = [aws_subnet.public_a.id, aws_subnet.public_b.id]

  tags = local.common_tags
}

resource "aws_lb_target_group" "librechat" {
  name        = "${local.name_prefix}-lc-tg"
  port        = var.librechat_container_port
  protocol    = "HTTP"
  vpc_id      = aws_vpc.test.id
  target_type = "ip"

  health_check {
    enabled             = true
    healthy_threshold   = 2
    unhealthy_threshold = 3
    timeout             = 5
    interval            = 30
    path                = "/"
    matcher             = "200"
  }

  tags = local.common_tags
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.this.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.librechat.arn
  }

  tags = local.common_tags
}

# =============================================================================
# Outputs — Test Infrastructure
# =============================================================================

output "alb_dns_name" {
  description = "DNS name of the ALB (internal — only accessible from within VPC)"
  value       = aws_lb.this.dns_name
}

output "ecs_cluster_name" {
  description = "Name of the ECS cluster created for testing"
  value       = aws_ecs_cluster.this.name
}
