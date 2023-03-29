provider "aws" {
  region = "eu-west-1"
}

locals {
  vpc_cidr_block = "10.0.0.0/16"
}

resource "aws_vpc" "mysql_vpc" {
  cidr_block = local.vpc_cidr_block
  tags = {
    Name = "mysql-vpc"
  }
}

resource "aws_subnet" "mysql_subnet_1" {
  cidr_block = "10.0.1.0/24"
  vpc_id     = aws_vpc.mysql_vpc.id
  tags = {
    Name = "mysql-subnet-1"
  }
}

resource "aws_subnet" "mysql_subnet_2" {
  cidr_block = "10.0.2.0/24"
  vpc_id     = aws_vpc.mysql_vpc.id
  tags = {
    Name = "mysql-subnet-2"
  }
}

resource "aws_security_group" "mysql_sg" {
  name        = "mysql-sg"
  description = "MySQL database security group"
  vpc_id      = aws_vpc.mysql_vpc.id
}

resource "aws_db_subnet_group" "mysql_subnet_group" {
  name       = "mysql-subnet-group"
  subnet_ids = [aws_subnet.mysql_subnet_1.id, aws_subnet.mysql_subnet_2.id]

  tags = {
    Name = "mysql-db-subnet-group"
  }
}

resource "aws_db_instance" "mysql_instance" {
  identifier           = "mysql-instance"
  allocated_storage    = 20
  engine               = "mysql"
  engine_version       = "8.0"
  instance_class       = "db.t3.micro"
  name                 = "mymysqldb"
  username             = "mysqluser"
  password             = "supersecretpassword"
  db_subnet_group_name = aws_db_subnet_group.mysql_subnet_group.name

  vpc_security_group_ids = [aws_security_group.mysql_sg.id]

  backup_retention_period = 7
  backup_window           = "07:00-09:00"
  maintenance_window      = "Mon:09:00-Mon:11:00"

  tags = {
    Name = "mysql-instance"
  }
}
