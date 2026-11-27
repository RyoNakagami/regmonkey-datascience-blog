# regmonkey-datascience-blog-new/justfile
set shell := ["bash", "-euo", "pipefail", "-c"]

today := `date +%F`

[doc("レシピのヘルプを表示")]
help recipe="":
    #!/usr/bin/env bash
    # Usage: just help [recipe]
    #
    # recipe の docstring を表示します。省略時はレシピ一覧を表示します。
    set -euo pipefail
    if [[ -z "{{recipe}}" ]]; then
      # レシピ名・引数・説明の3列に揃えて表示する
      "{{just_executable()}}" --justfile "{{justfile()}}" --list --unsorted |
        awk '
          NR == 1 { print; next }
          {
            line = $0; sub(/^[ \t]+/, "", line)
            doc = ""
            if ((i = index(line, " # ")) > 0) { doc = substr(line, i + 3); line = substr(line, 1, i - 1) }
            sub(/[ \t]+$/, "", line)
            name = line; args = ""
            if ((j = index(line, " ")) > 0) { name = substr(line, 1, j - 1); args = substr(line, j + 1) }
            n++; names[n] = name; argss[n] = args; docs[n] = doc
            if (length(name) > wn) wn = length(name)
            if (length(args) > wa) wa = length(args)
          }
          END {
            for (k = 1; k <= n; k++)
              printf "    %-*s  %-*s  # %s\n", wn, names[k], wa, argss[k], docs[k]
          }
        '
      exit 0
    fi
    awk -v r="{{recipe}}" '
      !in_r && $0 ~ ("^@?" r "([ \t][^:]*)?:([^=]|$)") { in_r = 1; found = 1; next }
      in_r && /^[ \t]+#!/ { next }
      in_r && /^[ \t]+#/  { line = $0; sub(/^[ \t]+# ?/, "", line); print line; next }
      in_r { exit }
      END { exit !found }
    ' "{{justfile()}}" || { echo "error: unknown recipe: {{recipe}}" >&2; exit 1; }

[doc("新しい記事を作る")]
new slug="" date=today:
    #!/usr/bin/env bash
    # Usage: just new <slug> [YYYY-MM-DD]
    #
    # 新しいブログ記事のディレクトリを作成します。
    #
    # Arguments:
    #   slug        記事のスラッグ（例: gnome-extensions）
    #   YYYY-MM-DD  記事の日付。省略時は今日
    #
    # Creates:
    #   posts/<date>-<slug>/
    #   ├── figures/
    #   └── index.qmd   (date: <date>, date-modified: 実行日)
    #
    # Examples:
    #   just new gnome-extensions 2026-11-22
    #   cd "$(just new gnome-extensions)"
    set -euo pipefail
    case "{{slug}}" in
      ""|-h|--help|help)
        exec "{{just_executable()}}" --justfile "{{justfile()}}" help new ;;
    esac
    if [[ ! "{{date}}" =~ ^[0-9]{4}-[0-9]{2}-[0-9]{2}$ ]]; then
      echo "error: date は YYYY-MM-DD 形式で指定してください: {{date}}" >&2
      exit 1
    fi
    dir="posts/{{date}}-{{slug}}"
    if [[ -e "$dir" ]]; then
      echo "error: $dir は既に存在します" >&2
      exit 1
    fi
    mkdir -p "$dir/figures"
    cat > "$dir/index.qmd" <<'EOF'
    ---
    title: ""
    author: "Ryo Nakagami"
    date: "{{date}}"
    date-modified: "{{today}}"
    categories: []
    lightbox: true
    comments:
      utterances:
           repo: RyoNakagami/regmonkey-datascience-blog
           label: discussion
           issue-term: title
    ---
    EOF
    echo "$dir"

