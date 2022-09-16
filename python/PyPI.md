# PyPI に自作の python package を登録する方法

<!-- markdownlint-disable MD046 code-block-style -->

## 必要となる背景知識

以下の項目の解説は行わないのですが、検索すると直ぐに出てくると思いますので、必要に応じてご確認下さい。

- pyenv-virtualenv, pipenv などの python仮想環境の作成方法
- python package 作成方法の詳細
- PyPI サイトでのアカウント作成、登録方法

## 前準備

### フォルダ構成の例

        .  <--- 作業用フォルダ
        ├── README.md
        ├── build                   <-自動生成
        ├── dist                    <-自動生成
        ├── <package_name>
        │   ├── __init__.py
        │   └── __main__.py
        ├── <package_name>.egg-info <-自動生成
        ├── setup.cfg               <-作成
        └── setup.py                <-作成
        
        ~/.pypirc                   <-作成

- 作業用フォルダを git で管理している場合には、`.gitignore` に以下を追加しておく。これらのフォルダ中のデータは作業後消去可能。

```.gitignore
build/
dist/
<package_name>.egg-info/
```

## 自作 python package 登録までの手順

新たな version を追加する場合は(`<package_name>.__version__` などを更新後に) [更新時に必要な手順](#更新時に必要な手順)を実行。

### 初回のみ必要な手順

1. `setup.py` に以下のみを記載

    ```python
    from setuptools import setup
    setup()
    ```

    - 注記 [setup.cfg-only projects](https://setuptools.readthedocs.io/en/latest/setuptools.html#setup-cfg-only-projects) によると、"setuptools >= 40.9.0" においては、setup.py は後方互換性の確保とバグ対策のためのファイルとなっており、詳細は setup.cfg に記載する。

1. setup.cfg の作成

   - setup.cfg 記載方法の詳細は検索すると出てきます。
   - 動作確認に使用した setup.cfg を[こちら](https://github.com/KazKobara/ebcic/blob/master/setup.cfg)に置いてあります。
   - 注意点や助言:
     - install_requires, python_requires は以下のテストの段階で動作を確認しながら決める。
     - install_requires で指定可能な `;` はその後ろの条件が True の場合にのみその前のパッケージが必要となるという意味。
       - 例えば、以下は python_version が 2.6 の場合には importlib を求めるという意味。（version 2.6 の python を求めるという意味ではないことに注意!!）

        ```text
        install_requires =
            importlib; python_version == "2.6"
        ```

1. dist の作成に必要となるパッケージのインストール

    ```console
    pip install twine wheel
    ```

1. PyPI テストサイトおよび本番サイトへのユーザ登録

    - [PyPI本番サイトのユーザ登録ページ](https://test.pypi.org/account/register/)および[PyPIテストサイトのユーザ登録ページ](https://pypi.org/account/register/)でそれぞれユーザ登録する。
      - 登録情報は同じでも違ってもよい。

1. 登録コマンド省略するための設定

    - 必要に応じ以下の内容を `~/.pypirc` に記載。

    ```text
    [distutils]
    index-servers =
        pypi
        testpypi

    [pypi]
    repository: https://upload.pypi.org/legacy/
    username:   <上記で登録したユーザ名>
    # password: <パスワードは記載しない>

    [testpypi]
    repository: https://test.pypi.org/legacy/
    username:   <上記で登録したユーザ名>
    # password: <パスワードは記載しない>
    ```

1. 以下の[更新時に必要な手順](#更新時に必要な手順)を実行

### 更新時に必要な手順

以下の手順の実行は、[こちらの bash script](https://raw.githubusercontent.com/KazKobara/tips-jp/gh-pages/python/pypi.sh) を以下の引数で実行することでも可能です。

```bash
./pypi.sh <package_name> <package_ver>
```

1. soft と binary の dist を作成しチェック

    以下のコマンドを実行

    ```console
    python setup.py sdist bdist_wheel
    twine check ./dist/*
    ```

    以下のように `PASSED` が表示されれば次に進む。

    ```text
    Checking dist/<package_name>-<version>*: PASSED
    ```

1. テスト環境を作り、そこに上記 dist 下につくられたローカルパッケージをインストールしテスト

    - Pythonの仮想環境などを用いてテスト環境を作り、そこにテストする version の Python とデフォルトのパッケージのみが入った状態にする。
    - 以下のコマンドにより <package_name> をインストール

        ```console
        pip install --no-index --find-links=<上記でチェックしたdistへのPATH>/dist <package_name>==<version>
        ```

        ```text
        ERROR: Could not find a version that satisfies the requirement scipy (from <package_name>)
        ERROR: No matching distribution found for scipy
        ```

        - 上記のエラーメッセージのように他のパッケージの不足やインストールが求められたら、それらをインストールすると共に、それらのパッケージ名を setup.cfg の `install_requires =` の下に１行づつ入れる。
        - （パッケージ間の依存関係により、パッケージのインストール順序を変えると上記に記述すべきパッケージの数は変わるため、なるべく規模の大きなパッケージからインストールするとよい。）
        - なお、 `pip install --no-index --find-links=` によるローカルフォルダからのパッケージインストールでは、`install_requires =` に記載したパッケージは自動インストールされないため、インストールしたパッケージの動作確認が終われば次に進む。

    - `pip list` により意図する version の <package_name> がインストールされていることが確認できれば、<package_name> の動作を確認する。

1. PyPI テストサイトへのアップロードとインストール

    - PyPI 本番およびテストサイトでは、いずれも、登録したパッケージの削除は可能であるが、削除したとしても**一度登録した version 番号で別のパッケージを登録することはできない**
      - ただし、PyPI の本番およびテストサイトは独立しているため、それらに同じ version 番号で違う内容を登録することはできる。
    - そのため、まずは PyPIのテストサイトを用いて登録のテストを行うこと。
    - 以下のコマンドで PyPI テストサイトへアップロード

        ```console
        twine upload -r testpypi dist/<package_name>-<version>*
        ```

    - 初期状態に戻したテスト環境(Python仮想環境)へ移動し、パッケージをダウンロードし動作をテスト。

        ```console
        pip uninstall <package_name>
        pip install -i https://test.pypi.org/simple/ <package_name>==<version>
        ```

1. PyPI 本番サイトへのアップロードとインストール

    - 以下のコマンドで PyPI 本番サイトへアップロード

        ```console
        twine upload -r pypi dist/<package_name>-<version>*
        ```

    - 初期状態に戻したテスト環境(Python仮想環境)へ移動し、パッケージをダウンロードし動作をテスト。

        ```console
        pip uninstall <package_name>
        pip install <package_name>==<version>
        ```

## 動作確認した version

### ebcic ver. 0.0.2

```text
Python       3.8.0
pip          21.3.1
setuptools   60.2.0
twine        3.4.1
wheel        0.35.1
```

### ebcic ver. 0.0.1 - 0.0.2

```text
Python       3.8.5
pip          21.0.1
setuptools   50.3.2
twine        3.4.1
wheel        0.35.1
```

---
最後までお読み頂きありがとうございます。
GitHubアカウントをお持ちでしたら、フォロー及び Star 頂ければと思います。リンクも歓迎です。

- [Follow (クリック後の画面左)](https://github.com/KazKobara)
- [Star (クリック後の画面右上)](https://github.com/KazKobara/tips-jp)

[homeに戻る](https://kazkobara.github.io/README-jp.html)
