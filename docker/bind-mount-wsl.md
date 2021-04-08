# docker run の "--mount", "--volume", "-v" のホストパスを WSL 上で指定する際の注意点

## 必要な背景知識

* Windows Subsystem for Linux (WSL, WSL2)
* Docker for Windows
* (linux native) Docker on WSL2
* [Docker bind mounts](https://docs.docker.com/storage/bind-mounts/#choosing-the--v-or---mount-flag)

## 内容

Docker bind mounts の source フォルダやファイルを WSL 上で指定する際には、Docker の種類(Docker for Windows なのか、WSL2上にインストールした linux native Docker なのか)、docker-compose で指定するのか、.env file で指定するのかなど、状況により適切な指定方法が異なるため、その整理を行っているページです（適宜更新中）。

## Windows版とLinux版の違い

||Docker for windows|Linux Docker|
|----|----|----|
|POSIX symbolic link|NG|OK|
|Windows C drive の指定方法| c:/| /mnt/c |
|"$(pwd)"|NG ('/mnt/...'に展開されるため)|OK|

## docker-compose.yml とそれ以外の違い

||docker-compose.yml の volumes:|左記以外|
|----|----|----|
|相対パスの利用|OK|NG *1|
|.env file 内での変数の入れ子|NG|OK|

*1 相対パスの前に"$(pwd)"を付ける。ただし、docker-compose.yml の volumes: の変数を .env file 内で "$(pwd)" を用いて指定すると入れ子の変数が展開されずエラーになる。

## 動作確認バージョン

* Docker Version 19.03
* docker-compose version 1.25.4

---
[homeに戻る](https://kazkobara.github.io/)
