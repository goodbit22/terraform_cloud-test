resource "digitalocean_project" "main" {
    name = "Szkolenia Cloud Example"
    description = "This is a project"
    purpose = "This project"
    environment = "development"
    resource = digitalocean_droplet.main.id
}

resource "digitalocean_vpc" "main" {
    name = "Szkolenia Cloud Example VPC "
    region = "fral"
    description = "This is a VPC for the Szkolenia Cloud Example"
    ip_range = "10.0.0.0/24"
}

resource "digitalocean_droplet" "main" {
    name = "Szkolenia Cloud Example Droplet"
    image = "ubuntu-202-04-x64"
    region = "fral"
    size = "s-1vcpu-1gb"
    vpc_uuid = digitalocean_vpc.main.id
}
resource "digitalocean_firewall" "main" {
    name = "Szkolenia Cloud Example Firewall"
    droplet_ids = [digitalocean_droplet.main.id]
    inbound_rule {
        protocol = "tcp"
        port_range = "22"
    }
}

resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/24"
  enable_dns_support = true 
  enable_dns_hostnames = true
}

resource "aws_subnet" "main" {
  vpc_id = aws_vpc.main.id
  cidr_block = "10.0.0.0/24"
  availability_zone = "eu-cental-id"
}

resource "aws_internet_gateway" "main" {
    vpc_id = aws_vpc.main.id  
}


resource "aws_route_table" "main" {
    vpc_id = aws_vpc.main.id  
    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.main
    }
}

resource "aws_route_table_association" "main" {
    subnet_id = aws_subnet.main.id 
    route_table_id = aws_route_table.main.id 
}

resource "aws_security_group" "main" {
    name = "Szkolenia Cloud Example Security Group"
    vpc_id = aws_vpc.main.id
    ingress {
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
}

resource "aws_instance" "main" {
    ami = "ami-07"
    instance_type = "t2.micro"
    subnet_id = aws_subnet.main.id
    vpc_security_group_ids = [aws_security_group.main.id]
    associate_public_ip_address = true
}