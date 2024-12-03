module "app_sg" {
  source = "terraform-aws-modules/security-group/aws"

  name        = "App-SG"
  description = "App SG for web app"
  vpc_id      = aws_vpc.minha_vpc.id
  ingress_with_cidr_blocks = [
    {
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      description = "Porta para minha aplicacao web de acesso"
      cidr_blocks = "0.0.0.0/0"
    }
  ]
  egress_rules        = ["all-all"]
}

module "ec2_app_instance" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "~> 3.0"

  name = "Web-App-Instance"

  ami                    = "ami-06b21ccaeff8cd686"
  instance_type          = "t2.micro"
  key_name               = "vockey"
  monitoring             = true
  vpc_security_group_ids = [module.app_sg.security_group_id]
  subnet_id              = aws_subnet.public_subnet.id
  user_data              = file("./dependencias.sh")
}

resource "aws_eip" "ec2_app_instance_ip" {
  instance = module.ec2_app_instance.id
  domain = "vpc"

  tags = {
    Name = "Web-Server-EIP"
  }
}
