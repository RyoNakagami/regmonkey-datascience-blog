-- ::: {#cmd-xxx .custom_command .blog-custom-border} を「Command N」付きのブロックにする．
-- Quarto の theorem 系 (#def- など) と同じ見た目になるよう，タイトルを
-- <span class="theorem-title"><strong>Command N</strong></span> として先頭段落に置く．
--   - 番号は記事ごとに 1 から振る
--   - 先頭の見出し (##, ###, ####) は [タイトル]{.def-title} と同じ表示にする
--   - id (#cmd-xxx) を付けると本文中の @cmd-xxx が「Command N」へのリンクになる

local counter = 0
local labels = {}

local function title_inlines(n)
  return {
    pandoc.Span(
      { pandoc.Strong({ pandoc.Str("Command"), pandoc.Space(), pandoc.Str(tostring(n)) }) },
      pandoc.Attr("", { "theorem-title" })
    ),
  }
end

local function number_blocks(div)
  if not div.classes:includes("custom_command") then
    return nil
  end

  counter = counter + 1
  if div.identifier ~= "" then
    labels[div.identifier] = counter
  end

  local title = title_inlines(counter)
  local first = div.content[1]
  if first and first.t == "Header" and first.level >= 2 and first.level <= 4 then
    table.insert(title, pandoc.Space())
    table.insert(title, pandoc.Span(first.content, pandoc.Attr("", { "def-title" })))
    div.content[1] = pandoc.Para(title)
  elseif first and first.t == "Para" then
    table.insert(title, pandoc.Space())
    for _, inline in ipairs(first.content) do
      table.insert(title, inline)
    end
    first.content = title
  else
    table.insert(div.content, 1, pandoc.Para(title))
  end
  return div
end

local function resolve_refs(cite)
  if #cite.citations ~= 1 then
    return nil
  end
  local id = cite.citations[1].id
  local n = labels[id]
  if not n then
    return nil
  end
  return pandoc.Link({ pandoc.Str("Command"), pandoc.Space(), pandoc.Str(tostring(n)) }, "#" .. id)
end

return {
  { Div = number_blocks },
  { Cite = resolve_refs },
}
