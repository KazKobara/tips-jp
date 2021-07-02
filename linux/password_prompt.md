# コマンド引数直書きパスワードへの対処方法 -- `pdftk`, `qpdf` を例として --

コマンドラインやCUI (Character User Interface)でコマンドを実行する際のパスワード入力方法には、以下のような方法がある。

1. パスワード入力プロンプトが表示されそこに入力する
2. コマンド引数に直書き

コマンドとその version によっては、2.しか実装されていない場合がある。

2.の場合、コマンド実行履歴などにパスワードが残る場合があるため、後に端末に侵入されたり、端末が盗まれたりした場合のことを考慮すると、適切に処理しておいた方がよい。

なお、コマンド実行時に既に端末が乗っ取られてしまっている場合には、別の対策が必要となる。

## 対応策1： 履歴から削除

### Linux の場合

```shell
history
```

コマンドで左側に番号、右側に実行されたコマンドが表示されるため、削除したいコマンド履歴の番号を調べ、以下のコマンドで削除。

```shell
history -d <番号>
```

他にもコマンド実行履歴が取られている場合には、それら毎の対応が必要。

## 対応策2： パスワード入力プロンプトを表示させるオプションが存在していないか調べる

### [pdftk](https://gitlab.com/pdftk-java/pdftk)の場合(`pdftk port to java 3.0.9`で確認)

コマンドラインのパスワードを記述する箇所に PROMPT と記述する。

例）

```shell
pdftk input.pdf user_pw PROMPT output encrypted.pdf
```

すると、パスワードを入力するためのプロンプトが表示され、打ち込んだパスワードは表示される（表示させない方法は以下を参照）。

```console
Please enter the user password to use on the output PDF.
   It can be empty, or have a maximum of 32 characters:
<ここに password を打ち込む> 
```

ちなみに、

- "PROMPT" というパスワードを指定したい場合には、表示されたパスワード入力プロンプトに PROMPT と打ち込む。

## パスワード入力プロンプトに打ち込んだパスワードを表示させない方法

### その1: `stty`コマンドの利用

コマンドの前に `stty -echo;` を付け、後ろに `; stty echo` を付ける  

例）

```shell
(stty -echo; pdftk input.pdf user_pw PROMPT output encrypted.pdf; stty echo)
```

コマンドラインに文字を打ち込んでも何も表示されなくなった場合には、Enter キーを押した後で `stty echo` と打って(も何も表示されないが)再び Enter キーを押す。

### その2: `read -sp` コマンドの利用

pdf ファイルを暗号化する場合の例:

> 以下の $pw 変数は、コマンドの最後で `; unset pw` を実行することでも自動的に消去可能であるが、処理が途中で中断されると最後まで実行されず変数が残ってしまうため、コマンドは必ず `()` で囲んでから実行すること。

pdftk コマンドの場合:

```shell
(read -sp "Enter password: " pw && echo; pdftk input.pdf user_pw "$pw" output encrypted.pdf)
```

- なお、少なくとも ```pdftk port to java 3.0.9``` では
  - AES では暗号化できないようで、RC4 で暗号化される。
  - 鍵長のデフォルトは 128 bit。

[qpdf](https://sourceforge.net/projects/qpdf/) コマンドの場合:

```shell
(read -sp "Enter password: " pw && echo; qpdf --encrypt "$pw" "" 128 --use-aes=y -- input.pdf encrypted.pdf)
```

- `128 --use-aes=y` オプションで 128-bit AES で暗号化される。
- `128` を `256` に変えると鍵長を 256-bit にできるが、パスワードのエントロピーは通常 128ビットより小さいので、それ以上のパスワードを使わなければ `256` とする利点は得られない。

## 対応策3： パスワード入力プロンプトに文字を打ち込む度に * (アスタリスク)を表示させる

以下のようなスクリプトを `read_password.sh` などの名前で保存し

```shell
#!/bin/bash

# Read password and store it to given variable.
# @param $1 variable to store the read password
read_password () {
    local local_pw=""
    local local_char=""
    echo -n "Enter password: "
    while read -rsn 1 local_char
    do
        if [ "$local_char" == "" ]; then
            break
        fi
        echo -n "*"
        local_pw="$local_pw$local_char"
    done
    echo
    local local_ret=$1
    eval "$local_ret=$local_pw"
}

read_password pw;
```

permission を以下のようにしておく。

```console
chmod 400 ./read_password.sh
```

暗号化された pdf ファイルを復号する場合の例:

> 以下の $pw 変数は、コマンドの最後で `; unset pw` を実行することでも自動的に消去可能であるが、処理が途中で中断されると最後まで実行されず変数が残ってしまうため、コマンドは必ず `()` で囲んでから実行すること。

pdftkの場合:

```shell
(source ./read_password.sh && pdftk encrypted.pdf
input_pw "$pw" output decrypted.pdf)
```

- `unknown.encryption.type.r` エラーが出る場合は[こちら](https://kazkobara.github.io/tips-jp/linux/pdftk_unknown_encryption_type_r.html)。

qpdfの場合:

```shell
(source ./read_password.sh && qpdf --password="$pw" --decrypt encrypted.pdf decrypted.pdf)
```

---
[homeに戻る](https://kazkobara.github.io/)
