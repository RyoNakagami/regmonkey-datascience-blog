-- ::: {.circle-numbered} の補助フィルタ．番号そのものの描画は styles.css の .circle-numbered で行う．
-- CSS だけでは扱えない次の2つを，その div 専用の <style> に変換する．
--   1. circle-numbered-style="color: #c00" … 番号（li::before）の見た目を上書きする
--   2. 開始番号（"5." から始まるリスト）… CSS カウンタは start 属性を見ないので引き継ぐ

local counter = 0

function Div(div)
  if not div.classes:includes("circle-numbered") then
    return nil
  end

  local style = div.attributes["circle-numbered-style"]
  div.attributes["circle-numbered-style"] = nil

  if not FORMAT:match("html") then
    return div
  end

  local rules = {}
  local function selector()
    if div.identifier == "" then
      counter = counter + 1
      div.identifier = "circle-numbered-" .. counter
    end
    return "#" .. div.identifier
  end

  -- 直下の番号付きリストのうち，1 以外から始まるものの開始番号を引き継ぐ
  local nth = 0
  for _, block in ipairs(div.content) do
    if block.t == "OrderedList" then
      nth = nth + 1
      local start = block.listAttributes.start or 1
      if start ~= 1 then
        table.insert(rules, string.format(
          "%s > ol:nth-of-type(%d) { counter-reset: circle-numbered %d; }",
          selector(), nth, start - 1))
      end
    end
  end

  if style then
    -- 値から <style> を閉じたり，ルールの外へ出たりできないようにする
    style = style:gsub("[<>{}]", "")
    table.insert(rules, string.format("%s > ol > li::before { %s }", selector(), style))
  end

  if #rules > 0 then
    table.insert(div.content, 1,
      pandoc.RawBlock("html", "<style>" .. table.concat(rules, "\n") .. "</style>"))
  end
  return div
end
