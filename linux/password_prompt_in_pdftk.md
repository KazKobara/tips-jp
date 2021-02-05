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

上記の「その2： 履歴に残さない」方法は、打ち込むパスワードはそのまま表示されるため、それを止めたい場合は、以下を実行。

pdftk コマンドのパスワード欄を "$pw" とし、pdftk コマンドの前に

```shell
read -s -p "Enter password: " pw; echo; 
```

を付ける。

例）

```console
$ read -s -p "Enter password: " pw; echo; pdftk input_pdf_file.pdf output password_encrypted_pdf_file.pdf user_pw "$pw"
Enter password: <ここに password を打ち込む> 
```

password が正しくセットされているかは、生成された pdf file を開いて確認。
