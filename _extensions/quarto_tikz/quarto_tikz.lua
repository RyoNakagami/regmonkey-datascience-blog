--[[
tikz.lua — Quarto extension: render ```{tikz} code blocks

Pipeline (HTML / Revealjs):
  .tex --(lualatex)--> .pdf --(dvisvgm --pdf --no-fonts)--> .svg  → inline <svg>
  (lualatex + fontspec so CJK / Japanese labels render with system fonts)

Pipeline (LaTeX / PDF output):
  raw tikzpicture passthrough (preamble injected via header-includes)

Block options (#| key: value):
  #| packages: [circuitikz, pgfplots]   -- extra \usepackage
  #| libraries: [arrows.meta, calc]     -- extra \usetikzlibrary
  #| scale: 1.5                         -- wraps in \scalebox
  #| width: 60%                         -- CSS width on the <svg>/<img>
  #| filename: my-diagram               -- stable cache name
  #| caption: "..."                     -- wraps in a figure
  #| mainfont: IPAexGothic              -- fontspec main font for this block

Document metadata (front matter / _quarto.yml) — defaults for all blocks:
  tikz:
    mainfont: IPAexGothic               -- overridden by #| mainfont
    packages: [circuitikz]              -- merged with block packages
    libraries: [decorations.markings]   -- merged with block libraries

Font precedence: #| mainfont > tikz.mainfont metadata > IPAexMincho.
]]

local system = require("pandoc.system")
local utils = require("pandoc.utils")

-- ---------------------------------------------------------------------------
-- config
-- ---------------------------------------------------------------------------

local DEFAULT_LIBRARIES = {
  "arrows.meta", "positioning", "calc", "shapes.geometric", "backgrounds", "fit"
}

local DEFAULT_PACKAGES = { "amsmath", "amssymb" }

-- system font used for CJK / Japanese labels (resolved by fontspec via fontconfig)
local DEFAULT_MAINFONT = "IPAexMincho"

-- document-level defaults collected from the `tikz` metadata key (see header)
local doc_defaults = { mainfont = nil, packages = {}, libraries = {} }

local CACHE_DIR = "_tikz-cache"

-- ---------------------------------------------------------------------------
-- helpers
-- ---------------------------------------------------------------------------

local function file_exists(path)
  local f = io.open(path, "r")
  if f then f:close() return true end
  return false
end

local function read_file(path)
  local f = assert(io.open(path, "rb"))
  local s = f:read("*a")
  f:close()
  return s
end

local function write_file(path, content)
  local f = assert(io.open(path, "wb"))
  f:write(content)
  f:close()
end

local function ensure_dir(dir)
  os.execute('mkdir -p "' .. dir .. '"')
end

local function sha1(s)
  return utils.sha1(s)
end

-- parse "#| key: value" comment options at the top of the code block
local function parse_options(text)
  local opts = {}
  local body_lines = {}
  local in_header = true
  for line in (text .. "\n"):gmatch("(.-)\n") do
    local key, value = line:match("^%s*#|%s*([%w%-_]+)%s*:%s*(.+)%s*$")
    if in_header and key then
      opts[key] = value
    else
      in_header = false
      table.insert(body_lines, line)
    end
  end
  return opts, table.concat(body_lines, "\n")
end

-- "[a, b, c]" or "a, b" -> {"a","b","c"}
local function parse_list(value)
  if not value then return {} end
  value = value:gsub("^%s*%[", ""):gsub("%]%s*$", "")
  local out = {}
  for item in value:gmatch("[^,]+") do
    item = item:gsub("^%s+", ""):gsub("%s+$", ""):gsub('^"', ""):gsub('"$', "")
    if #item > 0 then table.insert(out, item) end
  end
  return out
end

-- merge any number of lists, dropping duplicates (first occurrence wins)
local function merge_lists(...)
  local out, seen = {}, {}
  for _, list in ipairs({ ... }) do
    for _, v in ipairs(list) do
      if not seen[v] then
        seen[v] = true
        table.insert(out, v)
      end
    end
  end
  return out
end

-- metadata value (MetaList or scalar / comma string) -> {strings}
local function to_string_list(v)
  local out = {}
  if v == nil then return out end
  if utils.type(v) == "List" then
    for _, item in ipairs(v) do table.insert(out, utils.stringify(item)) end
  else
    for item in utils.stringify(v):gmatch("[^,]+") do
      item = item:gsub("^%s+", ""):gsub("%s+$", "")
      if #item > 0 then table.insert(out, item) end
    end
  end
  return out
end

-- ---------------------------------------------------------------------------
-- tex assembly
-- ---------------------------------------------------------------------------

local function build_tex(body, opts)
  local packages = merge_lists(
    DEFAULT_PACKAGES, doc_defaults.packages, parse_list(opts.packages))
  local libraries = merge_lists(
    DEFAULT_LIBRARIES, doc_defaults.libraries, parse_list(opts.libraries))

  -- load tikz as a package (not the `tikz` class option): the class option
  -- expects a bare tikzpicture as the top-level box, which breaks \scalebox.
  -- fontspec + \setmainfont makes lualatex render CJK / Japanese labels with a
  -- system font (resolved through fontconfig).
  local mainfont = opts.mainfont or doc_defaults.mainfont or DEFAULT_MAINFONT
  local lines = {
    "\\documentclass[border=2pt]{standalone}",
    "\\usepackage{fontspec}",
    "\\setmainfont{" .. mainfont .. "}",
    "\\usepackage{tikz}",
  }
  for _, p in ipairs(packages) do
    table.insert(lines, "\\usepackage{" .. p .. "}")
  end
  table.insert(lines, "\\usetikzlibrary{" .. table.concat(libraries, ",") .. "}")
  table.insert(lines, "\\begin{document}")

  -- allow bare content: wrap in tikzpicture if user omitted it
  if not body:match("\\begin%s*{tikzpicture}") then
    body = "\\begin{tikzpicture}\n" .. body .. "\n\\end{tikzpicture}"
  end

  if opts.scale then
    body = "\\scalebox{" .. opts.scale .. "}{" .. body .. "}"
  end

  table.insert(lines, body)
  table.insert(lines, "\\end{document}")
  return table.concat(lines, "\n")
end

-- ---------------------------------------------------------------------------
-- compilation
-- ---------------------------------------------------------------------------

local function run(cmd)
  local ok = os.execute(cmd)
  -- os.execute returns true/nil (Lua 5.3+) — normalize
  return ok == true or ok == 0
end

local function compile_svg(tex_source, name)
  ensure_dir(CACHE_DIR)
  local svg_path = CACHE_DIR .. "/" .. name .. ".svg"
  local hash_path = CACHE_DIR .. "/" .. name .. ".sha1"
  local hash = sha1(tex_source)

  -- cache hit: svg present AND built from identical tex source — a bare
  -- filename match would go stale when options (e.g. mainfont) change
  if file_exists(svg_path) and file_exists(hash_path)
      and read_file(hash_path) == hash then
    return read_file(svg_path)
  end

  local svg_content = system.with_temporary_directory("tikz", function(tmp)
    local tex_path = tmp .. "/diagram.tex"
    write_file(tex_path, tex_source)

    local latex_ok = run(
      string.format(
        'lualatex -interaction=nonstopmode -halt-on-error -output-directory="%s" "%s" > "%s/latex.log" 2>&1',
        tmp, tex_path, tmp))
    if not latex_ok then
      local log = file_exists(tmp .. "/diagram.log")
          and read_file(tmp .. "/diagram.log") or "no log"
      error("TikZ: lualatex compilation failed.\n" ..
        log:match("(!.-)\n%s*\n") or log:sub(-2000))
    end

    -- lualatex emits PDF; dvisvgm reads it with --pdf. --no-fonts embeds glyphs
    -- as paths so CJK renders without shipping font files.
    local dvisvgm_ok = run(
      string.format(
        'dvisvgm --pdf --no-fonts --exact-bbox --optimize=all -o "%s/diagram.svg" "%s/diagram.pdf" > /dev/null 2>&1',
        tmp, tmp))
    if not dvisvgm_ok then
      error("TikZ: dvisvgm conversion failed")
    end

    return read_file(tmp .. "/diagram.svg")
  end)

  write_file(svg_path, svg_content)
  write_file(hash_path, hash)
  return svg_content
end

-- dvisvgm emits ids (shared glyph paths, clip paths) that are unique per
-- FILE, not per PAGE: inlining several svgs into one HTML document makes a
-- later <use href='#g...'> resolve to the first matching id in the document,
-- i.e. a glyph from another diagram at a different font/size. Prefix every
-- id and reference with the diagram's cache name to keep them disjoint.
local function namespace_ids(svg, prefix)
  svg = svg:gsub("(%sid=')([^']+)'", "%1" .. prefix .. "-%2'")
  svg = svg:gsub('(%sid=")([^"]+)"', "%1" .. prefix .. '-%2"')
  svg = svg:gsub("(href='#)([^']+)'", "%1" .. prefix .. "-%2'")
  svg = svg:gsub('(href="#)([^"]+)"', "%1" .. prefix .. '-%2"')
  svg = svg:gsub("(url%(#)([^%)]+)%)", "%1" .. prefix .. "-%2)")
  return svg
end

-- strip XML prolog so the SVG can be inlined into HTML
local function inline_svg(svg, opts, name)
  svg = svg:gsub("<%?xml.-%?>%s*", ""):gsub("<!DOCTYPE.-%>%s*", "")
  svg = namespace_ids(svg, name)
  if opts.width then
    -- force responsive sizing; escape % so gsub treats the replacement literally
    local replacement = string.format('<svg style="width:%s;height:auto;" ', opts.width)
    replacement = replacement:gsub("%%", "%%%%")
    svg = svg:gsub("<svg ", replacement, 1)
  end
  return svg
end

-- ---------------------------------------------------------------------------
-- filter
-- ---------------------------------------------------------------------------

local function is_tikz_block(el)
  return el.classes:includes("tikz")
      or (el.attr and el.attr.classes:includes("{tikz}"))
end

-- collect document-level defaults from the `tikz` metadata key
local function Meta(meta)
  local t = meta.tikz
  if type(t) ~= "table" then return nil end
  if t.mainfont then doc_defaults.mainfont = utils.stringify(t.mainfont) end
  doc_defaults.packages = to_string_list(t.packages)
  doc_defaults.libraries = to_string_list(t.libraries)
  return nil
end

local function CodeBlock(el)
  if not is_tikz_block(el) then return nil end

  local opts, body = parse_options(el.text)
  -- attributes set via ```{.tikz key=value} also work
  for k, v in pairs(el.attributes) do
    if opts[k] == nil then opts[k] = v end
  end

  -- LaTeX output: pass through natively
  if quarto.doc.is_format("latex") then
    quarto.doc.use_latex_package("tikz")
    local out = body
    if not out:match("\\begin%s*{tikzpicture}") then
      out = "\\begin{tikzpicture}\n" .. out .. "\n\\end{tikzpicture}"
    end
    return pandoc.RawBlock("latex", out)
  end

  -- HTML / Revealjs: compile to SVG
  local tex = build_tex(body, opts)
  local name = opts.filename or ("tikz-" .. sha1(tex):sub(1, 12))

  local ok, result = pcall(compile_svg, tex, name)
  if not ok then
    quarto.log.error(result)
    return pandoc.CodeBlock("TikZ compilation error:\n" .. tostring(result))
  end

  local svg = inline_svg(result, opts, name)
  local html

  if opts.caption then
    html = string.format(
      '<figure class="tikz-figure">%s<figcaption>%s</figcaption></figure>',
      svg, opts.caption)
  else
    html = '<div class="tikz-figure">' .. svg .. "</div>"
  end

  return pandoc.RawBlock("html", html)
end

-- two passes: Meta first so document-level defaults are visible to CodeBlock
-- (within a single filter pandoc visits blocks before metadata)
return {
  { Meta = Meta },
  { CodeBlock = CodeBlock },
}
