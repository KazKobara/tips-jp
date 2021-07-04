# pdftk で `"unknown.encryption.type.r"` エラーが出る場合の解決方法

例えば、

```console
pdftk encrypted.pdf input_pw PASSWORD output plain.pdf
```

のようなコマンドでパスワード保護された pdf ファイルを復号する際に、以下のようなエラーが表示される場合

```text
Error: Unexpected Exception in open_reader()
pdftk.com.lowagie.text.exceptions.InvalidPdfException: unknown.encryption.type.r
```

## 原因

pdf ファイルの暗号化に使用されているアルゴリズムが実装されていない。

例えば、`pdftk port to java 3.0.9` では鍵長256ビットの[AES](https://ja.wikipedia.org/wiki/Advanced_Encryption_Standard)が実装されていない。

## 対応策

pdftk でもいずれ実装されると思うが、

- 256-bit AES 対応済みコマンドを使う

例えば、[qpdf](https://sourceforge.net/projects/qpdf/) を Debian/Ubuntu で使う場合

```console
sudo apt install qpdf
```

などでインストールした後

```console
qpdf --password="PASSWORD" --decrypt encrypted.pdf plain.pdf
```

## ちなみに

- qpdf で plain.pdf から指定ページ(以下の例では 2～4と6 ページ)を抽出し、output.pdf に保存する場合

    ```console
    qpdf plain.pdf --pages plain.pdf 2-4,6 -- output.pdf
    ```

- qpdf で `PASSWORD` をコマンドラインに書きたくない場合は[こちら][1]。
- pdftk の場合は `PASSWORD` のところを `PROMPT` としてコマンドを実行するとパスワード入力プロンプト経由でのパスワード入力となる[1]。

[1]: https://kazkobara.github.io/tips-jp/linux/password_prompt.html

---
[homeに戻る](https://kazkobara.github.io/)
