# 1. The Virtual Private Cloud (The "Walls" of our castle)
resource "aws_vpc" "safari_vpc" {
  cidr_block           = "10.0.0.0/16" # Defines IPs from 10.0.0.0 to 10.0.255.255
  enable_dns_support   = true
  enable_dns_hostnames = true
  
  tags = {
    Name = "SafariBank-Cloud"
  }
}

# 2. The Subnet (A specific room in the castle)
resource "aws_subnet" "eks_subnet" {
  vpc_id            = aws_vpc.safari_vpc.id
  cidr_block        = "10.0.1.0/24" # Defines IPs from 10.0.1.0 to 10.0.1.255
  availability_zone = "us-east-1a"
  
  tags = {
    Name = "Safari-EKS-Subnet"
  }
}

# 3. Security Group (The Firewall)
resource "aws_security_group" "internal_trust" {
  name        = "internal-trust-sg"
  description = "Allow all traffic within the VPC"
  vpc_id      = aws_vpc.safari_vpc.id

  # Ingress: Allow anyone inside 10.0.0.0/16 to talk to anyone else
  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1" # "-1" means ALL protocols (TCP, UDP, ICMP)
    cidr_blocks = ["10.0.0.0/16"]
  }

  # Egress: Allow servers to talk to the outside world (e.g., to download updates)
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
