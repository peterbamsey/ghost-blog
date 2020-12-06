# Load balancer
resource "aws_lb" "lb" {
  load_balancer_type = var.lb-type
  name               = "${var.environment}-${var.app-name}"
  security_groups    = [aws_security_group.sg.id]
  subnets            = var.subnets
  tags               = var.tags
}

# Listener for direct 443 connections and redirect from port 80
resource "aws_lb_listener" "listener" {
  load_balancer_arn = aws_lb.lb.arn
  port              = var.listener-port
  protocol          = var.listener-protocol
  ssl_policy        = var.ssl-policy
  certificate_arn   = aws_acm_certificate.cert.arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tg.arn
  }
}

resource "aws_lb_listener" "redirect" {
  load_balancer_arn = aws_lb.lb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type = "redirect"

    redirect {
      port        = var.listener-port
      protocol    = var.listener-protocol
      status_code = "HTTP_301"
    }
  }
}

# Target group for the ALB
resource "aws_lb_target_group" "tg" {
  name = "${var.environment}-${var.app-name}"
  health_check {
    interval = 30
    path     = "/"
  }
  port        = var.target-port
  protocol    = var.protocol
  target_type = var.target-type
  vpc_id      = var.vpc-id

  depends_on = [aws_lb.lb]
}

# Create Certificate
resource "aws_acm_certificate" "cert" {
  domain_name = var.domain-name
  subject_alternative_names = [
    "*.${var.domain-name}",
    "${var.sub-domain}.${var.domain-name}"
  ]
  tags              = var.tags
  validation_method = "DNS"

  lifecycle {
    create_before_destroy = true
  }
}

# Use Route 53 records to validate the certificate automatically
data "aws_route53_zone" "zone" {
  name         = var.domain-name
  private_zone = false
}

resource "aws_route53_record" "validation" {
  for_each = {
    for dvo in aws_acm_certificate.cert.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  type            = each.value.type
  zone_id         = data.aws_route53_zone.zone.zone_id
}

# Map the certificate to the listener
resource "aws_lb_listener_certificate" "listener-cert" {
  listener_arn    = aws_lb_listener.listener.arn
  certificate_arn = aws_acm_certificate.cert.arn
}

# Security group for the ALB to allow traffic from outside
resource "aws_security_group" "sg" {
  name = "${var.environment}-${var.app-name}-lb"

  ingress {
    description = "HTTP from Internet"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "TLS from Internet"
    from_port   = var.listener-port
    to_port     = var.listener-port
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags   = var.tags
  vpc_id = var.vpc-id
}

# Create a DNS record to point the subdomain to the load balancer
resource "aws_route53_record" "sub" {
  zone_id = data.aws_route53_zone.zone.id
  name    = "${var.sub-domain}.${var.domain-name}"
  type    = "A"

  alias {
    name                   = aws_lb.lb.dns_name
    zone_id                = aws_lb.lb.zone_id
    evaluate_target_health = false
  }
}