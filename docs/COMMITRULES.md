# Commit Rules

- This repository is a **Quarto content site** — blog posts (`posts/`), reference
  pages (`dictionary/`, `FAQ/`, `link_list/`), and book-style series threaded
  together by `listing_category`.
- It follows the [Conventional Commits](https://www.conventionalcommits.org/en/v1.0.0/)
  specification, adapted so that the `<type>` describes a change to **content**,
  not only to code.
- A consistent history makes it easy to answer "when did this post land?", "what
  changed in the glossary?", and "which commits touched the build?" — and it keeps
  the generated changelog readable.

## Commit Message Format

```text
<type>(<scope>): <description>   ← single line, mandatory

[optional body]

[optional footer(s)]
```

- The **header** is the first line and is mandatory — it is always a **single line**.
- The **scope** is optional but strongly encouraged; in a content repo it is
  usually the post slug or the section touched.
- A blank line separates the header from the body, and the body from the footer.

### Examples

A new post:

```text
post(lean4-setup): add Lean4 installation guide for Ubuntu

Covers elan as the version manager, VS Code extension setup, and the
mathlib cache warm-up step that is easy to miss on a fresh install.
```

An edit to an existing post:

```text
edit(shell-one-liner): clarify grep behaviour on empty lines
```

A reference-data change:

```text
dict(command): add realpath entry
```

Site-wide infrastructure:

```text
build: disable MathJax auto-injection via html-math-method plain
```

## Type

The `<type>` describes the kind of change and must be one of the following.
The first group is **content**; the second is **site and tooling**.

### Content types

| Type      | Description                                                                    |
| --------- | ------------------------------------------------------------------------------ |
| `post`    | Add a **new** post under `posts/<date>-<slug>/`                                 |
| `edit`    | Substantive edit to an existing post — new section, corrected explanation       |
| `dict`    | Changes to `dictionary/` — term, command, regex, unicode entries                |
| `faq`     | Changes to `FAQ/`                                                              |
| `link`    | Changes to `link_list/`                                                        |
| `series`  | Restructure a book-style series — reorder, re-thread `listing_category`, split  |
| `fig`     | Figures and diagrams — SVG, TikZ, plots, screenshots under `img/` or a post dir |
| `typo`    | Typos, punctuation normalisation, wording touch-ups with no change in meaning   |
| `meta`    | Frontmatter only — `title`, `date`, `categories`, `description`, `listing_category` |

### Site & tooling types

| Type       | Description                                                                  |
| ---------- | ---------------------------------------------------------------------------- |
| `style`    | Presentation only — `styles.css`, `include/*.scss`, layout, fonts            |
| `feat`     | New site capability — filter, shortcode, generator script, Quarto extension  |
| `fix`      | A bug fix in site code, a generator, a filter, or a broken render            |
| `refactor` | Code or file reorganisation that neither fixes a bug nor adds a feature      |
| `perf`     | Faster build or render (e.g. `_freeze` caching, incremental render)          |
| `build`    | Quarto config, `_quarto.yml`, extensions, `pyproject.toml`, Poetry deps      |
| `ci`       | GitHub Actions workflows, `.pre-commit-config.yaml`                          |
| `seo`      | `seo/`, `badges/`, analytics, Open Graph, site verification files            |
| `docs`     | Repository documentation — `README.md`, `docs/`, `.claude/skills/`           |
| `chore`    | Housekeeping — `.gitignore`, cleanup of stray `.quarto_ipynb` files, backups |
| `revert`   | Reverts a previous commit                                                    |

> [!NOTE]
> `post` vs `edit` vs `typo` is the distinction that matters most here.
> Reach for `post` only when a new post directory is created; use `edit` when the
> reader would learn something new; use `typo` when they would not.

### Legacy tags

Older commits in this repository use shouted tags (`FEATURE:`, `CHORE:`,
`REFACTORING:`, `FIXTYPOS:`) documented in `dictionary/git_commit_tag.yml`, and
many use a bare capitalised sentence with no tag at all. Those are **history** —
do not imitate them. New commits follow the format above. The mapping, if you need
to relate the two:

| Legacy tag                | Use instead                       |
| ------------------------- | --------------------------------- |
| `FEATURE`                 | `feat`, or `post` for a new post  |
| `FIX`, `HOTFIX`           | `fix`                            |
| `ENH`                     | `perf`, or `edit` for prose       |
| `REFACTOR`, `REFACTORING` | `refactor`                       |
| `RENAME`, `REMOVE`        | `refactor`, or `chore`           |
| `DOCS`                    | `docs`, or `edit` for post prose  |
| `STYLE`                   | `style`                          |
| `CICD`                    | `ci`                             |
| `ENV`, `DEPENDENCY`       | `build`                          |
| `FIXTYPOS`                | `typo`                           |

## Scope

The `<scope>` is optional and names the part of the site affected. Use a short,
lowercase noun. Omit it when the change is genuinely global.

- **For a post**, use the **slug without the date prefix**:
  `post(lean4-setup):`, `edit(shell-one-liner):`, `fig(wget-continue-flow):`
- **For a series**, use the series name: `series(set-and-topology):`
- **For reference pages**, use the file or facet:
  `dict(command):`, `dict(regex):`, `dict(unicode):`
- **For site internals**, use the directory or subsystem:
  `style(dark-theme):`, `build(quarto)`, `ci(publish):`, `feat(glossary):`

## Description

- Keep the description on a **single line** — never wrap it onto multiple lines.
- Use the **imperative, present tense**: "add", not "added" or "adds".
- Do **not** capitalize the first letter.
- Do **not** end with a period.
- Keep the header concise — aim for **50 characters or fewer**, hard limit **72**.
- Wrap file, command, and option names in backticks, e.g. a header reading
  `edit(find): document -exec with +` becomes ``edit(find): document `-exec` with `+` ``
- Japanese is acceptable in the description when the change is about Japanese
  prose or terminology, but keep the `<type>(<scope>):` prefix in ASCII:
  `dict(term): パスカルケースの項目を追加`
- If more explanation is needed, put it in the **body**, not the description.

## Body

- Optional. Use it to explain **what** and **why**, not **how**.
- Wrap lines at **72 characters**.
- Separate from the header with one blank line.
- For a new post, a one-or-two-sentence summary of what the post covers is more
  useful than a list of the sections you wrote.

## Footer

- Optional. Used for metadata such as issue references and breaking changes.
- Reference issues with `Closes #<id>`, `Fixes #<id>`, or `Refs #<id>`.
- Note when a change affects published URLs:
  `Refs: /posts/2026-07-31-lean4-setup/`

### Breaking Changes

In a content site, a "breaking change" is one that **breaks existing URLs or
inbound links** — renaming or deleting a post directory, changing a date prefix,
or moving a reference page. Indicate it with a `!` after the type/scope, a
`BREAKING CHANGE:` footer, or both.

```text
refactor(claude-code-setup)!: rename post to skill-ignition

BREAKING CHANGE: /posts/2025-06-14-claude-code-setup/ no longer resolves.
Inbound links and the RSS feed entry both change.
```

## One Change, One Commit

- Keep a post and its figures together in one commit — they are one change.
- Split unrelated work apart: adding a post and bumping a dependency are two
  commits, even when done in the same sitting.
- Do **not** commit build output. `_site/` and `_freeze/` are generated, and
  stray `*.quarto_ipynb` files are render artifacts.
- `pre-commit` enforces file-size limits (1MB general, 2MB HTML). Compress or
  down-scale screenshots rather than raising the limit.

## Quick Reference

```text
post:     a new post under posts/
edit:     substantive edit to an existing post
dict:     dictionary/ entries
faq:      FAQ/ changes
link:     link_list/ changes
series:   restructure a book-style series
fig:      figures, diagrams, screenshots
typo:     typos and wording, no change in meaning
meta:     frontmatter only

style:    CSS/SCSS, layout, fonts
feat:     new site capability
fix:      bug fix in site code or a broken render
refactor: reorganisation, no feature/fix
perf:     faster build or render
build:    Quarto config, extensions, dependencies
ci:       GitHub Actions, pre-commit
seo:      seo/, badges/, analytics
docs:     repo documentation
chore:    housekeeping
revert:   revert a previous commit
```
