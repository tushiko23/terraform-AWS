terraformstateの管理

terraformstateファイルとは
・applyした際の状態を記録したJSON。無くなるとどれがTerraformで構築したか判断不可能になってしまう
・通常はapplyを実行したディレクトリに生成

管理が不十分だと....。
* tfは最新なのにtfstateが古い
* ウイルス対策ソフトで駆除されて、保管期間を過ぎた後に発覚する
* コードと実環境が合わなくなるリスク

そこで、terraformstateファイルを安全に管理するためにBackend機能を使う

* 公式ドキュメント：https://www.terraform.io/docs/backends/types/s3.html
* tfstateをリモートストレージで管理する機能
* githubでの管理もできなくはないが、pull,pushを忘れるので自動化が一番有効。

2つの方法がある
1.AWSではS3バケットに格納するのがスタンダード
2.DynamoDBを使って、排他ロック（先に操作した人が終わるまでapplyなどをブロックする）
をかけるという方法。今回は割愛。
https://www.terraform.io/docs/backends/types/s3.html#dynamodb-state-locking

1の方法を使う

*S3バケットを作成
*今回は"tf-handson-tushiko"で作成
```
aws s3 mb s3://tf-handson-tushiko
```

バージョニングを有効にする
[公式ドキュメントより参照](https://docs.aws.amazon.com/ja_jp/AmazonS3/latest/userguide/manage-versioning-examples.html)
```
aws s3api put-bucket-versioning --bucket "バケット名" --versioning-configuration Status=Enabled	
```


