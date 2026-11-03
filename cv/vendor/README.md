`tinyyaml.lua` is vendored unmodified from
[api7/lua-tinyyaml](https://github.com/api7/lua-tinyyaml), commit
`197632c5aca09321ed89ed975613e7c16c7aaa00`, under the accompanying MIT license.

It is a pure Lua YAML **subset** parser; no network access or external program
is needed during compilation. Use ordinary mappings, sequences, quoted strings,
booleans, and `>` / `|` block strings. Use literal Unicode rather than YAML
Unicode escapes; avoid YAML anchors, aliases, custom tags, and merge keys in CV
data. Dates are read as strings. See `cv/tests/check.lua` for integration checks
against the site's actual content.
