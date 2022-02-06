# shell script の小ネタ集（間違いやすい箇所のまとめ）

## 複数行コメント中のシングルクオートとダブルクオート

```shell
: '
複数行のコメントはこれでも実現可能ですが、シングルクオートで挟まれたエリアはエスケープ記号も無視されるためエスケープしたとしてもシングルクオートを含められません。
ダブルクオート「"」は含められます。
'
```

```shell
: "
複数行のコメントはこれでも実現可能ですが、
ダブルクオートを含める際にはエスケープ「\"」が必要です。
"
```

```shell
: <<'COMMENT_EOF'
ここはシングルクオート「'」もダブルクオート「"」も
エスケープ無しで複数行をコメントアウトできます。
COMMENT_EOF
```

## 複数行の標準入力をコマンドに渡す際(Here document)のシングルクオート、ダブルクオート、クオート無しの違い

```shell
cat <<'STD_INPUT_WITHOUT_EXPANSION_EOF'
ここから標準入力
右上のラベルをシングルクオートまたはダブルクオートで挟むと
変数やコマンド(${PWD}、`pwd`)は展開されません。
ここまで標準入力
STD_INPUT_WITHOUT_EXPANSION_EOF
```

```shell
cat <<STD_INPUT_WITH_EXPANSION_EOF
ここから標準入力
右上のラベルをシングルクオートで挟んでないと
変数やコマンド(${PWD}、`pwd`)は展開されます。
ここまで標準入力
STD_INPUT_WITH_EXPANSION_EOF
```

## 比較演算子としての "=" と "==" との違い

- POSIX sh では "==" は未定義なので "=" を使う。
- [比較演算子としての動作は同じ][Comparison Operators]だが、代入の "=" と区別するために "==" が使える場合にはそちらを使う。
  - 代入の "=" では "=" の前後にスペースを入れない。スペースが入ると代入側はコマンドと解釈される。

## test、"[ ]"、"[[ ]]" の違い

- POSIX sh では、"[[ ]]" は未定義なので、"[ ]" か test を使う。
- "[ ]" と test の動作は基本同じ。
- "[ ]" と test で展開された変数は変数の範囲が不明確になるため、それを意図していない限り必ずダブルクォートで挟んでおく。
- ただし、let コマンド、バッククオート「\` \`」、$((var)) などで数値として展開されたは変数は分割されていないため、ダブルクォートは付けても付けなくてもよい。
- "[[ ]]"内では展開された変数にスペースなどが入っても一塊として扱われるため、ダブルクォートは不要。
- [より詳しい説明はこちら](https://fumiyas.github.io/2013/12/15/test.sh-advent-calendar.html "https://fumiyas.github.io/2013/12/15/test.sh-advent-calendar.html")にあります。

## リンク

- シェルスクリプトを手軽に試せるサイト [websh] と[その説明][webshの説明]

<!--参照-->

[Comparison Operators]: https://tldp.org/LDP/abs/html/comparison-ops.html "https://tldp.org/LDP/abs/html/comparison-ops.html"
[websh]: https://websh.jiro4989.com/ "https://websh.jiro4989.com/"
[webshの説明]: https://scrapbox.io/jiro4989/Web%E3%81%A7%E3%82%B7%E3%82%A7%E3%83%AB%E3%82%92%E5%AE%9F%E8%A1%8C%E3%81%99%E3%82%8Bwebsh%E3%82%92%E4%BD%9C%E3%81%A3%E3%81%9F "https://scrapbox.io/jiro4989/Web%E3%81%A7%E3%82%B7%E3%82%A7%E3%83%AB%E3%82%92%E5%AE%9F%E8%A1%8C%E3%81%99%E3%82%8Bwebsh%E3%82%92%E4%BD%9C%E3%81%A3%E3%81%9F"

---

- [https://github.com/KazKobara/](https://github.com/KazKobara/)
- [https://kazkobara.github.io/ (mostly in Japanese)](https://kazkobara.github.io/)
