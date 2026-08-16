# Repository Guidelines

## Project Structure & Module Organization
This is a Jekyll-based personal site, not an application with a compiled backend. Main entry points are `index.html` and `about.html`, with shared page wrappers in `_layouts/`. Project and article content lives in `_projetos/` and `_posts/`, respectively. Static assets, styles, and images are under `assets/`. Keep new content files in the same pattern:
- Posts: `_posts/YYYY-MM-DD-slug.md`
- Projects: `_projetos/slug.md`
- Images and CSS: `assets/`

## Build, Test, and Development Commands
The repo uses Bundler (Gemfile committed). Install dependencies and build with:
- `bundle install` - install Jekyll and the jekyll-sitemap plugin.
- `bundle exec jekyll serve` - start a local preview server with live rebuilds.
- `bundle exec jekyll build` - generate the static site output for a final check.
- `git status` - verify only the intended HTML, Markdown, CSS, and asset files changed.

`sitemap.xml` is generated automatically by the jekyll-sitemap plugin at build time — do not edit or commit a manual sitemap. Open the HTML directly only for a quick sanity check, and prefer a Jekyll preview for content that uses layouts or collections.

## Coding Style & Naming Conventions
Use two-space indentation for HTML/Liquid and keep CSS declarations consistently indented. Prefer lowercase, descriptive filenames with hyphens for new pages and assets. Keep inline scripts and styles minimal; place reusable styling in `assets/site.css`. Preserve the existing bilingual pattern with `data-pt` and `data-en` attributes when editing copy that needs translation.

## Testing Guidelines
There are no automated tests in this repository. Validate changes by previewing the site locally and checking:
- Home page, about page, and any affected project/post pages
- Responsive behavior at mobile and desktop widths
- Links, metadata, and image paths

For content edits, confirm the rendered markdown and front matter still produce valid pages.

## Commit & Pull Request Guidelines
Recent commits use short lowercase subjects such as `redesign`. Follow the same style: brief, imperative, and specific. For pull requests, include:
- A short summary of the visible change
- Screenshots or a preview link for UI updates
- Notes on affected routes or collection files
- Any manual verification steps performed

## Content & Configuration Notes
Site-wide settings live in `_config.yml`. Be careful when changing `baseurl`, `url`, or collection permalinks, because they affect every generated page. Keep external scripts and fonts limited to what the page already uses unless there is a clear need to expand them.
