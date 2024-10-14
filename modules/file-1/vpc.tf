# ----------
# リソース定義
# ----------
# VPCを作る
resource "aws_vpc" "main_vpc" {
  cidr_block           = var.my_vpc_cidr_block
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "${var.name_base}-vpc"
  }
}

# ----------
# リソース定義
# ----------
# IGWを作成&アタッチ
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main_vpc.id

  tags = {
    Name = "${var.name_base}-igw"
  }
}

# ----------
# リソース定義
# ----------
# PublicSubnet&PrivateSubnetを作成

# ap-northeast-1aにPublicSubnetを作成

resource "aws_subnet" "public_1a" {
  vpc_id = aws_vpc.main_vpc.id

  availability_zone = var.my_pubsub_1a_az
  cidr_block        = var.my_pubsub_1a_cidr

  tags = {
    Name = "${var.name_base}-pubsub-1a"
  }
}

# ap-northeast-1cにPublicSubnetを作成

resource "aws_subnet" "public_1c" {
  vpc_id = aws_vpc.main_vpc.id

  availability_zone = var.my_pubsub_1c_az
  cidr_block        = var.my_pubsub_1c_cidr

  tags = {
    Name = "${var.name_base}-pubsub-1c"
  }
}

# ap-northeast-1aにPrivateSubnetを作成

resource "aws_subnet" "private_1a" {
  vpc_id = aws_vpc.main_vpc.id

  availability_zone = var.my_prisub_1a_az
  cidr_block        = var.my_prisub_1a_cidr

  tags = {
    Name = "${var.name_base}-private-1a"
  }
}

# ap-northeast-1cにPrivateSubnetを作成

resource "aws_subnet" "private_1c" {
  vpc_id = aws_vpc.main_vpc.id

  availability_zone = var.my_prisub_1c_az
  cidr_block        = var.my_prisub_1c_cidr

  tags = {
    Name = "${var.name_base}-private-1c"
  }
}

#ルートテーブル作成
resource "aws_route_table" "tf-rtb-public" {
  vpc_id = aws_vpc.main_vpc.id #VPCとの紐付け

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id #IGWとの紐付け
  }

  tags = {
    Name = "${var.name_base}-rtb-public"
  }
}

#パブリックサブネットとの紐付け
resource "aws_route_table_association" "rtb-public-1a" {
  subnet_id      = aws_subnet.public_1a.id
  route_table_id = aws_route_table.tf-rtb-public.id
}

resource "aws_route_table_association" "rtb-public-1c" {
  subnet_id      = aws_subnet.public_1c.id
  route_table_id = aws_route_table.tf-rtb-public.id
}

#ルートテーブル作成
resource "aws_route_table" "tf-rtb-private-1a" {
  vpc_id = aws_vpc.main_vpc.id
  tags = {
    Name = "${var.name_base}-private-1a"
  }
}

#ルートテーブル作成
resource "aws_route_table" "tf-rtb-private-1c" {
  vpc_id = aws_vpc.main_vpc.id
  tags = {
    Name = "${var.name_base}-private-1c"
  }
}

#プライベートサブネットとの紐付け
resource "aws_route_table_association" "rtb-private-1a" {
  subnet_id      = aws_subnet.private_1a.id
  route_table_id = aws_route_table.tf-rtb-private-1a.id
}

resource "aws_route_table_association" "rtb-private-1c" {
  subnet_id      = aws_subnet.private_1c.id
  route_table_id = aws_route_table.tf-rtb-private-1c.id
}
