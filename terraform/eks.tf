# Configure AWS Provider
provider "aws" {
  region = "us-east-1" # Replace with your desired region
}

# Create a VPC
resource "aws_vpc" "my_vpc" {
  cidr_block = "10.0.0.0/16"
}

# Create a public subnet for worker nodes
resource "aws_subnet" "public_subnet" {
  vpc_id            = aws_vpc.my_vpc.id
  cidr_block         = "10.0.1.0/24"
  availability_zone = "us-east-1a"

  tags = {
    Name = "PublicSubnet"
  }
}

# Create a security group for the worker nodes (allowing SSH and Kubernetes API access)
resource "aws_security_group" "worker_group" {
  name        = "worker-security-group"
  vpc_id      = aws_vpc.my_vpc.id

  ingress {
    from_port         = 22
    to_port           = 22
    protocol          = "tcp"
    cidr_blocks       = ["0.0.0.0/0"]  # Allow SSH from anywhere (adjust for security)
  }

  ingress {
    from_port         = 6443
    to_port           = 6443
    protocol          = "tcp"
    cidr_blocks       = [aws_subnet.public_subnet.cidr_block]  # Allow API access from the public subnet
  }

  egress {
    from_port         = 0
    to_port           = 0
    protocol          = "-1"
    cidr_blocks       = ["0.0.0.0/0"]  # Allow all outbound traffic (adjust for security)
  }
}

# Create an EKS cluster with worker nodes in the public subnet
resource "aws_eks_cluster" "my_eks_cluster" {
  name          = "my-eks-cluster"
  role_arn       = aws_iam_role.eks_cluster_role.arn
  vpc_config {
    security_group_ids = [aws_security_group.worker_group.id]
    subnet_ids        = [aws_subnet.public_subnet.id]
  }
}

# IAM Role for EKS Cluster (replace with your IAM role creation)
resource "aws_iam_role" "eks_cluster_role" {
  arn:aws:iam::637423303341:user/eks_cluster
}
