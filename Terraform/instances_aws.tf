# Define aws key pair for EC2
resource "aws_key_pair" "keypair_ec2_mlserve" {
  key_name   = "${var.keypair_name_ec2}"
  public_key = "${file(var.public_key_path_ec2)}"
}

# Define security group for public subnet
resource "aws_security_group" "sg_public_mlserve" {
  name        = "sg_public_mlserve"
  description = "allows all incoming http/https connection"
  vpc_id      = "${aws_vpc.vpc_mlserve.id}"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["${chomp(data.http.my_ip.body)}/32"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["${var.public_cidr_block}"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["${var.public_cidr_block}"]
  }

  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["${var.public_cidr_block}"]
  }

  ingress {
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = ["${var.public_cidr_block}"]
  }

  egress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["${var.public_cidr_block}"]
  }

  egress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["${var.public_cidr_block}"]
  }

  tags {
    Name = "ML Serve Public Security Group"
  }
}

# Define public EC2 instance
resource "aws_instance" "ec2_public_mlserve" {
  ami                         = "${var.ami_image_ubuntu_18}"
  instance_type               = "${var.instance_type_t2micro}"
  vpc_security_group_ids      = ["${aws_security_group.sg_public_mlserve.id}"]
  subnet_id                   = "${aws_subnet.subnet_public_mlserve.id}"
  key_name                    = "${var.keypair_name_ec2}"
  associate_public_ip_address = true
  depends_on                  = ["aws_internet_gateway.ig_mlserve"]

  tags {
    Name = "ML Serve Public Instance"
  }
}

# Define security group for private subnet
resource "aws_security_group" "sg_private_mlserve" {
  name        = "sg_private_mlserve"
  description = "ssh only"
  vpc_id      = "${aws_vpc.vpc_mlserve.id}"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["${chomp(data.http.my_ip.body)}/32"]
  }

  tags {
    Name = "ML Serve Private Security Group"
  }
}

# Define private EC2 instance
resource "aws_instance" "ec2_private_mlserve" {
  ami                         = "${var.ami_image_ubuntu_18}"
  instance_type               = "${var.instance_type_t2micro}"
  vpc_security_group_ids      = ["${aws_security_group.sg_private_mlserve.id}"]
  subnet_id                   = "${aws_subnet.subnet_private_mlserve.id}"
  key_name                    = "${var.keypair_name_ec2}"
  associate_public_ip_address = false

  tags {
    Name = "ML Serve Private Instance"
  }
}

# Define security group for load balancer
resource "aws_security_group" "sg_elb_mlserve" {
  name        = "sg_elb_mlserve"
  description = "allows incomming http connection"
  vpc_id      = "${aws_vpc.vpc_mlserve.id}"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["${var.public_cidr_block}"]
  }

  egress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["${var.public_cidr_block}"]
  }

  tags {
    Name = "ML Serve Elastic Load Banacer Security Group"
  }
}

# Define elastic load balancer
resource "aws_elb" "elb_public" {
  name            = "elb-public"
  subnets         = ["${aws_subnet.subnet_public_mlserve.id}"]
  security_groups = ["${aws_security_group.sg_elb_mlserve.id}"]
  instances       = ["${aws_instance.ec2_public_mlserve.id}"]

  listener {
    instance_port     = 80
    instance_protocol = "http"
    lb_port           = 80
    lb_protocol       = "http"
  }

  tags {
    Name = "ML Serve Elastic Load Balancer"
  }
}
