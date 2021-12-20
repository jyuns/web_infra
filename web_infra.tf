resource "aws_key_pair" "educook_kr_admin" {
	key_name = var.key_name
	public_key = file(var.public_key_src)
}

resource "aws_vpc" "prod_vpc" {
	cidr_block = "10.10.0.0/16"
	enable_dns_hostnames = true
	enable_dns_support = true
	instance_tenancy = "default"
}

resource "aws_default_route_table" "prod_default_route_table" {
	default_route_table_id = aws_vpc.prod_vpc.default_route_table_id
	tags = {
		name = "default"
	}
}

// public subnet에 연결할 외부 연결 라우팅 테이블
resource "aws_route" "prod_internet_access" {
	route_table_id = aws_vpc.prod_vpc.default_route_table_id
	destination_cidr_block = "0.0.0.0/0"
	gateway_id = aws_internet_gateway.prod_igw.id
}

resource "aws_eip" "prod_nat_eip" {
	vpc = true
	depends_on = [aws_internet_gateway.prod_igw]
}

resource "aws_nat_gateway" "prod_nat" {
	allocation_id = aws_eip.prod_nat_eip.id
	subnet_id = aws_subnet.prod_public_subnet.id
	depends_on = [aws_internet_gateway.prod_igw]
}

resource "aws_route_table" "prod_private_route_table" {
	vpc_id = aws_vpc.prod_vpc.id
	tags = {
		name = "private"
	}
}

resource "aws_route" "prod_private_route" {
	route_table_id = aws_route_table.prod_private_route_table.id
	destination_cidr_block = "0.0.0.0/0"
	nat_gateway_id = aws_nat_gateway.prod_nat.id
}

data "aws_availability_zone" "prod_az" {
	name = "ap-northeast-2a"
}

resource "aws_subnet" "prod_public_subnet" {
	vpc_id = aws_vpc.prod_vpc.id
	cidr_block = "10.10.1.0/24"
	map_public_ip_on_launch = true
	availability_zone = data.aws_availability_zone.prod_az.name
}

resource "aws_subnet" "prod_private_subnet" {
	vpc_id = aws_vpc.prod_vpc.id
	cidr_block = "10.10.2.0/24"
	availability_zone = data.aws_availability_zone.prod_az.name
}

resource "aws_internet_gateway" "prod_igw" {
	vpc_id = aws_vpc.prod_vpc.id
	tags = {
		name = "internet-gateway"
	}
}


resource "aws_security_group" "ssh" {
	name = "allow_ssh_from_all"
	vpc_id = aws_vpc.prod_vpc.id
	description = "Allow SSH port from all"
	ingress {
		from_port = 22
		to_port = 22
		protocol = "tcp"
		cidr_blocks = ["0.0.0.0/0"]
	}
}

resource "aws_security_group" "tcp_jenkins" {
	name = "allow_tcp_jenkins_from_all"
	vpc_id = aws_vpc.prod_vpc.id
	description = "Allow TCP Jenkins port from all"
	ingress {
		from_port = 8181
		to_port = 8181
		protocol = "tcp"
		cidr_blocks = ["0.0.0.0/0"]
	}
}


data "aws_security_group" "prod_default" {
	name = "default"
	vpc_id = aws_vpc.prod_vpc.id
}

data "template_file" "public_instance_init_sh" {
	template = file("./userData/public_instance_init.sh")
}

data "template_file" "private_instance_init_sh" {
	template = file("./userData/private_instance_init.sh")
}

resource "aws_instance" "prod_public_instance" {
	ami = "ami-0ed11f3863410c386"
	instance_type = "t2.micro"
	key_name = aws_key_pair.educook_kr_admin.key_name
	vpc_security_group_ids = [
		aws_security_group.ssh.id,
		aws_security_group.tcp_jenkins.id,
		data.aws_security_group.prod_default.id
	]
	subnet_id = aws_subnet.prod_public_subnet.id
	associate_public_ip_address = true

	user_data = data.template_file.public_instance_init_sh.rendered

    tags {
        Name = "educook_public_instance"
    }

}

resource "aws_eip" "prod_public_instance_eip" {
	vpc = true
	instance = aws_instance.prod_public_instance.id
	depends_on = [aws_internet_gateway.prod_igw]
}


resource "aws_instance" "prod_private_instance" {
	ami = "ami-0ed11f3863410c386"
	instance_type = "t2.micro"
	key_name = aws_key_pair.educook_kr_admin.key_name
	subnet_id = aws_subnet.prod_private_subnet.id

	user_data = data.template_file.private_instance_init_sh.rendered

    tags {
        Name = "educook_private_instance"
    }

}