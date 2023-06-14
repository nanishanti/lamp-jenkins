variable "aws_region"{
    description ="AWS region"
    default = "us-east-1"
}
variable "vpc_cidr_block" {
    description = "CIDR block for the VPC"
    default = "10.0.0.0/16"
}
variable "public_subnet"{
    description = "public subnet"
    default = "10.0.1.0/24"
}
variable "private_subnet"{
    description ="private subnet"
    default = "10.0.2.0/24"
}
variable  "ami_osversion"{
    description = "Linux ami version"
    default = "ami-022e1a32d3f742bd8"
}
variable "instance_type"{
    description = "Instance Type"
    default = "t2.micro"
}
variable "keypair"{
    description = "KeyPair"
    default = "prasanth_dev"
}
variable "homeip"{
    description = "Home IP"
    default = "73.147.81.220/32"
}
variable "officeip"{
    description = "Office IP"
    default = "70.106.221.84/32"
}