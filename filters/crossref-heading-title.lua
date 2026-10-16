-- Cross-referenceブロック（#def-, #thm- など）の先頭に置いた見出し（##, ###, ####）を
-- [タイトル]{.def-title} と同じ表示にする
local crossref_prefixes = {
  thm = true, lem = true, cor = true, prp = true,
  cnj = true, def = true, exm = true, exr = true,
}

function Div(div)
  local prefix = div.identifier:match("^(%a+)%-")
  if not prefix or not crossref_prefixes[prefix] then
    return nil
  end

  local first = div.content[1]
  if not first or first.t ~= "Header" or first.level < 2 or first.level > 4 then
    return nil
  end

  div.content[1] = pandoc.Para({
    pandoc.Span(first.content, pandoc.Attr("", { "def-title" })),
  })
  return div
end
