variable "instance_name" {}
variable "instance_type" {
    description = "EC2 instance type"
    type        = string
    }
variable "security_group" {}
variable "subnet_id" {}
# variable "user_data_script" {
#     description = "User data script to configure the instance on launch "
#     type        = string
#     default     = "null"
#}

variable "key_name" {
    description = "The name of the key pair to use for the instances"
    type        = string
    # default     = "my-key-pair"
  
}
