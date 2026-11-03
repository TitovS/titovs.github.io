# CV from the website's content

LuaLaTeX reads YAML **during compilation**. There is no Python/Pandoc conversion,
generated LaTeX source, shell escape, or network access during compilation.

From the repository root, with TeX Live or MacTeX installed:

```sh
latexmk -g -lualatex -halt-on-error -interaction=nonstopmode -outdir=cv/build main.tex
```

Open `cv/build/main.pdf`. `-g` forces a fresh pass so newly added collection files
are picked up as well as edits to existing ones. The compiler needs `fontspec`, `geometry`, `xcolor`,
`hyperref`, `needspace`, `enumitem`, and the Latin Modern fonts. On Debian/Ubuntu,
install `latexmk texlive-luatex texlive-latex-extra texlive-fonts-recommended`.
Run the content checks with `texlua cv/tests/check.lua`.

## Shared content

| Source | Used for |
| --- | --- |
| `_config.yml` → `author`, `url` | Name and contact details |
| `_work_experience/*.md` YAML front matter | Roles, dates, short descriptions |
| `_publications/*.md` YAML front matter | Publication entries and awards |
| `_data/education.yml` | Education in the PDF and homepage |
| `_data/teaching.yml` | Teaching in the PDF and academic-work page |
| `_data/cv.yml` | PDF-only profile, summary, selections, and wording overrides |

The long Markdown bodies of experience entries remain website content; the PDF
uses `short_description` and optional CV-only `highlights`. Existing inline HTML
in publications and basic Markdown links/bold/code in summaries are reduced to
plain text. New CV overrides should use plain text and YAML lists, not LaTeX or
HTML. TeX special characters are escaped automatically. Unicode is supported by
LuaLaTeX; additional scripts may require a different font in `cv/main.tex`.

Dates retain their known precision. Blank role end dates mean Present only when
a start date exists; otherwise `date_note` or “Dates not specified” is printed.
Accepted papers and preprints are labeled. All publications, including future
dates, are included by default, matching the site's `future: true` setting. Use
an explicit selection to omit workshop/full-paper duplicates or future entries.
Conference attendance and miscellaneous service are not included in this initial
template; the academic-work page continues to show them.

The bundled parser supports a YAML subset. Use ordinary mappings, sequences,
quoted strings, booleans, and `>` / `|` block text. Write Unicode characters
directly. Avoid anchors, aliases, custom tags, merge keys, and `\u`/`\x` escapes
in CV content. Keep dates quoted. `_config.yml`'s existing top-level anchors are
not used by the CV; it reads the literal values in `author` and `url`.

## One branch per application

Create a branch such as `cv/company-name` and edit `_data/cv.yml` there. For example:

```yaml
sections:
  - summary
  - experience
  - education
  - publications

summary: >-
  Research lead focused on machine learning for developer tools.

experience:
  - multi-task-learning-team-lead
  - code-modeling-team-lead
  - fintech-data-scientist

publications:
  - 2025-04-29-pandasplotbench
  - 2022-05-18-jupyter-analysis

experience_overrides:
  code-modeling-team-lead:
    short_description: "Led seven researchers working on code generation."
    highlights:
      - "Managed colleagues and mentored students."
```

These IDs are source filenames without `.md`. Education and teaching IDs are
keys in their YAML files; award IDs are publication filenames. Selections accept
`all` (newest first), `[]` (none), or a list (exact order). Omitted selections
default to `all`; `sections` controls which sections appear and their order.
Unknown/duplicate IDs, sections, and override fields fail the build.

`profile` can override `name`, `location`, `email`, `website`, `github`, and
`linkedin`. Set a field to `""` to hide it; GitHub/LinkedIn values are usernames.
`experience_overrides` supports `title`, `company`, `team`, `location`,
`date_start`, `date_finish`, `date_note`, `short_description`, and `highlights`.
`publication_overrides` supports `title`, `authors`, `venue`, `date`, `status`,
`paperurl`, and `award`. Overrides affect the PDF only. Shared facts can still be
merged from the main branch; resolve any `_data/cv.yml` conflicts deliberately.

GitHub Actions compiles the checked-out branch on relevant pushes and pull
requests, or manually via **Actions → Build CV → Run workflow**. Download the
`cv-<commit>` artifact from the completed run. Artifacts expire after 14 days;
download a copy or rerun the workflow later. The workflow does not commit PDFs,
change GitHub Pages settings, or deploy application branches. Keep Pages pointed
at your existing website branch. A public repository's branches are public too.

## Overleaf

For a first trial, upload a ZIP of the desired branch to a new Overleaf project.
Keep the repository directory structure, including root `main.tex`, `_config.yml`, `_data/`,
`_work_experience/`, `_publications/`, and `cv/` (including `vendor/`). Set:

- **Main document:** `main.tex` at the project root
- **Compiler:** LuaLaTeX

Then edit `_data/cv.yml` and click Recompile. YAML is edited as source text; the
PDF preview updates directly. Edit `cv/main.tex` for layout changes. No conversion
script or generated content needs to be synchronized.

The root `main.tex` loads the layout in `cv/main.tex`. Compile the root file to
keep the Lua and YAML paths relative to the repository root. Do not upload only
the `cv/` directory, flatten the folders, or move the layout to the project root.
The project should contain:

```text
main.tex
_config.yml
_data/
_work_experience/
_publications/
cv/
  main.tex
  content.lua
  vendor/
    tinyyaml.lua
```

If the log says `cannot open cv/content.lua`, confirm that this file exists under
`cv/`, pull the latest GitHub changes using **Integrations → GitHub**, and select
the root `main.tex` before recompiling. A project containing only the LaTeX layout
is missing the data and Lua modules needed to build the CV.

For ongoing synchronization, use Overleaf's GitHub/Git integration if available
on your plan. Synchronization and branch support depend on that integration;
do not assume one Overleaf project tracks your local active branch. Use a
separate project per application version and verify its source branch before
syncing. A ZIP upload is a snapshot and does not establish synchronization.
