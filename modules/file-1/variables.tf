# ------------------------------
# Variables
# ------------------------------

# defaultは記述しないでもOK。記述がある場合は、変数に値を設定しない場合にdefault値が適用される
# ------------------------------
# vpcのcidr_brock
# ------------------------------
variable "my_vpc_cidr_block" {
  default = "10.0.0.0/16"
}

# ------------------------------
# タグ名でプロジェクト名を識別する因子を変数化
# ------------------------------
variable "name_base" {
  # "ydk-project"を設定
  default = "ydk-project"
}

# ------------------------------
# 1つ目ap-northeast-1aのPublicSubnetのcidr_brock
# ------------------------------
variable "my_pubsub_1a_cidr" {
  # "my_pubsub_1a_cidr"を設定
  default = "10.0.0.0/20"
}

# ------------------------------
# 1つ目のPublicSubnetのAZ
# ------------------------------
variable "my_pubsub_1a_az" {
  # "ap-northeast-1a"を設定
  default = "ap-northeast-1a"
}

# ------------------------------
# 2つ目ap-northeast-1cのPublicSubnetのcidr_brock
# ------------------------------
variable "my_pubsub_1c_cidr" {
  # "my_pubsub_1a_cidr"を設定
  default = "10.0.16.0/20"
}

# ------------------------------
# 2つ目のPublicSubnetのAZ
# ------------------------------
variable "my_pubsub_1c_az" {
  # "ap-northeast-1c"を設定  
  default = "ap-northeast-1c"
}

# ------------------------------
# 1つ目ap-northeast-1aのPrivateSubnetのcidr_brock
# ------------------------------
variable "my_prisub_1a_cidr" {
  # "my_prisub_1a_cidr"を設定
  default = "10.0.128.0/20"
}

# ------------------------------
# 1つ目のPrivateSubnetのAZ
# ------------------------------
variable "my_prisub_1a_az" {
  # "ap-northeast-1a"を設定
  default = "ap-northeast-1a"
}

# ------------------------------
# 2つ目ap-northeast-1cのPrivateSubnetのcidr_brock
# ------------------------------
variable "my_prisub_1c_cidr" {
  # "my_prisub_1c_cidr"を設定
  default = "10.0.144.0/20"
}


# ------------------------------
# 2つ目のPrivateSubnetのAZ
# ------------------------------
variable "my_prisub_1c_az" {
  # "ap-northeast-1c"を設定
  default = "ap-northeast-1c"
}

# ------------------------------
# SGのEgressグループのポート番号
# ------------------------------
variable "SG_egress_port0" {
  # すべてのトラフィックなので0を設定
  default = "0"
}

# ------------------------------
# SGのEgressグループのcidr
# ------------------------------
variable "SG_egress_cidr" {
  # すべてのトラフィックなので0.0.0.0/0を設定
  default = "0.0.0.0/0"
}

# ------------------------------
# EC2にアタッチするSG名
# ------------------------------
variable "SG_ec2" {
  # "SG_1_name"を設定
  default = "SG_1_name"
}

# ------------------------------
# EC2にアタッチするSGのポートSSH
# ------------------------------
variable "SG_ec2_port22" {
  # "port22"を設定
  default = "22"
}

# ------------------------------
# 外部APIを使って自分のIPアドレスを取得
# ------------------------------

data "http" "my_ip" {
  url = "https://api.ipify.org?format=json"
}

# ------------------------------
# EC2にアタッチするSGのポートSSHのcidrip
# ------------------------------

#local変数を使用してSGのポートSSHのcidripをマイIPを設定
locals {
  my_ip = "${jsondecode(data.http.my_ip.response_body)["ip"]}/32"
}

# ------------------------------
# EC2にアタッチするSGのポートHTTP
# ------------------------------
variable "SG_ec2_port80" {
  # "port80"を設定
  default = "80"
}

# ------------------------------
# EC2にアタッチするSGのポートHTTPのcidrip
# ------------------------------
variable "SG_ec2_80_cidr" {
  # "0.0.0.0/0"
  default = "0.0.0.0/0"
}

# ------------------------------
# RDSにアタッチするSG名
# ------------------------------
variable "SG_rds" {
  # "SG_2_name"を設定
  default = "SG_2_name"
}

# ------------------------------
# RDSにアタッチするSGのポートMYSQL/Aurora
# ------------------------------
variable "SG_rds_port3306" {
  # "port3306"を設定
  default = "3306"
}

# ------------------------------
# ALBにアタッチするSG名
# ------------------------------
variable "SG_alb" {
  # "SG_3_name"を設定
  default = "SG_3_name"
}

# ------------------------------
# ALBにアタッチするSGのポートHTTP
# ------------------------------
variable "SG_alb_port80" {
  # "port80"を設定
  default = "80"
}

# ------------------------------
# ALBにアタッチするSGのポートHTTPのcidrip
# ------------------------------
variable "SG_alb_80_cidr" {
  # "0.0.0.0/0"
  default = "0.0.0.0/0"
}

# ------------------------------
# RDS_database_name
# ------------------------------
variable "database_name" {
  # rds名を設定
  default = "rds_instance_name"
}

# ------------------------------
# RDS_database_strage_size
# ------------------------------
variable "storage_size" {
  # ストレージ割り当て20を設定
  default = "20"
}

# ------------------------------
# RDS_storage_type
# ------------------------------
variable "storage_type" {
  # ストレージタイプgp2を設定
  default = "gp2"
}

