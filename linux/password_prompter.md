# コマンド引数直書きパスワードへの対処方法 -- `pdftk`, `qpdf` を例として --

コマンドラインやCUI (Character User Interface)でコマンドを実行する際のパスワード入力方法には、以下のような方法がある。

1. パスワード入力プロンプトが表示されそこに入力する
2. コマンド引数に直書き

2.を実行する場合、コマンド実行履歴などにパスワードが残る場合があるため、後に端末に侵入されたり、端末が盗まれたりした場合のことを考慮すると、適切に処理しておいた方がよい。なお、コマンド実行時に既に端末が乗っ取られてしまっている場合には、別の追加の対策も必要となる。

## 対応策1： 履歴から削除

### Linux の場合

```shell
history
```

コマンドで左側に番号、右側に実行されたコマンドが表示されるため、削除したいコマンド履歴の番号を調べ、以下のコマンドで削除。

```shell
history -d <番号>
```

他の箇所にもコマンド実行履歴が残っている場合には、それら毎の対応が必要。

## 対応策2： コマンド引数直書き以外の方法が存在していないか調べる

### [pdftk](https://gitlab.com/pdftk-java/pdftk)コマンドの場合

引数のパスワードを記述する箇所に PROMPT と記述する。
(動作は `pdftk port to java 3.0.9`で確認)

```shell
pdftk input.pdf output encrypted.pdf user_pw PROMPT
```

すると、パスワードを入力するためのプロンプトが表示され、打ち込んだパスワードは表示される（表示させない方法は以下を参照）。

```console
Please enter the user password to use on the output PDF.
   It can be empty, or have a maximum of 32 characters:
<ここに password を打ち込む> 
```

- ちなみに、"PROMPT" というパスワードを指定したい場合には、表示されたパスワード入力プロンプトに PROMPT と打ち込む。

### パスワード入力プロンプトに打ち込んだパスワードを表示させない方法

- コマンドの前に `stty -echo;` 後ろに `; stty echo` を付ける  

```shell
stty -echo && command_with_password_prompt; stty echo
```

- ただし、この方法だとコマンドが中断された場合に、`stty echo`が実行されるコマンドラインに文字を打ち込んでも何も表示されなくなる。
- そうなった場合には Enter キーを押した後で `stty echo` と打って(も何も表示されないが)再び Enter キーを押す。
- 以下の対応策は`stty`を使わない。

## 対応策3： パスワード入力プロンプトに文字を打ち込む度に * (アスタリスク)を表示させる

### 前準備

1. password_prompter.sh を入手:

    ```console
    curl -O https://raw.githubusercontent.com/KazKobara/tips-jp/gh-pages/linux/password_prompter.sh
    ```

2. 中身を確認(意図しない挙動が含まれていないかなど)

    ```console
    cat ./password_prompter.sh
    ```

3. permission を以下のようにしておく。

    ```console
    chmod 400 ./password_prompter.sh
    ```

### `password_prompter.sh` の使い方

- `source ./password_prompter.sh` を実行すると、パスワード入力プロンプトが表示され、打ち込んだパスワードが `$pw` に格納される。
  - パスワードとして受け付ける文字は数英大文字小文字(a-zA-Z0-9)に制限してある。
  - 本制限を緩める場合でかつ、Web経由などの別システムから入力を受け付ける場合には、別途入力文字への sanitization を行う必要がある。
- `source ./password_prompter.sh "user_"` などのように引数に文字列を与えると、パスワードプロンプト"Enter password:"の"password:"の前にその文字列が追加される。上記例の場合は "Enter user_password:" となる。
  - 本引数として受け付ける文字は "a-zA-Z0-9_ "に制限してある。
- 複数種類のパスワード入力する必要がある場合には、1回目に入手した`$pw`を別変数に移動させ、2回目以降は `read_password` を実行する。
  - 例としては以下の[PDFファイルをユーザパスワードで暗号化し、オーナーパスワードもセットする場合](#PDFファイルをユーザパスワードで暗号化し、オーナーパスワードもセットする場合の例)を参照。

> 上記の `$pw` および以下の `$upw` 変数は、コマンドの最後でそれぞれ `unset pw upw` を実行することでも自動的に消去可能であるが、処理が途中で中断されると最後まで実行されず変数が残ってしまう。そのため、コマンド行は必ず `()` で囲んでから(つまりsubsystem上で)実行すること。

### PDFファイルを暗号化する場合の例

pdftkコマンドの場合:

```shell
(source ./password_prompter.sh && {echo; pdftk input.pdf output encrypted.pdf user_pw "$pw";})
```

- なお、少なくとも ```pdftk port to java 3.0.9``` では
  - AES では暗号化できないようで、RC4 で暗号化される。
    - AESで暗号化する場合の一つの例としては、以下の`qpdf`コマンドの場合を参照。
  - 鍵長のデフォルトは 128 bit。

[qpdf](https://sourceforge.net/projects/qpdf/)コマンドの場合:

```shell
(source ./password_prompter.sh && {echo; qpdf --encrypt "$pw" "" 128 --use-aes=y -- input.pdf encrypted.pdf;})
```

- `--use-aes=y` オプションにより AES で暗号化される。
- `128` を `256` に変えると鍵長を 256-bit にできるが、パスワードのエントロピーは通常 128ビットより小さいので、それ以上のパスワードを使わなければ `256` とする利点は得られない。

### PDFファイルをユーザパスワードで暗号化し、オーナーパスワードもセットする場合の例

- ただし、オーナーパスワードをセットして利用許可を設定してもそれらが尊重されるか否かは[PDFリーダ次第](https://www.antenna.co.jp/pdf/reference/SecurityEncryption.html#a06)。

qpdfコマンドの場合:

```shell
(source ./password_prompter.sh "user " && {upw="$pw"; read_password "owner ";} && qpdf --encrypt "$upw" "$pw" 128 --use-aes=y -- input.pdf encrypted.pdf)
```

pdftkコマンドの場合:

```shell
(source ./password_prompter.sh "user " && {upw="$pw"; read_password "owner ";} && pdftk input.pdf output encrypted.pdf user_pw "$upw" ower_pw "$pw")
```

### 暗号化されたPDFファイルを復号する場合の例

qpdfコマンドの場合:

```shell
(source ./password_prompter.sh && qpdf --password="$pw" --decrypt encrypted.pdf decrypted.pdf)
```

pdftkコマンドの場合:

```shell
(source ./password_prompter.sh && pdftk encrypted.pdf input_pw "$pw" output decrypted.pdf)
```

- `unknown.encryption.type.r` エラーが出る場合は[こちら](https://kazkobara.github.io/tips-jp/linux/pdftk_unknown_encryption_type_r.html)。

### おまけ

文字を打ち込む度に * (アスタリスク)を表示させなくても良い場合には、それぞれ以下のように置き換えてもよい。ただし、パスワードとして受け付ける文字は制限されないため、Web経由などの別システムから入力を受け付ける場合には、別途入力文字への sanitization を行う必要がある。

- '`source ./password_prompter.sh &&`' ---> '`read -sp "Enter password: " pw && echo;`'
- '`source ./password_prompter.sh "user " && {upw="$pw"; read_password "owner " ;}  && {`' ----> '`read -sp "Enter user password: " upw && echo; read -sp "Enter owner password: " pw && {echo;`'

---
[homeに戻る](https://kazkobara.github.io/)
