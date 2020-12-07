locals {
  dahboard-name = "${var.environment}-${var.app-name}"
  all-widgets   = [template_file.ecs-cpu.rendered, template_file.ecs-memory.rendered]
  widget-list   = join(",", local.all-widgets)
}

resource "aws_cloudwatch_dashboard" "main" {
  dashboard_name = local.dahboard-name

  dashboard_body = template_file.dashboard.rendered
}

resource "template_file" "dashboard" {
  template = "${file("${path.module}/templates/dashboard.json")}"

  vars = {
    rendered-widgets = template_file.ecs-cpu.rendered
  }
}

resource "template_file" "ecs-cpu" {
  template = "${file("${path.module}/templates/widgets/ecs-cpu.json")}"

  vars = {
    ecs-service-name = var.app-name
    ecs-cluster-name = var.app-name
  }
}

resource "template_file" "ecs-memory" {
  template = "${file("${path.module}/templates/widgets/ecs-memory.json")}"

  vars = {
    ecs-service-name = var.app-name
    ecs-cluster-name = var.app-name
  }
}
