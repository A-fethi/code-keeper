resource "aws_acm_certificate" "self_signed" {
  private_key      = file("${path.module}/alb-selfsigned.key")
  certificate_body = file("${path.module}/alb-selfsigned.crt")

  lifecycle {
    create_before_destroy = true
  }

  tags = {
    Name = "cloud-design-self-signed-cert"
  }
}