-- dates.lua  ───  minimal, robust placeholder replacement --------------------
local dates = {}

-- Read schedule.csv exactly once, as soon as the script is loaded
for line in io.lines("schedule.csv") do
  local n, d = line:match("^(%d+),%s*([%d%-/]+)")
  if n then dates[n] = d end          -- skip the header row automatically
end

-- Helper: swap %%M<n>%% → date
local function swap(text)
  return text:gsub("%%%%M(%d+)%%%%", function(n) return dates[n] or ("M"..n) end)
end

-- Replace inside headings
function Header(h)
  local new = swap(pandoc.utils.stringify(h))      -- stringify joins the inline list :contentReference[oaicite:2]{index=2}
  if new ~= pandoc.utils.stringify(h) then
    return pandoc.Header(h.level, new, h.attr)
  end
end

-- …and inside normal paragraphs/blocks so you’re covered everywhere
function Para(p)
  for i, inl in ipairs(p.content) do
    if inl.t == "Str" then
      p.content[i] = pandoc.Str(swap(inl.text))
    end
  end
  return p
end
-----------------------------------------------------------------------
