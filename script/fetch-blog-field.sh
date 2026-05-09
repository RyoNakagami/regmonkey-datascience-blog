#!/usr/bin/env bash
# Extract unique frontmatter values from qmd files under posts/.
#
# Usage:
#   script/fetch-blog-field.sh --categories [DIR]
#   script/fetch-blog-field.sh --title      [DIR]
#
# DIR defaults to the repository's posts/ directory.

set -euo pipefail

usage() {
    cat <<'EOF' >&2
usage: fetch-blog-field.sh (--categories | --title) [DIR]
  --categories  list each unique item in `categories: [...]`
  --title       list each unique `title:` value
EOF
    exit 2
}

mode=""
target_dir=""

while (($#)); do
    case "$1" in
        --categories|--title)
            [[ -n "${mode}" ]] && usage
            mode="${1#--}"
            ;;
        -h|--help) usage ;;
        --) shift; target_dir="${1:-}"; break ;;
        -*) usage ;;
        *)
            [[ -n "${target_dir}" ]] && usage
            target_dir="$1"
            ;;
    esac
    shift
done

[[ -z "${mode}" ]] && usage

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
target_dir="${target_dir:-${repo_root}/posts}"

if [[ ! -d "${target_dir}" ]]; then
    echo "error: directory not found: ${target_dir}" >&2
    exit 1
fi

find "${target_dir}" -type f -name '*.qmd' -print0 \
    | xargs -0 awk -v mode="${mode}" '
        FNR == 1 { in_fm = 0; seen = 0 }
        /^---[[:space:]]*$/ {
            if (seen == 0) { in_fm = 1; seen = 1; next }
            else           { in_fm = 0; nextfile }
        }
        !in_fm { next }

        mode == "categories" && /^categories:[[:space:]]*\[/ {
            line = $0
            sub(/^categories:[[:space:]]*\[/, "", line)
            sub(/\].*$/, "", line)
            n = split(line, items, ",")
            for (i = 1; i <= n; i++) {
                v = items[i]
                gsub(/^[[:space:]]+|[[:space:]]+$/, "", v)
                gsub(/^["\x27]|["\x27]$/, "", v)
                if (v != "") print v
            }
        }

        mode == "title" && /^title:[[:space:]]*/ {
            v = $0
            sub(/^title:[[:space:]]*/, "", v)
            # strip surrounding matching quotes (double or single)
            if (v ~ /^".*"$/)        { v = substr(v, 2, length(v) - 2) }
            else if (v ~ /^\x27.*\x27$/) { v = substr(v, 2, length(v) - 2) }
            gsub(/^[[:space:]]+|[[:space:]]+$/, "", v)
            if (v != "") print v
        }
    ' \
    | LC_ALL=C sort -u
