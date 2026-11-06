A Github Pages template for academic websites. This was forked (then detached) by [Stuart Geiger](https://github.com/staeiou) from the [Minimal Mistakes Jekyll Theme](https://mmistakes.github.io/minimal-mistakes/), which is © 2016 Michael Rose and released under the MIT License. See LICENSE.md.

I think I've got things running smoothly and fixed some major bugs, but feel free to file issues or make pull requests if you want to improve the generic template / theme.

### Note: if you are using this repo and now get a notification about a security vulnerability, delete the Gemfile.lock file. 

# Instructions

1. Register a GitHub account if you don't have one and confirm your e-mail (required!)
1. Fork [this repository](https://github.com/academicpages/academicpages.github.io) by clicking the "fork" button in the top right. 
1. Go to the repository's settings (rightmost item in the tabs that start with "Code", should be below "Unwatch"). Rename the repository "[your GitHub username].github.io", which will also be your website's URL.
1. Set site-wide configuration and create content & metadata (see below -- also see [this set of diffs](http://archive.is/3TPas) showing what files were changed to set up [an example site](https://getorg-testacct.github.io) for a user with the username "getorg-testacct")
1. Upload any files (like PDFs, .zip files, etc.) to the files/ directory. They will appear at https://[your GitHub username].github.io/files/example.pdf.  
1. Check status by going to the repository settings, in the "GitHub pages" section
1. (Optional) Use the Jupyter notebooks or python scripts in the `markdown_generator` folder to generate markdown files for publications and talks from a TSV file.

See more info at https://academicpages.github.io/

## To run locally (not on GitHub Pages, to serve on your own computer)

1. Clone the repository and made updates as detailed above
1. Make sure you have ruby-dev, bundler, and nodejs installed: `sudo apt install ruby-dev ruby-bundler nodejs`
1. Run `bundle clean` to clean up the directory (no need to run `--force`)
1. Run `bundle install` to install ruby dependencies. If you get errors, delete Gemfile.lock and try again.
1. Run `bundle exec jekyll liveserve` to generate the HTML and serve it from `localhost:4000` the local server will automatically rebuild and refresh the pages on change.

## Adding work experience

The **Work experience** tab lists Markdown files from `_work_experience/`, just as publications are stored in `_publications/`. Roles are grouped by company, with navigation links to each company. Role details sit alongside the full descriptions on desktop and stack above them on mobile. Each role also has its own page.

Copy an existing entry and update its front matter:

```yaml
---
title: "Team Lead"
team: "Multi-task Learning"
company: "Company name"
location: "The Netherlands"
date_start: "2026-07"
date_finish: ""
short_description: "A brief overview shown beneath the role details."
highlights:
  - "A key contribution or result shown before the full description in the CV."
---

Write the **long description** here, using Markdown. It appears on both the
Work experience page and the individual role page, and can include paragraphs,
lists, and links to papers. Separate paragraphs with blank lines.
```

Use the exact same `company` name to group roles together. `team` and `location` are optional; locations appear in both the overview and the individual role page. Roles are sorted by `date_start`, newest first, and companies are ordered by their most recent role's start date. Roles without a start date appear after dated roles.

Keep dates quoted and use `YYYY`, `YYYY-MM`, or `YYYY-MM-DD`, depending on the precision you know. Leave `date_finish` blank for an ongoing role. When both dates are unknown, leave them blank and optionally add `date_note: "Before JetBrains"` (or `"Present"` for a current role whose start date is unknown). Otherwise the page shows "Dates not specified". Roles without a company name appear under "Earlier experience".

`short_description` appears beneath the role details in a separate block of smaller, muted text and supports Markdown. The Markdown body below the front matter is the long description, displayed in full without expanding or opening another page; there is no separate `description` field to keep in sync. The old `period` and `order` fields are no longer used.

Keep each role's `highlights` in its Markdown front matter alongside the title and dates. These are plain-text bullets shown before the description in the CV. Omit the field or use `highlights: []` for a role without highlights. CV-specific replacements can still be set in `_data/cv.yml` under `experience_overrides` when tailoring an application.

## Saving a PDF CV

Open the **CV** tab (`/cv/`) and click **Save as PDF**. In the browser's print
dialog, choose **Save as PDF**, **A4**, and turn off headers and footers. The CV
uses the same Jekyll build as the website; no separate rendering engine is needed.

Customize `_data/cv.yml` on each application branch to select entries and override
CV wording without changing the other pages. GitHub Actions builds a standalone
HTML preview for each branch that you can download, open, and print locally.
See [the CV guide](cv/README.md) for shared content and branch customization.

# Changelog -- bugfixes and enhancements

There is one logistical issue with a ready-to-fork template theme like academic pages that makes it a little tricky to get bug fixes and updates to the core theme. If you fork this repository, customize it, then pull again, you'll probably get merge conflicts. If you want to save your various .yml configuration files and markdown files, you can delete the repository and fork it again. Or you can manually patch. 

To support this, all changes to the underlying code appear as a closed issue with the tag 'code change' -- get the list [here](https://github.com/academicpages/academicpages.github.io/issues?q=is%3Aclosed%20is%3Aissue%20label%3A%22code%20change%22%20). Each issue thread includes a comment linking to the single commit or a diff across multiple commits, so those with forked repositories can easily identify what they need to patch.
