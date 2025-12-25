variable "cidr_blocks" {
  description = "List of CIDR blocks allowed to access the resources"
  type        = list(string)
  default     = ["152.57.175.27/32"]
  
}
variable "vpc_id" {
  description = "The ID of the VPC where security groups will be created"
  type        = string
  
}