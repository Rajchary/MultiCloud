


resource "aws_key_pair" "hubble_aws_keypair" {
  key_name   = "Hubble_Key"
  public_key = var.aws_pub_key
}

resource "aws_instance" "hubble_aws_vm" {
  ami                    = var.ami_id
  instance_type          = "t2.micro"
  key_name               = aws_key_pair.hubble_aws_keypair.id
  vpc_security_group_ids = [var.aws_sg_id]
  subnet_id              = var.aws_subnet_id

  tags = {
    "Name" = "Hubble_VM"
  }
}