# docker network の subnet を指定する際に使うべきでないネットワークアドレス

Docker コンテナ・ネットワークについては[こちら](http://docs.docker.jp/v17.06/engine/userguide/networking/dockernetworks.html)など、docker-compose.yml での docker network の指定例などは[こちら](https://github.com/KazKobara/dockerfile_fswiki_local/blob/main/docker-compose.yml)などを参照。

## 結論

* 以下の docker-compose, docker build などで自動割り当てされる subnet (および別途指定している subnet )は避ける。
* うっかりミスを避ける意味でもクラスA プライベートIPアドレス (10.0.0.0/8) を分割して subnet を指定しておくのが無難。
  * 例えば 10.0.0.0/24, 10.0.1.0/24, 10.0.2.0/24 など。

## docker-compose が bridge network に自動で割り当てる subnet

* 172.x.0.0/16 ここで x は18以上31以下、および、
* 192.168.y.0/20 ここで y は 0 以上 256 以下の16の倍数、つまり、0, 16, 32, 48, ..., 240, 256。
* version 1.25.0 で確認。

## docker build が bridge network に自動で割り当てる subnet

* 172.17.0.0/8
* version 19.03.13 で確認。

## 補足

* subnetを指定した後で、docker-composeが自動的に割り当る際には、指定された subnet を避けてくれるが、逆の場合（docker-composeが自動割り当てた subnet を指定した場合）は問題が生じる。
  * docker-composeが自動的に割り当る subnet はラウンドロビンで毎回変わるため、運悪く指定予定の subnet が自動的に割り当てられた場合に地雷を踏むことになる。
