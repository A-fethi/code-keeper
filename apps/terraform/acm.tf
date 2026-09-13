# 1. Generate Private Key dynamically in memory
resource "tls_private_key" "self_signed" {
  algorithm = "RSA"
  rsa_bits  = 2048
}

# 2. Generate Self-Signed Certificate dynamically
resource "tls_self_signed_cert" "self_signed" {
  private_key_pem = tls_private_key.self_signed.private_key_pem

  subject {
    common_name  = "cloud-design.local"
    organization = "Cloud Design Inc"
  }

  validity_period_hours = 8760 # 1 year

  allowed_uses = [
    "key_encipherment",
    "digital_signature",
    "server_auth",
  ]
}

# 3. Import Certificate into AWS Certificate Manager (ACM)
resource "aws_acm_certificate" "self_signed" {
  private_key      = tls_private_key.self_signed.private_key_pem
  certificate_body = tls_self_signed_cert.self_signed.cert_pem

  lifecycle {
    create_before_destroy = true
  }

  tags = {
    Name = "cloud-design-self-signed-cert"
  }
}