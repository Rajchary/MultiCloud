
#========================================> AWS_Compute main.tf <===========================================

resource "aws_key_pair" "hubble_aws_keypair" {
  key_name   = "Hubble_Key"
  public_key = var.aws_pub_key
}

resource "aws_lb_target_group" "hubble_tg" {
  name     = "HUbble-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.vpc_id
  lifecycle {
    ignore_changes        = [name]
    create_before_destroy = true
  }
}

resource "aws_launch_template" "hubble_app_lt" {
  name                   = "HUbble_Launch_Template"
  instance_type          = "t2.micro"
  image_id               = var.ami_id
  vpc_security_group_ids = [var.aws_sg_ids.sts_sg, var.aws_sg_ids.midtier_sg]
  user_data              = filebase64(var.userData_path)
  key_name               = aws_key_pair.hubble_aws_keypair.id
  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "Hubble_App"
    }
  }
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "hubble_asg" {
  name                = "Hubble_ASG"
  vpc_zone_identifier = var.aws_subnet_id
  desired_capacity    = 2
  max_size            = 2
  min_size            = 1
  target_group_arns   = [aws_lb_target_group.hubble_tg.arn]

  launch_template {
    id      = aws_launch_template.hubble_app_lt.id
    version = "$Latest"
  }
  lifecycle {
    create_before_destroy = true
    ignore_changes        = [desired_capacity]
  }
}

resource "aws_lb" "hubble_alb" {
  name            = "hubble-alb"
  subnets         = var.aws_subnet_id
  security_groups = [var.aws_sg_ids.sts_sg, var.aws_sg_ids.frontier_sg]
  idle_timeout    = 400
}

resource "aws_lb_listener" "hubble_lb_listener" {
  load_balancer_arn = aws_lb.hubble_alb.arn
  port              = 80
  protocol          = "HTTP"
  default_action {
    target_group_arn = aws_lb_target_group.hubble_tg.arn
    type             = "forward"
  }
}