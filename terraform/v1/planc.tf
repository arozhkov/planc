
provider "aws" {
    region = "${var.aws_region}"
    access_key = "${var.aws_access_key}"
    secret_key = "${var.aws_secret_key}"
}


resource "aws_security_group" "frontend_security_group" {
    name = "frontend_security_group"
    description = "Frontend security group (Linux)"

    # SSH access from anywhere
    ingress {
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    # HTTP access from anywhere
    ingress {
        from_port = 80
        to_port = 80
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    # HTTP access from anywhere
    ingress {
        from_port = 443
        to_port = 443
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    # outbound internet access
    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
}

resource "aws_security_group" "middleware_security_group" {
    name = "middleware_security_group"
    description = "Middleware security group (Windows)"

    # RDP access from anywhere
    ingress {
        from_port = 3389
        to_port = 3389
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    
    # winrm
    ingress {
        from_port = 5985
        to_port = 5986
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    # HTTP access from anywhere
    ingress {
        from_port = 7000
        to_port = 7010
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    # outbound internet access
    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
}


resource "aws_instance" "frontend" {
  # The connection block tells our provisioner how to
  # communicate with the resource (instance)
  connection {
    # The default username for our AMI
    user = "ec2-user"

    # The path to your keyfile
    key_file = "${var.key_path}"
  }

  instance_type = "t2.micro"

  # Lookup the correct AMI based on the region
  # we specified
  ami = "${lookup(var.aws_amis_frontend, var.aws_region)}"

  # The name of our SSH keypair you've created and downloaded
  # from the AWS console.
  #
  # https://console.aws.amazon.com/ec2/v2/home?region=us-west-2#KeyPairs:
  #
  key_name = "${var.key_name}"

  # Our Security group to allow HTTP and SSH access
  security_groups = ["${aws_security_group.frontend_security_group.name}"]

  # We run a remote provisioner on the instance after creating it.
  # In this case, we just install nginx and start it. By default,
  # this should be on port 80
  # provisioner "remote-exec" {
  #   inline = [
  #       "sudo apt-get -y update",
  #       "sudo apt-get -y install nginx",
  #       "sudo service nginx start"
  #   ]
  # }

  tags =  {
    Name = "NGINX-${count.index}"
  }

  count = 2

  provisioner "remote-exec" {
    inline = ["df -h"]
  }
}

resource "aws_instance" "middleware" {
  # The connection block tells our provisioner how to
  # communicate with the resource (instance)
  connection {
    # The default username for our AMI
    type = "winrm"
    user = "Administrator"
    password = "A1exande8"

    # https = true
    # insecure = true

    # The path to your keyfile
    # key_file = "${var.key_path}"
  }

  instance_type = "t2.micro"

  # Lookup the correct AMI based on the region
  # we specified
  ami = "${lookup(var.aws_amis_middleware, var.aws_region)}"

  # The name of our SSH keypair you've created and downloaded
  # from the AWS console.
  #
  # https://console.aws.amazon.com/ec2/v2/home?region=us-west-2#KeyPairs:
  #
  key_name = "${var.key_name}"

  # Our Security group to allow HTTP and SSH access
  security_groups = ["${aws_security_group.middleware_security_group.name}"]

  # We run a remote provisioner on the instance after creating it.
  # In this case, we just install nginx and start it. By default,
  # this should be on port 80
  # provisioner "remote-exec" {
  #   inline = [
  #       "sudo apt-get -y update",
  #       "sudo apt-get -y install nginx",
  #       "sudo service nginx start"
  #   ]
  # }

  tags =  {
    Name = "WLS-${count.index}"
  }

  count = 2

  provisioner "remote-exec" {
    inline = ["dir c:\\"]

  }
}
