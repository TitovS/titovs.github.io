-- Read the site's YAML directly inside LuaLaTeX. No generated TeX intermediates.
local yaml = dofile("cv/vendor/tinyyaml.lua")
local lfs = require("lfs")
local M = {}

local function fail(message)
  error("CV: " .. message, 0)
end

local function clean_nulls(value)
  if tostring(value) == "yaml.null" then return nil end
  if type(value) ~= "table" then return value end
  local result = {}
  for key, item in pairs(value) do result[key] = clean_nulls(item) end
  return result
end

function M.read_yaml(path, front_matter)
  local file, err = io.open(path, "r")
  if not file then fail(err) end
  local source = file:read("*a"):gsub("\r\n", "\n")
  file:close()
  if front_matter then
    source = source:match("^%-%-%-[ \t]*\n(.-)\n%-%-%-[ \t]*\n")
      or source:match("^%-%-%-[ \t]*\n(.-)\n%-%-%-[ \t]*$")
    if not source then fail(path .. ": missing YAML front matter") end
  end
  local ok, data = pcall(yaml.parse, source, {timestamps = false})
  if not ok then fail(path .. ": " .. tostring(data)) end
  if type(data) ~= "table" then fail(path .. ": expected YAML mapping") end
  return clean_nulls(data)
end

local function scalar(value)
  if value == nil then return "" end
  if type(value) ~= "string" and type(value) ~= "number" then
    fail("expected text, got " .. type(value))
  end
  return tostring(value)
end

local function nonempty(value)
  return value ~= nil and scalar(value):match("%S") ~= nil
end

local function keys_allowed(data, allowed, context)
  if type(data) ~= "table" then fail(context .. ": expected a mapping") end
  for key in pairs(data) do
    if not allowed[key] then fail(context .. ": unknown field " .. tostring(key)) end
  end
end

local function list(value, context)
  if type(value) ~= "table" then fail(context .. ": expected a list") end
  local count = 0
  for key in pairs(value) do
    count = count + 1
    if type(key) ~= "number" or key < 1 or key % 1 ~= 0 then
      fail(context .. ": expected a list")
    end
  end
  if count ~= #value then fail(context .. ": expected a continuous list") end
  return value
end

local function collection(root, directory)
  local entries = {}
  for filename in lfs.dir(root .. "/" .. directory) do
    local id = filename:match("^(.*)%.md$")
    if id then entries[id] = M.read_yaml(root .. "/" .. directory .. "/" .. filename, true) end
  end
  return entries
end

local function apply_overrides(entries, overrides, allowed, context)
  keys_allowed(overrides, entries, context)
  for id, fields in pairs(overrides) do
    keys_allowed(fields, allowed, context .. "." .. id)
    for key, value in pairs(fields) do entries[id][key] = value end
  end
end

