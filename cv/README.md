# HTML CV and browser PDF export

Open the **CV** tab at `/cv/`, then click **Save as PDF**. In the browser print
dialog, choose **Save as PDF**, paper **A4**, scale **100%**, and turn off
**Headers and footers**. The print stylesheet defines page margins, hides the
toolbar, and keeps entries together where they fit. Links remain clickable in
the PDF. Chrome/Edge provide the most predictable pagination; exact page breaks
can differ between browsers.

The CV is rendered by the site's existing Jekyll build. There is no LaTeX,
Overleaf integration, or separate content conversion step.

## Local preview

Use the site's normal `bundle exec jekyll serve` command and open
`http://localhost:4000/cv/`. Or build once with `bundle exec jekyll build` and open
`_site/cv/index.html` directly in your browser. The HTML embeds its styles and
print button, uses system fonts, and needs no server or network connection to
display or print. You can rename it to `sergey-titov-cv.html` and share it.

## Content and layout

The CV opens with **Profile**, followed by the detailed sections. Edit `summary`
in `_data/cv.yml` for your profile statement. Each position starts with two or
three highlights, followed by its description. Highlights and descriptions use
the same body size and line spacing, with space between them; dates and other
metadata use one smaller size. Bullet markers sit inside the content column,
with a small indent for the list text and its wrapped lines.
Edit these bullets in the `highlights` list in each `_work_experience/*.md`
file's front matter; use `[]` or omit the field for a role without highlights.
Section labels sit in a narrow left column on desktop
and in print, and above the content on mobile.

| Source | Used for |
| --- | --- |
| `_config.yml` → `author`, `url` | Default name and contact details |
| `_work_experience/*.md` front matter | Roles, dates, short descriptions, highlights |
| `_publications/*.md` front matter | Publications and awards |
| `_data/education.yml` | Education in the CV and homepage |
| `_data/teaching.yml` | Teaching in the CV and academic-work page |
| `_data/cv.yml` | CV-only summary, selections, and wording overrides |
| `_layouts/cv.html`, `_includes/cv/` | CV markup and screen/print styles |

The default CV uses the full Markdown bodies from the work-experience files,
including their paper links. Set `experience_detail: summary` in `_data/cv.yml`
for a shorter version using `short_description`. Roles without a body fall back
to their summary. Both modes support optional `highlights`. Publication titles, authors, and venues
use plain text, removing existing presentation tags from the site's metadata.

Dates retain their known precision. A missing end date means Present when a
start date exists; otherwise the CV uses `date_note` or “Dates not specified”.
The default CV includes the completed degrees and five selected papers. Accepted
papers and preprints are labeled. Explicit selections can include future dates,
matching the site's current configuration; use `publications: all` for the full list.
Conference attendance and miscellaneous service remain on the academic-work
page and are not included in this template.

Optional thesis details go under the relevant degree in `_data/education.yml`:

```yaml
thesis:
  title: "Your thesis title"
  description: >-
    A short description of the research question, methods, and findings.
  url: "https://example.com/thesis"
  supervisor: "Supervisor name"
```

Only `title` is required; omit the other fields if not needed. The description
supports Markdown. No thesis block is shown until a title is supplied.
Thesis titles also appear in an expandable list in the homepage education summary.

The CV's `teaching` selection currently includes only the two Introduction to
Statistics courses. Other teaching entries remain available in the shared data.

Edit `skills` in `_data/cv.yml` as category/text pairs, for example:

```yaml
skills:
  Programming: "Python, R, C++"
  Software: "MATLAB, SPSS, Tableau"
  Languages: "English (IELTS 7.0)"
```

Category order is preserved. Use `skills: {}` or remove `skills` from `sections`
to omit the section. The initial list comes from the previous CV.

## One branch per application

Edit `_data/cv.yml` on a branch such as `cv/company-name`:

```yaml
sections:
  - summary
  - experience
  - education
  - publications

summary: >-
  Research lead focused on machine learning for developer tools.

experience:
  - jetbrains-team-lead
  - jetbrains-researcher
  - dxfeed-data-scientist

publications:
  - 2025-04-29-pandasplotbench
  - 2022-05-18-jupyter-analysis

experience_overrides:
  jetbrains-team-lead:
    short_description: "Led seven researchers working on code generation."
    highlights:
      - "Managed colleagues and mentored students."
```

IDs are filenames without `.md` for experience/publications, keys in the shared
YAML for education/teaching, and publication IDs for awards. Selections accept
`all` (source dates, newest first), `[]` (none), or a list (exact order). Omitted
selections default to `all`; `sections` controls which sections appear and their
order. Empty sections have no heading.

`profile` can override `name`, `location`, `email`, `website`, `github`, and
`linkedin`. Set a field to `""` to hide it; GitHub/LinkedIn values are usernames.
`experience_overrides` supports `title`, `company`, `team`, `location`,
`date_start`, `date_finish`, `date_note`, `short_description`, `description`, and
`highlights`. `description` overrides the full body only in the CV; it does not
change the source role page. Use `short_description` for summary mode.
`publication_overrides` supports `title`, `authors`, `venue`, `date`, `status`,
`paperurl`, and `award`. Overrides affect only the CV page and printed PDF.
Explicit lists preserve your preferred order even if you override dates.

After pushing, open **Actions → Build CV preview**, select the run for your
branch, and download `cv-<commit>`. Unzip it and open `index.html`, then print.
The workflow builds an HTML artifact; it does not deploy branches or commit PDFs.
Artifacts expire after 14 days; download a copy or rerun the workflow later.
The website's existing deployment still determines what appears at `/cv/`.

Validate configuration and a rendered preview with:

```sh
bundle exec ruby cv/check.rb
bundle exec jekyll build
bundle exec ruby cv/check.rb _site/cv/index.html
bundle exec ruby cv/tests/render.rb
```

The checks reject unknown/duplicate IDs, unsupported override fields, and invalid
selections. Rendering also displays a visible error for missing selected entries
so a typo does not silently remove experience from the CV.
