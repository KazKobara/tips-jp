# git push で `EOFoading LFS objects:` `error: failed to push some refs to '/` などのエラーが出た場合の解決方法

## 解決策

ローカルレポジトリの .git/config の url として、例えば以下のように directory を指定している場合、

```text
[remote "origin"]
        url = /remote_repo/repo_name.git
```

directory の頭に `file://` を付ける。

```text
[remote "origin"]
        url = file:///remote_repo/repo_name.git
```

## 補足

### 必要な背景知識

- git
- git ローカルレポジトリ
- git リモートレポジトリ として directory を指定する
- git LFS (Large File Storage)

### 表題のエラーが起こる状況の例

0. git LFS の設定が行われている。

1. git のローカルレポジトリを作成する。

   まずは一人で作業を行うため、リモートレポジトリ無しで、ローカルレポジトリのみを作成する。 
   以下はローカルレポジトリの名前を repo_name とした場合の例、

    ```console
    mkdir repo_name
    cd repo_name
    git init
    ```

    (以降、当該フォルダ内で git add, git commit コマンドなどを利用して編集作業を行う。)

2. git のリモートレポジトリを作成する。

    閉鎖ネットワーク内で共同作業を行うなどの理由で、共有フォルダなどの下に repo_name.git という名前のフォルダでリモートレポジトリを作成する。

    ```console
    git init --bare --shared /path/to/repo_name.git
    ```

    ここで、`/path/to/repo_name.git` の先頭には `file://` を**付けてはならない**ことに注意!!
    (付けるとコマンドを実行した場所に file: という名前のフォルダができ、その下にリモートレポジトリができるため、意図した場所にリモートレポジトリが作成されないことになる。)

    また、`--shared` には以下のような引数を指定できるため、フォルダの共有範囲に応じて引数を指定する。

    ```text
    --shared[=(false|true|umask|group|all|world|everybody|0xxx)]
    ```

3. ローカルレポジトリに移動し、リモートレポジトリを紐づける

    ```console
    cd repo_name
    git remote add origin file:///path/to/repo_name.git
    git push --set-upstream origin main
    ```

    ここで、`file://` を付けずに `/path/to/repo_name.git` とすると以降の `git push --force --set-upstream origin main` で表題のエラーとなる。

    紐づけられているリモートレポジトリは以下のコマンドで確認できる。

    ```console
    git remote -v
    ```

    なお、origin という名前のリモートレポジトリが既に存在している場合に、別のリモートレポジトリの url を追加する場合には、```git remote add```ではなく以下を実行する。

    ```console
    git remote set-url origin --add <url>
    ```

4. 共同作業者による `git clone`
 
    ```console
    git clone file:///path/to/repo_name.git
    ```

    ここでも、`/path/to/repo_name.git` の前に `file://` を付けておく。
    もし、以下の警告が出た場合、

    ```text
    warning: remote HEAD refers to nonexistent ref, unable to checkout.
    ```

    デフォルトのブランチ名(例えば master )がリモートレポジトリに存在していないため、以下のコマンドでリモートレポジトリに存在しているブランチを確認し、

    ```console
    git branch -a
    ```

    例えば、```remotes/origin/main``` が存在していて、それをチェックアウトする場合は、以下のコマンドを実行する。
    
    ```console
    git checkout main
    ```

## link

- [lfs.url not honored when using local path as remote #3893](https://github.com/git-lfs/git-lfs/issues/3893)
- [I have an issue when pushing to a network drive using Git LFS](https://stackoverflow.com/questions/58849793/i-have-an-issue-when-pushing-to-a-network-drive-using-git-lfs)

---

- [一覧に戻る](docker/index.md)
