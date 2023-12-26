
resource "aws_instance" "app-1-servers" {
  count                       = length(var.subnet_cidrs_private)
  ami                         = "ami-0a2e7efb4257c0907"
  instance_type               = "t2.micro"
  associate_public_ip_address = true
  vpc_security_group_ids      = [aws_security_group.ec2_instance.id]
  subnet_id                   = element(aws_subnet.app-1-private-subnets.*.id, count.index)

  user_data = file("data/user_data.sh")

  tags = {
    Name : "app-1-server_${count.index + 1}"
  }
}
