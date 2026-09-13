terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
  required_version = ">= 1.0.0"
}

provider "aws" {
  region  = "us-east-1"
  profile = "myprofile"
}

#importing existing resources into Terraform state

#vpc
resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "my-vpc-01"
  }
}

import {
  id = "vpc-01113a14ae167d089"
  to = aws_vpc.main
}

#subnets

resource "aws_subnet" "subnet1" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "us-east-1a"
  tags = {
    Name = "subnet-01"
  }
}

import {
  id = "subnet-03a0f68dffa662ba8"
  to = aws_subnet.subnet1
}

resource "aws_subnet" "subnet2" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "us-east-1a"
  tags = {
    Name = "subnet-02"
  }
}

import {
  id = "subnet-07d2b7e9d016d1464"
  to = aws_subnet.subnet2
}

#internet gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "my-internet-gateway"
  }
}

import {
  id = "igw-070337325c1eee7a0"
  to = aws_internet_gateway.igw
}

resource "aws_eip" "eip" {
  domain = "vpc"
}

import {
  id = "eipalloc-00e1e23efabf09cf8"
  to = aws_eip.eip
}

#nat gateway
resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.eip.id
  subnet_id     = aws_subnet.subnet1.id
  tags = {
    Name = "real-nat"
  }
}

import {
  id = "nat-0cc40b96b75440986"
  to = aws_nat_gateway.nat
}

#route table

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "my-route-table"
  }
}

import {
  id = "rtb-0d4360bf58687b48a"
  to = aws_route_table.public
}

resource "aws_route" "public_internet" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw.id
}

import {
  id = "rtb-0d4360bf58687b48a_0.0.0.0/0"
  to = aws_route.public_internet
}

resource "aws_route_table_association" "subnet1_association" {
  subnet_id      = aws_subnet.subnet1.id
  route_table_id = aws_route_table.public.id
}

import {
  id = "subnet-03a0f68dffa662ba8/rtb-0d4360bf58687b48a"
  to = aws_route_table_association.subnet1_association
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "my-private-route"
  }
}

import {
  id = "rtb-017fb28da2e3c41d7"
  to = aws_route_table.private
}

resource "aws_route" "private_nat" {
  route_table_id         = aws_route_table.private.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_nat_gateway.nat.id
}

import {
  id = "rtb-017fb28da2e3c41d7_0.0.0.0/0"
  to = aws_route.private_nat
}

resource "aws_route_table_association" "subnet2_association" {
  subnet_id      = aws_subnet.subnet2.id
  route_table_id = aws_route_table.private.id
}

import {
  id = "subnet-07d2b7e9d016d1464/rtb-017fb28da2e3c41d7"
  to = aws_route_table_association.subnet2_association
}