[doc("categories を正規表現で検索して該当記事を一覧表示")]
[positional-arguments]
tag-search *args:
    #!/usr/bin/env bash
    # Usage: just tag-search <pattern> [--asc|--desc] [-a]
    #        just tag-search --list [pattern] [--asc|--desc]
    #
    # posts/*/index.qmd の frontmatter の categories を正規表現（ERE）で検索し，
    # いずれかの category がマッチした記事ディレクトリを一覧表示します。
    # マッチは category 単位・部分一致・大文字小文字を区別しません（ASCII のみ）。
    # 完全一致させたい場合は ^...$ で囲んでください。
    # --list を指定すると，記事ではなく category の一覧と記事件数を表示します。
    #
    # Arguments:
    #   pattern  category にマッチさせる正規表現（例: Linux, '^(C|Rust)$'）
    #            --list 指定時は省略可（省略時は全 category を表示）
    #   --list   category 一覧と記事件数を表示
    #   --asc    date の古い順に表示（--list 時は件数の少ない順）
    #   --desc   date の新しい順に表示（--list 時は件数の多い順，デフォルト）
    #   -a       ディレクトリではなく index.qmd のパスまで表示
    #
    # Output:
    #   <date>  posts/<dir>  [<categories>]          （-a 指定時は posts/<dir>/index.qmd）
    #   <count>  <category>                           （--list 指定時）
    #
    # Examples:
    #   just tag-search Linux
    #   just tag-search '^環境構築$' --asc
    #   just tag-search 'python|julia' --desc
    #   just tag-search security -a
    #   just tag-search --list
    #   just tag-search --list python --asc
    set -euo pipefail
    pattern=""
    order="desc"
    show_file=0
    list_tags=0
    for a in "$@"; do
      case "$a" in
        --asc)  order="asc" ;;
        -a)     show_file=1 ;;
        --desc) order="desc" ;;
        --list) list_tags=1 ;;
        -h|--help|help)
          exec "{{just_executable()}}" --justfile "{{justfile()}}" help tag-search ;;
        -*)
          echo "error: unknown option: $a" >&2; exit 1 ;;
        *)
          if [[ -n "$pattern" ]]; then
            echo "error: pattern は1つだけ指定してください" >&2; exit 1
          fi
          pattern="$a" ;;
      esac
    done
    if [[ -z "$pattern" && "$list_tags" -eq 0 ]]; then
      exec "{{just_executable()}}" --justfile "{{justfile()}}" help tag-search
    fi
    # 不正な正規表現を事前に検出する（検索と同じ awk で評価）
    if ! awk -v pat="$pattern" 'BEGIN { if ("" ~ pat) {} }' 2>/dev/null; then
      echo "error: 不正な正規表現です: $pattern" >&2; exit 1
    fi
    sort_opt=(-k1,1); [[ "$order" == "desc" ]] && sort_opt=(-k1,1r)
    cd "{{justfile_directory()}}"
    if [[ "$list_tags" -eq 1 ]]; then
      if [[ "$show_file" -eq 1 ]]; then
        echo "error: -a は --list と併用できません" >&2; exit 1
      fi
      # category ごとの記事件数を集計する．pattern 指定時は category 名でフィルタする
      # 件数順（同数なら category 名順）で表示
      result=$(
        awk -v pat="$(printf '%s' "$pattern" | tr '[:upper:]' '[:lower:]')" '
          FNR == 1 { infm = ($0 ~ /^---[ \t]*$/); next }
          !infm { next }
          /^---[ \t]*$/ { infm = 0; next }
          /^categories:/ {
            c = $0; sub(/^categories:[ \t]*\[/, "", c); sub(/\][ \t]*$/, "", c)
            n = split(c, arr, ",")
            for (i = 1; i <= n; i++) {
              t = arr[i]; gsub(/^[ \t"\047]+|[ \t"\047]+$/, "", t)
              if (t == "") continue
              if (pat == "" || tolower(t) ~ pat) count[t]++
            }
          }
          END { for (t in count) printf "%d\t%s\n", count[t], t }
        ' posts/*/index.qmd | sort -t$'\t' -k1,1n"$([[ "$order" == "desc" ]] && echo r)" -k2,2
      )
      if [[ -z "$result" ]]; then
        echo "no categories matched: $pattern" >&2
        exit 1
      fi
      printf '%s\n' "$result" | column -t -s$'\t'
      echo "$(printf '%s\n' "$result" | wc -l) categories" >&2
      exit 0
    fi
    # 全ファイルを1回の awk で処理する．frontmatter（先頭の --- から次の --- まで）だけを読む
    result=$(
      awk -v show_file="$show_file" -v pat="$(printf '%s' "$pattern" | tr '[:upper:]' '[:lower:]')" '
        function flush() {
          if (hit) {
            if (date == "") date = substr(dir, 7, 10)
            printf "%s\t%s\t[%s]\n", date, (show_file ? path : dir), cats
          }
          hit = 0; date = ""; cats = ""; infm = 0
        }
        FNR == 1 {
          flush()
          path = FILENAME; dir = path; sub(/\/index\.qmd$/, "", dir)
          if ($0 ~ /^---[ \t]*$/) infm = 1
          next
        }
        !infm { next }
        /^---[ \t]*$/ { infm = 0; next }
        /^date:/ {
          date = $0; sub(/^date:[ \t]*/, "", date); gsub(/["\047 \t]/, "", date)
        }
        /^categories:/ {
          c = $0; sub(/^categories:[ \t]*\[/, "", c); sub(/\][ \t]*$/, "", c)
          cats = c
          n = split(c, arr, ",")
          for (i = 1; i <= n; i++) {
            t = arr[i]; gsub(/^[ \t"\047]+|[ \t"\047]+$/, "", t)
            if (tolower(t) ~ pat) hit = 1
          }
        }
        END { flush() }
      ' posts/*/index.qmd | sort -t$'\t' "${sort_opt[@]}" -k2,2
    )
    if [[ -z "$result" ]]; then
      echo "no posts matched: $pattern" >&2
      exit 1
    fi
    printf '%s\n' "$result" | column -t -s$'\t'
    echo "$(printf '%s\n' "$result" | wc -l) posts matched" >&2
