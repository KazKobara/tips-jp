# WSLのgitでGPG署名を付ける場合に`gpg failed to sign the data`となる場合

## 解決策

1. `~/.bashrc` に以下を追加

    ```shell
    # enable passphrase prompt for gpg
    export GPG_TTY=$(tty)
    ```

2. 追加後`source ~/.bashrc`

## 補足

1. `GIT_CURL_VERBOSE=1 GIT_TRACE=1 <エラーとなるgitコマンドとオプション>` を実行しgitから呼び出されているgpgコマンドを表示させる。
2. 表示されたコマンドをコマンドラインで実行。
    - 実行に失敗する場合には、「gpg コマンドが入っていない」、「署名鍵が作られていない」など、上記とは別の原因が考えられる。これらの解決策は検索すれば出てくる。
    - 実行に成功する場合には、冒頭の解決策を試す。

## link

- [WSL Ubuntu: git gpg signing Inappropriate ioctl for device #4029](https://github.com/microsoft/WSL/issues/4029)

---

- [一覧に戻る](docker/index.md)
