# WSLのgitでGPG署名を付ける場合に`gpg failed to sign the data`となる場合

## 解決策

1. `~/.bashrc` に以下を追加

    ```shell
    # enable passphrase prompt for gpg
    export GPG_TTY=$(tty)
    ```

2. 追加後`source ~/.bashrc`

## 補足

上記で解決しない場合には、以下の可能性もある。

### 「gpg コマンドが入っていない」、「署名鍵が作られていない」など

1. `GIT_CURL_VERBOSE=1 GIT_TRACE=1 <エラーとなるgitコマンドとオプション>` を実行しgitから呼び出されているgpgコマンドを表示させる。
2. 表示されたコマンドをコマンドラインで実行。
    - 実行に失敗する場合には、「gpg コマンドが入っていない」、「署名鍵が作られていない」などの原因が考えられる。これらの解決策は検索すれば出てくる。

### `git config` の `user.signingkey` が設定されていない

1. 以下のコマンドを実行

    ```console
    git config --global --list
    ```

2. `user.signingkey=<GPG KEY ID>` が表示されない場合には、以下を実行

    ```console
    gpg --list-secret-key | grep sec -A 1
    ```

3. 上記で得られた2行目の16進数を以下の`<GPG KEY ID>`として、以下のコマンドを実行する。

    ```console
    git config --global user.signingkey <GPG KEY ID>
    ```

## link

- [WSL Ubuntu: git gpg signing Inappropriate ioctl for device #4029](https://github.com/microsoft/WSL/issues/4029)
- [Git error: gpg failed to sign the data on Linux](https://stackoverflow.com/questions/52808365/git-error-gpg-failed-to-sign-the-data-on-linux)

---
[homeに戻る](https://kazkobara.github.io/)
