# ------------------------------
# vpcのcidr_block
# ------------------------------
my_vpc_cidr_block = "172.16.0.0/16"

# ------------------------------
# プロジェクト名を識別するタグ名
# ------------------------------
name_base = "ydk-tushiko-tf"

# ------------------------------
# 各Subnetのcidr_block
# ------------------------------

#1つ目ap-northeast-1aのPublicSubnetのcidr_block
my_pubsub_1a_cidr = "172.16.0.0/20"

#2つ目ap-northeast-1cのPublicSubnetのcidr_block
my_pubsub_1c_cidr = "172.16.16.0/20"

#1つ目ap-northeast-1aのPrivateSubnetのcidr_block
my_prisub_1a_cidr = "172.16.128.0/20"

#2つ目ap-northeast-1cのPrivateSubnetのcidr_block
my_prisub_1c_cidr = "172.16.144.0/20"


# ------------------------------
# 各SubnetのAZ
# ------------------------------

#1つ目のPublicSubnetのAZ
my_pubsub_1a_az = "ap-northeast-1a"

#2つ目のPublicSubnetのAZ
my_pubsub_1c_az = "ap-northeast-1c"

#1つ目のPrivateSubnetのAZ
my_prisub_1a_az = "ap-northeast-1a"

#1つ目のPrivateSubnetのAZ
my_prisub_1c_az = "ap-northeast-1c"

# ------------------------------
# SGのEgressグループ
# ------------------------------

#SGのアウトバウンドのポート番号
SG_egress_port0 = "0"

#アウトバウンドのcidr
SG_egress_cidr = "0.0.0.0/0"

# ------------------------------
# EC2にアタッチするSG
# ------------------------------

#SG名
SG_ec2 = "ydk-ec2-sg"

#ポートSSHの番号
SG_ec2_port22 = "22"

#ポートHTTPの番号
SG_ec2_port80 = "80"

#80番ポートのcidr
SG_ec2_80_cidr = "0.0.0.0/0"

# ------------------------------
# RDSにアタッチするSG
# ------------------------------

#SG名
SG_rds = "ydk-rds-sg"

#ポートMYSQL/Auroraの番号
SG_rds_port3306 = "3306"

# ------------------------------
# ALBにアタッチするSG
# ------------------------------

#SG名
SG_alb = "ydk-alb-sg"

#ポートHTTPの番号
SG_alb_port80 = "80"

#80番ポートのcidr
SG_alb_80_cidr = "0.0.0.0/0"

# ------------------------------
# RDS_database_name
# ------------------------------

# rds名を設定
database_name = "rds_instance_name"

# ------------------------------
# RDS_database_strage_size
# ------------------------------

# ストレージ割り当て20を設定
storage_size = "20"

# ------------------------------
# RDS_storage_type
# ------------------------------

# ストレージタイプgp2を設定
storage_type = "gp2"

# ------------------------------
# RDS_database_engine
# ------------------------------

# エンジンのタイプmysqlを設定
database_engine = "mysql"

# ------------------------------
# RDS_database_engine_version
# ------------------------------

# エンジンバージョンを8.0を設定
database_engine_version = "8.0"

# ------------------------------
# RDS_database_instance_class
# ------------------------------

# db.t3.micro を設定
database_instance_class = "db.t3.micro"

# ------------------------------
# RDS_database_instance_identifier
# ------------------------------

# DB識別子を設定
database_instance_identifier = "ydk-tf-database"

# ------------------------------
# RDS_database_master_user
# ------------------------------

# マスタユーザ名を設定
database_master_user = "admin"


# ------------------------------
# RDS_database_master_user_password
# ------------------------------

# マスタユーザパスワードを設定
database_user_password = "Q3P3Nj9SACVN"

# ------------------------------
# RDS_database_availability_zone
# ------------------------------

# ap-northeast-1aを設定
availability_zone = "ap-northeast-1a"

# ------------------------------
# KeyPairName
# ------------------------------

# SSH接続に使用するキーペア名を設定
keypair_name = "ec2-connect-key"

# ------------------------------
# EC2InstanceType
# ------------------------------

# インスタンスタイプを設定
ec2_instance_type = "t3.micro"

# ------------------------------
# EC2InstanceName
# ------------------------------

# instance名を設定
ec2_instance_name = "ydk-tf-ec2"

# ------------------------------
# EC2InstanceVolumeSize
# ------------------------------

# サイズを設定
ec2_instance_volume_size = "20"

# ------------------------------
# EC2InstanceVolumeType
# ------------------------------

# gp3を設定
ec2_instance_volume_type = "gp3"

# ------------------------------
# ターゲットグループの名前
# ------------------------------

# ターゲット名を設定
target_group_name = "ydk-tf-target-group"

# ------------------------------
# ターゲットタイプの設定
# ------------------------------

# instanceまたはipまたはlambdaを選択。今回はinstance
target_type = "instance"

# ------------------------------
# protocolのバージョン
# ------------------------------

#クライアントのサポートがあれば、HTTP2も可
protocol_version = "HTTP1"

# ------------------------------
# ターゲットグループのport
# ------------------------------

#defultでHTTP80番ポート
target_group_port = "80"

# ------------------------------
# ターゲットグループのprotcol
# ------------------------------

#defultでHTTP80番ポート
target_group_protcol = "HTTP"

# ------------------------------
# ヘルスチェックの設定
# ------------------------------

# ------------------------------
# ヘルスチェックの間隔
# ------------------------------

#defultでは30秒
health_check_interval = "30"

# ------------------------------
# ヘルスチェックのPATH
# ------------------------------

#defultでは"/"
health_check_path = "/"

# ------------------------------
# ヘルスチェックのprotcol
# ------------------------------

#defultでHTTP80番ポート
health_check_protcol = "HTTP"

# ------------------------------
# ヘルスチェックのtimeout
# ------------------------------

#defultで"5"秒
health_check_timeout = "5"

# ------------------------------
# 正常と判断する際の閾値
# ------------------------------

#defultで"5"秒
healthy_threshold_count = "5"

# ------------------------------
# 異常と判断する際の閾値
# ------------------------------

#defultで"5"秒
unhealthy_threshold_count = "2"

# ------------------------------
# ALBの名前
# ------------------------------

# ALB名を設定
alb_name = "ydk-tf-alb"

# ------------------------------
# ALBのタイプ
# ------------------------------

# applicationまたはnetworkを設定
load_balancer_type = "application"

# ------------------------------
# ALBのIPアドレスタイプ
# ------------------------------

# ipv4またはipv6またはdualstackを設定
ip_address_type = "ipv4"

# ------------------------------
# リスナーの設定
# ------------------------------

# ------------------------------
# リスナーのポート設定
# ------------------------------

# デフォルトではHTTP80番ポートを設定
listener_port = "80"

# ------------------------------
# リスナーのプロトコル設定
# ------------------------------

# デフォルトではHTTP80番ポートを設定
listener_protocol = "HTTP"

# ------------------------------
# S3の名前
# ------------------------------

# 画像を保存するS3バケット名を指定
s3_name = "ydk-tf-bucket"
