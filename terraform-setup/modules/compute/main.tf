resource "aws_instance" "server" {
  ami             = "ami-02b8269d5e85954ef" # Ubuntu 24.04 LTS (Update for your region)
  instance_type   = var.instance_type
  key_name        = var.key_name          # Your AWS Key Pair name
  subnet_id       = var.subnet_id
  vpc_security_group_ids = [var.security_group]
  # This reads the script file you pass from the root main.tf
  # user_data = var.user_data_script

  tags = {
    Name = var.instance_name
  }
}
