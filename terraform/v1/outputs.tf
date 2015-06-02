

output "frontends_public" {
  value = "${aws_instance.frontend.0.public_ip}"
}

output "middleware_private" {
  value = "${aws_instance.middleware.0.private_ip}"
}

