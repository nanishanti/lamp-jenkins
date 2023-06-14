provider "aws"{
    region = var.aws_region
}

resource "aws_vpc" "vpc_lamp"{
    cidr_block = var.vpc_cidr_block

    tags = {
        Name = "VPC Lamp"
    }
}

resource "aws_internet_gateway" "igw_lamp"{
    vpc_id = aws_vpc.vpc_lamp.id

    tags = {
        Name = "IGW Lamp"
    }
}

resource "aws_subnet" "public_subnet" {
    vpc_id = aws_vpc.vpc_lamp.id
    cidr_block = var.public_subnet
    availability_zone = "us-east-1a"
    
    tags = {
        Name = "Public Subnet"
    }
}

resource "aws_route_table" "public_rt_table"{
    vpc_id = aws_vpc.vpc_lamp.id

    route{
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.igw_lamp.id
    }

    tags = {
        Name = "Public RT Table"
    }
    
}
resource "aws_route_table_association" "public_sb_aasociation"{
    subnet_id = aws_subnet.public_subnet.id
    route_table_id = aws_route_table.public_rt_table.id
}

resource "aws_subnet" "private_subnet" {
    vpc_id = aws_vpc.vpc_lamp.id
    cidr_block = var.private_subnet
    availability_zone ="us-east-1a"

    tags = {
        Name = "Private Subnet"
    }
}

resource "aws_route_table" "private_rt_table"{
    vpc_id = aws_vpc.vpc_lamp.id

    tags = {
        Name = "Private RT Table"
    }
}

resource "aws_route_table_association" "private_sb_association"{
    subnet_id = aws_subnet.private_subnet.id
    route_table_id = aws_route_table.private_rt_table.id
}

resource "aws_security_group" "lamp_sg"{
    name = "lamp-sg"
    description = "Allow SSH and HTTP inbound traffic"
    vpc_id = aws_vpc.vpc_lamp.id

    ingress {
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = [var.homeip, var.officeip]
    }
    ingress {
        from_port = 80
        to_port = 80
        protocol = "tcp"
        cidr_blocks =[var.homeip, var.officeip]
    }
    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }

    tags = {
        Name = "Lamp SG"
    }
}

resource "aws_security_group" "jenkins_sg"{
    name = "jenkins-sg"
    description = "Allow SSH, HTTP and Custom TCP inbound traffic"
    vpc_id = aws_vpc.vpc_lamp.id

    ingress {
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = [var.homeip, var.officeip]
    }
    ingress {
        from_port = 80
        to_port = 80
        protocol = "tcp"
        cidr_blocks = [var.homeip, var.officeip]
    }
    ingress {
        from_port = 8080
        to_port = 8080
        protocol = "tcp"
        cidr_blocks = [var.homeip, var.officeip]
    }
    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }

    tags ={
        Name = "Jenkins SG"
    }
}

resource "aws_instance" "lamp_server"{
    ami = var.ami_osversion
    instance_type = var.instance_type
    key_name = var.keypair
    subnet_id = aws_subnet.public_subnet.id
    vpc_security_group_ids = [aws_security_group.lamp_sg.id]
    source_dest_check = false
    associate_public_ip_address = true

    tags = {
        Name = "Lamp Server"
    }

    user_data = file("lampstack.sh")
}

resource "aws_instance" "jenkins_server"{
    ami = var.ami_osversion
    instance_type = var.instance_type
    key_name = var.keypair
    subnet_id = aws_subnet.public_subnet.id
    vpc_security_group_ids = [aws_security_group.jenkins_sg.id]
    associate_public_ip_address = true

    tags = {
        Name = "Jenkins Server"
    }

    user_data = file("jenkins.sh")
}
