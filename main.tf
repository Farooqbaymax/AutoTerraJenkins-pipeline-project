terraform {
  required_version = ">= 1.0.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.0.0"
    }
  }
}


# Define the provider to use (AWS)
provider "aws" {
  region = "ap-south-1"  # Specify the AWS region (e.g., ap-south-1 for Mumbai)
}

# Create a new VPC
resource "aws_vpc" "my_vpc" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "MyNewVPC"
  }
}

# Create a new Subnet in the VPC
resource "aws_subnet" "my_subnet" {
  vpc_id            = aws_vpc.my_vpc.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "ap-south-1a"

  tags = {
    Name = "MyNewSubnet"
  }
}

# Create a new Internet Gateway
resource "aws_internet_gateway" "my_internet_gateway" {
  vpc_id = aws_vpc.my_vpc.id

  tags = {
    Name = "MyNewInternetGateway"
  }
}

# Create a new Route Table for the VPC
resource "aws_route_table" "my_route_table" {
  vpc_id = aws_vpc.my_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.my_internet_gateway.id
  }

  tags = {
    Name = "MyNewRouteTable"
  }
}

# Associate the Route Table with the Subnet
resource "aws_route_table_association" "my_route_table_association" {
  subnet_id      = aws_subnet.my_subnet.id
  route_table_id = aws_route_table.my_route_table.id
}

# Create a Security Group that allows SSH and HTTP access
resource "aws_security_group" "my_security_group" {
  vpc_id = aws_vpc.my_vpc.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # Allows SSH access from anywhere
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # Allows HTTP access from anywhere
  }

#   ingress {
#     from_port   = 8080
#     to_port     = 80
#     protocol    = "tcp"
#     cidr_blocks = ["0.0.0.0/0"] 
#   }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"  # Allows all outbound traffic
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "MyNewSecurityGroup"
  }
}

# Create an S3 bucket
resource "aws_s3_bucket" "my_bucket" {
  bucket = "my-new-s3-bucket-${random_id.bucket_id.hex}"  # Unique bucket name

  tags = {
    Name = "MyNewS3Bucket"
  }
}

terraform {
  backend "s3" {
    bucket         = "my-new-s3-bucket-24b891cc"  # Your S3 bucket name
    key            = "terra-jenkins-pipeline\terraform.tfstate"  # The path to store the state file
    region         = "ap-south-1"                 # Your AWS region
    encrypt        = true                         # Enable state file encryption
    # dynamodb_table = "terraform-state-lock"       # (Optional) DynamoDB table for state locking
  }
}

#Add random ID for bucket uniqueness
resource "random_id" "bucket_id" {
  byte_length = 4
}

# Launch a new EC2 instance within the new VPC and Subnet
resource "aws_instance" "my_ec2_instance" {
  ami           = "ami-0522ab6e1ddcc7055"  # Replace with a valid AMI ID for your region
  instance_type = "t2.micro"

  # subnet_id         = aws_subnet.my_subnet.id
  # vpc_security_group_ids = [aws_security_group.my_security_group.name]

  tags = {
    Name = "MyNewEC2Instance"
  }
}

