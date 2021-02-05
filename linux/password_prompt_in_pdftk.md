# pdftk でパスワードをコマンドラインに書かないようにする方法

## 必要な背景知識

- [pdftk](https://gitlab.com/pdftk-java/pdftk) (Handy Tool for Manipulating PDF Documents)
- shell script

## pdftk コマンドの例と問題点

Linux などの shell コマンドラインで、例えば、以下のようなコマンドを打ち込むと、input_pdf_file.pdf を "password" というパスワードで暗号化したファイルを password_encrypted_pdf_file.pdf に保存できるが、履歴に "password" という文字列が残るのが問題。

```shell
pdftk input_pdf_file.pdf output password_encrypted_pdf_file.pdf user_pw "password"
```

## 解決策

### その1： 履歴から削除

```shell
history
```

コマンドで左側に番号、右側に実行されたコマンドが表示されるため、削除したいコマンド履歴の番号を調べ、以下のコマンドで削除。

```shell
history -d <番号>
```

### その2： 履歴に残さない

動作は以下の version で確認してます。

```console
$ pdftk --version
pdftk port to java 3.0.9
```

pdftkコマンドのパスワードを記述する箇所に PROMPT と記述してコマンドを実行する。

例）

```shell
pdftk input_pdf_file.pdf output password_encrypted_pdf_file.pdf user_pw PROMPT
```

すると、パスワードを入力するためのプロンプトが表示されるため、そこにパスワードを打ち込む。

```console
Please enter the user password to use on the output PDF.
   It can be empty, or have a maximum of 32 characters:
<ここに password を打ち込む> 
```

ちなみに、(ニーズは無いと思うが) PROMPT というパスワードを指定したい場合には、上記のプロンプト箇所に PROMPT と打ち込む。

### その3： 履歴に残さず、かつ、プロンプトにパスワードを表示させない

上記の「その2： 履歴に残さない」方法は、打ち込むパスワードはそのまま表示されるため、それを止めたい場合は、以下のいずれかを実行。
password が正しくセットされているかは、生成された pdf file を開いて確認。

#### pdftk コマンドの前に `stty -echo;` を付け、後ろに `; stty echo` を付ける。

例）

```shell
stty -echo; pdftk input_pdf_file.pdf output password_encrypted_pdf_file.pdf user_pw PROMPT; stty echo
```

万が一、コマンドラインに文字を打ち込んでも何も表示されなくなった場合には、Enter キーを押した後で `stty echo` と打って(も何も表示されないが)再び Enter キーを押す。

#### pdftk コマンドのパスワード欄を "$pw" とし、pdftk コマンドの前に `read -s -p "Enter password: " pw; echo;` を付け、後ろに `; unset pw` を付ける。

例）

```shell
read -s -p "Enter password: " pw; echo; pdftk input_pdf_file.pdf output password_encrypted_pdf_file.pdf user_pw "$pw"; unset pw
```

を実行すると、パスワードを入力するためのプロンプトが表示されるため、そこにパスワードを打ち込む。

```console
Enter password: <ここに password を打ち込む> 
```

### その4： 履歴に残さず、かつ、プロンプトにパスワードの文字を打ち込む度に * (アスタリスク)を表示させる

以下のようなスクリプトを `read_password.sh` などの名前で保存しておき、

```shell
#!/bin/sh

# Read password and store it to given variable.
# @param $1 variable to store the read password
read_password () {
    local local_pw=""
    local local_char=""
    echo -n "Enter password: "
    while read -sn 1 local_char
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
```

以下を実行。

```shell
source ./read_password.sh; read_password pw; pdftk input_pdf_file.pdf output password_encrypted_pdf_file.pdf user_pw "$pw"; unset pw
```

（もしくは、pdftk を更新するか、更新されるまで待つ...）

password が正しくセットされているかは、生成された pdf file を開いて確認。
