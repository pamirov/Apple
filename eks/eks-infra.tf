# This is our VPC
resource "aws_vpc" "eks_vpc" {
    cidr_block = var.cidr_vpc

    tags = {
      Name = "eks_vpc"
    }
}

# These are our private subnets
resource "aws_subnet" "eks_pr_subnets" {
    count = length(var.pr_cidr)
    vpc_id = aws_vpc.eks_vpc.id
    cidr_block = var.pr_cidr[count.index]
    availability_zone = var.azs[count.index % length(var.azs)]
    map_public_ip_on_launch = false

    tags = {
      Name = var.pr_cidr_tag[count.index]
    }
}

# These are our public subnets
resource "aws_subnet" "eks_pub_subnets" {
    count = length(var.pub_cidr)
    vpc_id = aws_vpc.eks_vpc.id
    cidr_block = var.pub_cidr[count.index]
    availability_zone = var.azs[(count.index + 1) % length(var.azs)]
    map_public_ip_on_launch = true
    
    tags = {
      Name = var.pub_cidr_tag[count.index]
    }
}

resource "aws_route_table" "rt_pr" {
    count = length(var.azs)
    vpc_id = aws_vpc.eks_vpc.id

    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_nat_gateway.nat_gw[count.index].id
    }

    tags = {
        Name = "rt for nat gw"
    }
  
}

#This is our Route Table
resource "aws_route_table" "rt_pub" {
    vpc_id = aws_vpc.eks_vpc.id

    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.igw.id
    }

    tags = {
        Name = "eks_rt_pub"
    }
  
}


#This is our RT  Public association
resource "aws_route_table_association" "eks_rt_as" {
    count = length(var.pub_cidr)
    subnet_id = aws_subnet.eks_pub_subnets[count.index].id
    route_table_id = aws_route_table.rt_pub.id
}

#This is our RT  Private association
resource "aws_route_table_association" "eks_rt_nat" {
  count          = length(var.pr_cidr)
  subnet_id      = aws_subnet.eks_pr_subnets[count.index].id
  route_table_id = aws_route_table.rt_pr[count.index].id
}

#This is our IGW
resource "aws_internet_gateway" "igw" {
    vpc_id = aws_vpc.eks_vpc.id

    tags = {
      Name = "eks_igw"
    } 
}

#This is our Elastic IP
resource "aws_eip" "nat_eip" {
  count = length(var.azs)
  depends_on = [ aws_internet_gateway.igw ]
}

#This is our NAT Gateway
resource "aws_nat_gateway" "nat_gw" {
    count = length(var.pub_cidr)
    allocation_id = aws_eip.nat_eip[count.index].id
    subnet_id = aws_subnet.eks_pub_subnets[count.index].id

    tags = {
      Name = "eks_nat"
    }

    depends_on = [ aws_internet_gateway.igw ]
  
}

#This is our SGs
resource "aws_security_group" "eks_sg" {
    name = "eks-sg"
    description = "security group for eks cluster"
    vpc_id = aws_vpc.eks_vpc.id
  
}

#This is our SG rules
resource "aws_security_group_rule" "eks_rule_https" {
    type = "ingress"
    description = "Allow HTTPS"
    from_port = 443
    to_port = 443 
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    security_group_id = aws_security_group.eks_sg.id
  
}

#This is our SG rules
resource "aws_security_group_rule" "eks_rule_http" {
    type = "ingress"
    description = "Allow HTTP"
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    security_group_id = aws_security_group.eks_sg.id
  
}

#This is our SG rules
resource "aws_security_group_rule" "eks_rule_all" {
    type = "egress"
    description = "Allow all"
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    security_group_id = aws_security_group.eks_sg.id
  
}
