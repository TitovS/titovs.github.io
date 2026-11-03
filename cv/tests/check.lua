-- Run from the repository root with: texlua cv/tests/check.lua
local cv = dofile("cv/content.lua")
local checks = 0
local function check(condition, message)
  assert(condition, message)
  checks = checks + 1
end
local function rejects(callback, expected)
  local ok, err = pcall(callback)
  check(not ok and tostring(err):find(expected, 1, true), "Expected error containing: " .. expected .. "; got " .. tostring(err))
end

-- Exercise the renderer independently of this branch's CV selections/overrides.
local model = cv.load(".", {})
local lfs = require("lfs")
local function file_count(directory)
  local count = 0
  for name in lfs.dir(directory) do
    if name:match("%.md$") then count = count + 1 end
  end
  return count
end
check(#model.experience == file_count("_work_experience"), "All existing roles are included")
check(#model.publications == file_count("_publications"), "All existing publications are included")
check(#model.education > 0 and #model.teaching > 0, "Shared academic content is loaded")
check(model.education[1].completed == false, "Incomplete PhD status is preserved")
local output = cv.to_tex(model)
check(output:find("PhD in Philosophy (not completed)", 1, true), "The PDF must not claim a completed PhD")
check(output:find("Țerna", 1, true), "Unicode author names survive")
check(output:find("sergey.titov@jetbrains.com", 1, true), "Obfuscated source email becomes a usable PDF contact")
check(not output:find("<i>", 1, true) and not output:find("<b>", 1, true), "Publication HTML is stripped")
check(output:find("Accepted", 1, true) and output:find("Preprint", 1, true), "Publication statuses survive")
check(not output:find("🏆", 1, true), "Decorative emoji does not require an emoji font")

local options = {}
options.sections = {"experience", "publications"}
options.experience = {"fintech-data-scientist", "code-modeling-team-lead"}
options.publications = {"2025-04-29-pandasplotbench"}
options.profile = {name = "Branch & Co", email = "", location = ""}
options.experience_overrides = {
  ["code-modeling-team-lead"] = {
    short_description = "R&D: 20% growth, C_1 costs $5 #1 {safe} \\input{secret}",
    highlights = {"Led seven researchers.", "A ~ B ^ C"},
  },
}
local tailored = cv.load(".", options)
check(#tailored.experience == 2 and tailored.experience[1].company == "DevExperts (dxFeed)", "Selection preserves explicit order")
check(#tailored.publications == 1, "Branch selection filters publications")
local tailored_tex = cv.to_tex(tailored)
check(tailored_tex:find("R\\&D: 20\\% growth, C\\_1 costs \\$5 \\#1 \\{safe\\}", 1, true), "LaTeX special characters are escaped")
check(tailored_tex:find("\\textbackslash{}input\\{secret\\}", 1, true), "YAML text cannot inject LaTeX commands")
check(not tailored_tex:find("\\cvsection{Education}", 1, true), "Omitted sections are not rendered")
check(not tailored_tex:find("mailto:", 1, true), "Empty profile overrides suppress contacts")
check(not cv.to_tex(cv.load(".", {})):find("20\\% growth", 1, true), "Overrides do not mutate source content")

check(cv.plain("<b>A &amp; B</b> with [links](https://example.com) and **bold**") == "A & B with links and bold", "Existing inline markup converts to text")
check(cv.plain("&#x021A; &#38; &unknown;") == "Ț & &unknown;", "Entities decode without damaging unknown entities")
check(cv.plain("A < B > C and <model>") == "A < B > C and <model>", "Plain text in angle brackets is preserved")
check(cv.date("2020") == "2020" and cv.date("2020-09") == "Sep 2020" and cv.date("2020-09-03") == "3 Sep 2020", "Date precision is preserved")
rejects(function() cv.date("2020-19") end, "invalid date")
options.experience = {"missing-role"}
rejects(function() cv.load(".", options) end, "unknown entry missing-role")
options.experience = {"fintech-data-scientist", "fintech-data-scientist"}
rejects(function() cv.load(".", options) end, "duplicate entry")
options.experience = {}
options.publications = {}
check(not cv.to_tex(cv.load(".", options)):find("\\cvsection", 1, true), "Empty selections omit headings")
options.sections = {"typo"}
rejects(function() cv.load(".", options) end, "unknown section typo")
options.sections = {}
options.experience_overrides = {typo = {short_description = "text"}}
rejects(function() cv.load(".", options) end, "unknown field typo")
options.experience_overrides = { ["fintech-data-scientist"] = {description = "typo"} }
rejects(function() cv.load(".", options) end, "unknown field description")
options.experience_overrides = {}
options.publication = "all"
rejects(function() cv.load(".", options) end, "unknown field publication")

-- Finally validate this branch's actual selections and overrides as well.
check(#cv.to_tex(cv.load(".")) > 0, "This branch's CV configuration renders")
print(string.format("Passed %d CV checks.", checks))
