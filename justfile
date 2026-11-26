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
