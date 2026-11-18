---
name: add-glossary
description: |
  Use this skill when the user wants to add glossary entries to a QMD post
  in the regmonkey-datascience-blog. Triggers include phrases like
  "用語集に追加して", "glossaryに追加", "Appendixに用語を足して",
  "glossary形式で書いて", "glossaryエントリを追加". This skill enforces
  the blog's glossary YAML format inside a :::{.glossary-container} block.
---

# add-glossary

`regmonkey-datascience-blog` の QMD 記事に用語集エントリを追加する skill．

## glossary の記法

glossary は以下の形式で記述する．**必ずこの形式に従うこと．**

````markdown
:::{.glossary-container}

```yaml
glossary:
  - def: 用語名
    description: |
      用語の説明文．複数行にまたがる場合はここにインデントして続ける．
      インラインコード (`code`) は使用可能．

  - def: 別の用語
    description: |
      説明文．
```

:::
````

## 記法の制約

- `:::{.glossary-container}` と `:::` で囲む（コロンは3個）
- コードブロックのフェンスは必ず ` ```yaml ` と ` ``` `
- `glossary:` はリストのルートキー（インデントなし）
- 各エントリは `- def:` と `description:` の2フィールドのみ
- `description:` の値は必ず `|` つきのブロックスカラー（改行を保持するため）
- 説明文の各行は半角スペース 6 個でインデント
- エントリ間には空行を1行入れる
- `def:` の値にインラインコードやカッコは使用可能（例: `I/O 層 (Input/Output 層)`）
- `description:` 内ではインラインコード `` `code` `` を使用可能

## Appendix セクションへの配置

glossary は記事末尾の `## 📘 用語集` セクション内に置く．
このセクションがまだなければ末尾に追加する．

```markdown
## 📘 用語集

:::{.glossary-container}

```yaml
glossary:
  - def: 用語名
    description: |
      説明文．
```

:::
```

## エントリ追加時の手順

1. 対象ファイルを Read して現在の内容を確認する
2. `## Appendix` セクションと `:::{.glossary-container}` ブロックの有無を確認する
3. **ブロックが存在する場合**: ` ``` ` の直前（`:::` の手前）に新エントリを追記する
4. **ブロックが存在しない場合**: ファイル末尾に `## Appendix` セクションごと追加する
5. 追記後のファイルパスをユーザーに報告する

## やらないこと

- ❌ `description:` を `|` なし（フロースカラー）で書く
- ❌ `glossary-container` を `::::` (4コロン以上) で囲む（3コロン固定）
- ❌ `def` / `description` 以外のフィールドを追加する
- ❌ 用語の説明を要約・短縮する（ユーザーが渡した内容をそのまま使う）
- ❌ Appendix 以外の場所に glossary ブロックを置く
