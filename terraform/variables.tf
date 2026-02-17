variable "aws_region" {
  description = "AWS region"
  default     = "ap-south-1"
}

variable "instance_type" {
  description = "EC2 instance type"
  default     = "t3.micro"
}

variable "key_name" {
  description = "EC2 Key Pair Name"
  default     = "python-web-server"
}

variable "subnet_id" {
  description = "Subnet ID"
  default     = "subnet-0ece98ce546951ed5"
}