local function select_entries(entries, selection, context, date_key)
  local ids = {}
  if selection == nil or selection == "all" then
    for id in pairs(entries) do ids[#ids + 1] = id end
    table.sort(ids, function(a, b)
      local da, db = scalar(entries[a][date_key]), scalar(entries[b][date_key])
      if da == db then return a < b end
      return da > db
    end)
  else
    ids = list(selection, context)
  end
  local result, seen = {}, {}
  for _, id in ipairs(ids) do
    if type(id) ~= "string" or not entries[id] then
      fail(context .. ": unknown entry " .. tostring(id))
    end
    if seen[id] then fail(context .. ": duplicate entry " .. id) end
    seen[id] = true
    result[#result + 1] = entries[id]
  end
  return result
end

-- Strip the presentation markup already used in publication metadata and role
-- summaries. CV-only overrides should use plain text and YAML highlight lists.
function M.plain(value)
  local text = scalar(value)
  local tags = {a = true, b = true, i = true, em = true, strong = true, span = true, p = true, br = true}
  text = text:gsub("</?([%a]+)[^>]*>", function(tag)
    tag = tag:lower()
    if tag == "br" or tag == "p" then return " " end
    if tags[tag] then return "" end
    return nil -- Keep text in angle brackets that is not known HTML markup.
  end)
    :gsub("%[([^%]]+)%]%([^%)]+%)", "%1")
    :gsub("%*%*(.-)%*%*", "%1")
    :gsub("__(.-)__", "%1")
    :gsub("%*([^*]+)%*", "%1")
    :gsub("`([^`]+)`", "%1")
  local entities = {amp = "&", lt = "<", gt = ">", quot = '"', apos = "'", nbsp = " "}
  text = text:gsub("&(#?[%w]+);", function(entity)
    if entities[entity] then return entities[entity] end
    local hex = entity:match("^#x(%x+)$")
    local code = tonumber(entity:match("^#(%d+)$")) or (hex and tonumber(hex, 16))
    if code and code > 0 and code <= 0x10ffff and not (code >= 0xd800 and code <= 0xdfff) then
      return utf8.char(code)
    end
    return "&" .. entity .. ";"
  end)
  -- The source decorates award names with trophy emoji; use the actual text.
  return (text:gsub("🏆", ""):gsub("%s+", " "):gsub("^%s+", ""):gsub("%s+$", ""))
end

local escapes = {
  ["\\"] = "\\textbackslash{}", ["{"] = "\\{", ["}"] = "\\}",
  ["#"] = "\\#", ["$"] = "\\$", ["%"] = "\\%", ["&"] = "\\&", ["_"] = "\\_",
  ["^"] = "\\textasciicircum{}", ["~"] = "\\textasciitilde{}",
}
function M.escape(value)
  return (M.plain(value):gsub("[\\{}#$%%&_^~]", escapes))
end

local function link(url, label)
  if not nonempty(url) then return M.escape(label) end
  url = scalar(url)
  if not url:match("^https?://") and not url:match("^mailto:") then
    fail("unsupported link: " .. url)
  end
  url = url:gsub("[\\{}^~%s]", function(char) return string.format("%%%02X", char:byte()) end)
    :gsub("[#$%%&_ ]", function(char) return "\\" .. char end)
  return "\\href{" .. url .. "}{" .. M.escape(label) .. "}"
end

local months = {"Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"}
function M.date(value)
  local text = scalar(value)
  if text == "" or text:match("^%d%d%d%d$") then return text end
  local year, month = text:match("^(%d%d%d%d)%-(%d%d)$")
  local day
  if not year then year, month, day = text:match("^(%d%d%d%d)%-(%d%d)%-(%d%d)$") end
  if not year or not months[tonumber(month)] or (day and (tonumber(day) < 1 or tonumber(day) > 31)) then
    fail("invalid date " .. text .. "; use YYYY, YYYY-MM, or YYYY-MM-DD")
  end
  return (day and (tonumber(day) .. " ") or "") .. months[tonumber(month)] .. " " .. year
end

local function period(entry)
  if nonempty(entry.date_start) then
    return M.date(entry.date_start) .. " – " .. (nonempty(entry.date_finish) and M.date(entry.date_finish) or "Present")
  end
  if nonempty(entry.date_finish) then return "Until " .. M.date(entry.date_finish) end
  return entry.date_note or "Dates not specified"
end

local sections = {
  summary = "Profile", experience = "Experience", education = "Education",
  teaching = "Teaching", awards = "Awards", publications = "Publications",
}
local profile_keys = {name = true, location = true, email = true, website = true, github = true, linkedin = true}

function M.load(root, options)
  local config = options or M.read_yaml(root .. "/_data/cv.yml")
  keys_allowed(config, {
    sections = true, summary = true, profile = true, experience = true, education = true,
    teaching = true, awards = true, publications = true,
    experience_overrides = true, publication_overrides = true,
  }, "_data/cv.yml")
  local site = M.read_yaml(root .. "/_config.yml")
  local author = site.author or {}
  local profile = {
    name = author.name, location = author.location, email = author.email,
    website = site.url, github = author.github, linkedin = author.linkedin,
  }
  keys_allowed(config.profile or {}, profile_keys, "profile")
  for key, value in pairs(config.profile or {}) do profile[key] = value end
  if not nonempty(profile.name) then fail("profile.name must not be empty") end

  local roles = collection(root, "_work_experience")
  local papers = collection(root, "_publications")
  apply_overrides(roles, config.experience_overrides or {}, {
    title = true, company = true, team = true, location = true, date_start = true,
    date_finish = true, date_note = true, short_description = true, highlights = true,
  }, "experience_overrides")
  apply_overrides(papers, config.publication_overrides or {}, {
    title = true, authors = true, venue = true, date = true, status = true,
    paperurl = true, award = true,
  }, "publication_overrides")
  local awards = {}
  for id, paper in pairs(papers) do
    if nonempty(paper.award) then awards[id] = paper end
  end
  local order = list(config.sections or {"summary", "experience", "education", "teaching", "awards", "publications"}, "sections")
  local seen = {}
  for _, name in ipairs(order) do
    if not sections[name] then fail("unknown section " .. tostring(name)) end
    if seen[name] then fail("duplicate section " .. name) end
    seen[name] = true
  end
  return {
    profile = profile, sections = order, summary = config.summary or "",
    experience = select_entries(roles, config.experience, "experience", "date_start"),
    education = select_entries(M.read_yaml(root .. "/_data/education.yml"), config.education, "education", "date_finish"),
    teaching = select_entries(M.read_yaml(root .. "/_data/teaching.yml"), config.teaching, "teaching", "period"),
    awards = select_entries(awards, config.awards, "awards", "date"),
    publications = select_entries(papers, config.publications, "publications", "date"),
  }
end

function M.to_tex(model)
  local lines = {}
  local function emit(line) lines[#lines + 1] = line end
  local esc = M.escape
  local function entry(title, dates, subtitle)
    emit("\\cventry{" .. title .. "}{" .. esc(dates) .. "}{" .. subtitle .. "}")
  end
  local profile, contacts = model.profile, {}
  if nonempty(profile.location) then contacts[#contacts + 1] = esc(profile.location) end
  if nonempty(profile.email) then
    local email = profile.email:gsub("%[at%]", "@")
    contacts[#contacts + 1] = link("mailto:" .. email, email)
  end
  if nonempty(profile.website) then
    contacts[#contacts + 1] = link(profile.website, profile.website:gsub("^https?://", ""))
  end
  if nonempty(profile.github) then contacts[#contacts + 1] = link("https://github.com/" .. profile.github, "GitHub") end
  if nonempty(profile.linkedin) then contacts[#contacts + 1] = link("https://www.linkedin.com/in/" .. profile.linkedin, "LinkedIn") end
  emit("\\hypersetup{pdftitle={" .. esc(profile.name) .. " — CV},pdfauthor={" .. esc(profile.name) .. "}}")
  emit("{\\Huge\\bfseries " .. esc(profile.name) .. "}\\par")
  emit("{\\small " .. table.concat(contacts, " \\enspace\\textperiodcentered\\enspace ") .. "}\\par")

  local renderers = {}
  function renderers.summary()
    emit(esc(model.summary) .. "\\par")
  end
  function renderers.experience()
    for _, role in ipairs(model.experience) do
      local subtitle = {}
      for _, field in ipairs({"company", "team", "location"}) do
        if nonempty(role[field]) then subtitle[#subtitle + 1] = esc(role[field]) end
      end
      entry(esc(role.title), period(role), table.concat(subtitle, " · "))
      if nonempty(role.short_description) then emit(esc(role.short_description) .. "\\par") end
      if role.highlights then
        local highlights = list(role.highlights, "experience highlights")
        if #highlights > 0 then
          emit("\\begin{itemize}")
          for _, text in ipairs(highlights) do emit("\\item " .. esc(text)) end
          emit("\\end{itemize}")
        end
      end
    end
  end
  function renderers.education()
    for _, education in ipairs(model.education) do
      local title = education.degree .. " in " .. education.subject
      if education.completed == false then title = title .. " (not completed)" end
      local dates = nonempty(education.date_start) and period(education) or M.date(education.date_finish)
      entry(esc(title), dates, link(education.url, education.institution))
      if nonempty(education.focus) then emit(esc("Focus: " .. education.focus .. ".") .. "\\par") end
    end
  end
  function renderers.teaching()
    for _, teaching in ipairs(model.teaching) do
      entry(esc(teaching.role .. ": " .. teaching.course), teaching.period, link(teaching.url, teaching.institution))
    end
  end
  function renderers.awards()
    for _, paper in ipairs(model.awards) do
      entry(esc(paper.award), scalar(paper.date):sub(1, 4), link(paper.paperurl, paper.title))
    end
  end
  function renderers.publications()
    for _, paper in ipairs(model.publications) do
      local status = ({accepted = "Accepted", preprint = "Preprint", published = ""})[paper.status]
      if not status then fail("unknown publication status " .. tostring(paper.status)) end
      local venue = esc(paper.venue)
      if status ~= "" then venue = venue .. "; " .. status end
      entry(link(paper.paperurl, paper.title), scalar(paper.date):sub(1, 4), esc(paper.authors))
      emit(venue .. ".\\par")
    end
  end
  for _, name in ipairs(model.sections) do
    local present = name == "summary" and nonempty(model.summary) or (name ~= "summary" and #model[name] > 0)
    if present then
      emit("\\cvsection{" .. sections[name] .. "}")
      renderers[name]()
    end
  end
  return table.concat(lines, "\n")
end

function M.render(root)
  -- tex.print treats embedded newlines as characters, not separate input lines.
  for line in M.to_tex(M.load(root)):gmatch("[^\n]+") do tex.print(line) end
end

return M
