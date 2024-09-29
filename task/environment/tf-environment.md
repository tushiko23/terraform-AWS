# terraform環境構築
1. [AWSCLIをインストールし、terraformの操作をできるようにする](https://github.com/tushiko23/CLI-AWS/blob/modify/cLI-command/cli-install.md)
2. `tfenv`を使用して、Terraformをインストール

## LocalPCにterraformをインストール

インストール方法さまざまありますが、今回は、バージョン管理容易なtfenvを用いてインストールします。

[下記サイトを参考にインストール](https://www.ios-net.co.jp/blog/20230322-861/)

```
#tfenvをgitからクローン

git clone --depth=1 https://github.com/tfutils/tfenv.git ~/.tfenv

#PATHを通す

echo 'export PATH=$PATH:$HOME/.tfenv/bin' >> ~/.bashrc
source ~/.bashrc
```

tfenvでTerraformのインストールするにはunzipをインストール。

unzipとは
ZIP形式で圧縮されたファイルやフォルダを展開し、圧縮されていない状態に戻すことである。もしくは、そのために用いられるソフトウェアのこと、UNIXにおいてその作業を行うために用いられるコマンドを指すこともある。今回は両方の意味で使われる。

今回は terraform zip ファイルを解凍するので、インストール。

```
sudo apt-get update
sudo apt-get install zip
```

terraformをインストールする
```

tfenv install 0.7.0      # version 0.7.0 をインストール
tfenv install latest     # 最新バージョンをインストール

# 正規表現`^0.8`に合致する最新バージョンをインストールする

tfenv install latest:^0.8 

# Terraformのrequired_versionから、最新バージョンをインストールする

tfenv install latest-allowed   

 # Terraformのrequired_versionから、最低バージョンをインストールする

tfenv install min-required    
```

```
#バージョンを指定して、アンインストール
tfenv uninstall 0.7.0

#最新版をアンインストール
tfenv uninstall latest

# ^0.8`に合致する最新バージョンをインストール
tfenv uninstall latest:^0.8
```

```
#使用するバージョンを指定
tfenv use min-required
tfenv use 0.7.0
tfenv use latest
tfenv use latest:^0.8
```

今回は、最新版のバージョン v1.9.5 (2024年9月地点)を使用します

```
terraform -v
Terraform v1.9.5
on linux_amd64
```

### プロジェクトに応じて実施してください

インストールしたバージョンを確認する
```
tfenv list
```

インストール可能なバージョンを確認
```
tfenv list-remote
```

プロジェクトルートに.terraform-versionというファイルを配置して、そこに使用するTerraformのバージョンを記述することで、そのバージョンを優先して利用することが出来る。

```
$ echo 1.3.5 > .terraform-version
$ tfenv install     # ver 1.3.5 がインストールされる
$ tfenv use         # ver 1.3.5 を使用する

$ echo 1.2.9 > .terraform-version
$ tfenv install     # ver 1.2.9 がインストールされる
$ tfenv use         # ver 1.2.9 を使用する
```