# ------------------------------
# RDS_database_engine
# ------------------------------
variable "database_engine" {
  # エンジンのタイプmysqlを設定
  default = "mysql"
}

# ------------------------------
# RDS_database_engine_version
# ------------------------------
variable "database_engine_version" {
  # エンジンバージョンを8.0を設定
  default = "8.0"
  validation {
    condition     = contains(["8.0", "8.1", "8.2"], var.database_engine_version)
    error_message = "The allowed values for engine_version are 8.0, 8.1, or 8.2"
  }
}

# ------------------------------
# RDS_database_instance_class
# ------------------------------
variable "database_instance_class" {
  # を設定
  default = "db.t3.micro"
}

# ------------------------------
# RDS_database_instance_identifier 
# ------------------------------
variable "database_instance_identifier" {
  # を設定
  default = "database1"
}

# ------------------------------
# RDS_database_master_user 
# ------------------------------
variable "database_master_user" {
  # マスタユーザ名を設定
  default = "admin"
}

# ------------------------------
# RDS_database_master_user_password        
# ------------------------------
variable "database_user_password" {
  # マスタユーザパスワードを設定
  default = "mypassword"
}

# ------------------------------
# RDS_database_availability_zone
# ------------------------------
variable "availability_zone" {
  # ap-northeast-1aを設定
  default = "ap-northeast-1a"
}

# ------------------------------
# KeyPairName
# ------------------------------
variable "keypair_name" {
  # SSH接続に使用するキーペア名を設定
  default = "keypair_name"
}

# ------------------------------
# EC2InstanceType
# ------------------------------
variable "ec2_instance_type" {
  # インスタンスタイプを設定
  default = "t3.micro"
  validation {
    condition     = contains(["t3.micro", "t2.micro", "t2.small"], var.ec2_instance_type)
    error_message = "The allowed values for engine_version are t3.micro, t2.micro, or t2.small"
  }
}

# ------------------------------
# EC2InstanceName
# ------------------------------
variable "ec2_instance_name" {
  # instance名を設定
  default = "ec2_instance_name"
}

# ------------------------------
# EC2InstanceVolumeSize
# ------------------------------
variable "ec2_instance_volume_size" {
  # デフォルトの8を設定
  default = "8"
}


# ------------------------------
# EC2InstanceVolumeType
# ------------------------------
variable "ec2_instance_volume_type" {
  # gp3を設定
  default = "gp3"
}


# ------------------------------
# ターゲットグループの名前
# ------------------------------
variable "target_group_name" {
  # ターゲット名を設定
  default = "alb-target-group"
}

# ------------------------------
# ターゲットタイプの設定
# ------------------------------
variable "target_type" {
  # instanceまたはipまたはlambdaを選択。今回はinstance
  default = "instance"
}

# ------------------------------
# protocolのバージョン
# ------------------------------
variable "protocol_version" {
  #クライアントのサポートがあれば、HTTP2も可 
  default = "HTTP1"
}

# ------------------------------
# ターゲットグループのport
# ------------------------------
variable "target_group_port" {
  #defultでHTTP80番ポート
  default = "80"
}

# ------------------------------
# ターゲットグループのprotcol
# ------------------------------
variable "target_group_protcol" {
  #defultでHTTP80番ポート
  default = "HTTP"
}

# ------------------------------
# ヘルスチェックの設定
# ------------------------------

# ------------------------------
# ヘルスチェックの間隔
# ------------------------------
variable "health_check_interval" {
  #defultでは30秒
  default = "30"
}

# ------------------------------
# ヘルスチェックのPATH
# ------------------------------
variable "health_check_path" {
  #defultでは"/"
  default = "/"
}

# ------------------------------
# ヘルスチェックのprotcol
# ------------------------------
variable "health_check_protcol" {
  #defultでHTTP80番ポート
  default = "HTTP"
}

# ------------------------------
# ヘルスチェックのtimeout
# ------------------------------
variable "health_check_timeout" {
  #defultで"5"秒
  default = "5"
}

# ------------------------------
# 正常と判断する際の閾値
# ------------------------------
variable "healthy_threshold_count" {
  #defultで"5"秒
  default = "5"
}

# ------------------------------
# 異常と判断する際の閾値
# ------------------------------
variable "unhealthy_threshold_count" {
  #defultで"5"秒
  default = "2"
}

# ------------------------------
# ALBの名前
# ------------------------------
variable "alb_name" {
  # ALB名を設定
  default = "alb-name"
}

# ------------------------------
# ALBのタイプ
# ------------------------------
variable "load_balancer_type" {
  # applicationまたはnetworkを設定
  default = "application"
}

# ------------------------------
# ALBのIPアドレスタイプ
# ------------------------------
variable "ip_address_type" {
  # ipv4またはipv6またはdualstackを設定    
  default = "ipv4"
}

# ------------------------------
# リスナーの設定
# ------------------------------

# ------------------------------
# リスナーのポート設定
# ------------------------------
variable "listener_port" {
  # デフォルトではHTTP80番ポートを設定
  default = "80"
}

# ------------------------------
# リスナーのプロトコル設定
# ------------------------------
variable "listener_protocol" {
  # デフォルトではHTTP80番ポートを設定
  default = "HTTP"
}

# ------------------------------
# S3の名前
# ------------------------------
variable "s3_name" {
  default = "s3-bucket-sample"
}
