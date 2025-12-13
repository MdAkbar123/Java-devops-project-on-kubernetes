variable "key_name" {
    description = "The name of the key pair to use for the instances"
    type        = string
    default     = "my-key-pair"
  
}
variable "private_key_path" {
  description = "Path to save the generated private key"
  type        = string
  default     = "/home/akbar-ali/.ssh/my-key-pair.pem"
}