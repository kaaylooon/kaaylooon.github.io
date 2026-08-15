---
slug: favoritos
status: approved
intent: unclear
review_required: true
plan_path: .omo/plans/favoritos.md
plan_sha256: 72218b7b1005b36363d0d5e9eace41863d531b11a1a11727c6aad9568dac8e17
review_round_id: rr-favoritos-20260814-02
pending-action: review .omo/plans/favoritos.md
review:
  momus:
    status: pending
    workspace_root: /home/kaylon/dev/web-kaaylooon-pages
    runtime_home: null
    target: .omo/plans/favoritos.md
    round_id: rr-favoritos-20260814-02
    plan_sha256: 72218b7b1005b36363d0d5e9eace41863d531b11a1a11727c6aad9568dac8e17
    launch_id: la-favoritos-momus-02
    session: null
    result: null
  independent:
    status: pending
    workspace_root: /home/kaylon/dev/web-kaaylooon-pages
    runtime_home: null
    target: .omo/plans/favoritos.md
    round_id: rr-favoritos-20260814-02
    plan_sha256: 72218b7b1005b36363d0d5e9eace41863d531b11a1a11727c6aad9568dac8e17
    launch_id: la-favoritos-oracle-02
    session: null
    result: null
approach: New /favoritos/ standalone page (layout null, modeled on about.html) rendering three data-driven sections - "Coisas que eu gosto" (favorites), "Experiências" (timeline), "Livros" (bookshelf) - fed by _data/{favoritos,experiencias,livros}.yml, bilingual via data-pt/data-en attributes, linked from site-nav, styled in assets/site.css.
---

# Draft: favoritos

## Components (topology ledger)
<!-- Lock the SHAPE before depth. One row per top-level component that can succeed or fail independently. -->
<!-- id | outcome (one line) | status: active|deferred | evidence path -->
- C1 | `_data/favoritos.yml` - grouped "things I like" entries (categoria, nome, nota) with pt/en fields | active | `_data/resume.yml:1-40` precedent
- C2 | `_data/experiencias.yml` - chronological timeline entries (periodo, titulo, descricao) with pt/en fields | active | `_data/resume.yml` precedent
- C3 | `_data/livros.yml` - bookshelf entries (titulo, autor, ano, status, nota) with pt/en fields | active | `_data/resume.yml` precedent
- C4 | `favoritos/index.html` - standalone page (layout: null, permalink /favoritos/) rendering the three sections via Liquid loops with data-pt/data-en rendering | active | `posts/index.html:1-21`, `about.html:1-60`
- C5 | `_includes/site-nav.html` - add "Favoritos" link to both `.nav-links` and `.nav-more-nav` | active | `_includes/site-nav.html:17-34`
- C6 | `assets/site.css` - styles for favorites grid, timeline, bookshelf; responsive at 768px/520px | active | `assets/site.css:911-990,1099-1286`

## Open assumptions (announced defaults)
<!-- Intent is UNCLEAR: research resolves ambiguity, defaults are adopted (not asked), and each is surfaced in the plan's human TL;DR for veto. -->
<!-- assumption | adopted default | rationale | reversible? -->
- Page topology | ONE new page `/favoritos/` with three sections, instead of three separate pages or new collections | IndieWeb /favorites convention groups likes+books+media; site is "one page per topic" (index, about, posts); keeps nav/sitemap light | yes - sections can be split later
- Content storage | Three `_data/*.yml` files, not a Jekyll collection | matches `_data/resume.yml` precedent; books/likes/experiences are structured lists, not long-form posts; no per-book pages needed | yes - can migrate to collections later
- Bilingual rendering | Liquid emits `data-pt`/`data-en` attributes from YAML `pt`/`en` fields; no change to `assets/lang-toggle.js` | existing toggle reads `[data-en][data-pt]` at DOM load (`lang-toggle.js:3,9-13`); zero JS churn | yes
- Bookshelf format | List-only (no per-book detail pages): titulo, autor, ano, status (lido|lendo), nota opcional | "livros que gostei" = a shelf, not reviews; avoids speculative page-per-item scope | yes
- Placeholder content | Ship 1-2 clearly-marked `# EXEMPLO - substitua` entries per section; user replaces after execution | executor must not fabricate the user's real favorites/experiences/books | yes
- Nav label | "Favoritos" (`data-pt="Favoritos" data-en="Favorites"`) added to desktop `.nav-links` and mobile `.nav-more-nav` | matches existing bilingual nav entries (`site-nav.html:17-23`) | yes
- Section order | Coisas que eu gosto -> Experiências -> Livros | mirrors the user's request order | yes

## Findings (cited - path:lines)
- Jekyll static site, no Gemfile/package manager; build via `jekyll serve` / `jekyll build` (AGENTS.md)
- Collections: only `projetos` in `_config.yml:11-14` (permalink `/projetos/:path/`); defaults map `_projetos` -> layout `projeto` (`_config.yml:16-21`)
- Standalone page pattern with `layout: null`: `posts/index.html:1-7` (permalink `/posts/`), `about.html:1-7`; both include site-head/site-nav/site-footer and load `assets/lang-toggle.js` (`about.html:55-57`)
- Bilingual: attribute pattern `data-pt`/`data-en` (`index.html:24-28`), block pattern `data-language-block="pt|en"` with `hidden`/`aria-hidden` (`about.html:32-51`); toggle in `assets/lang-toggle.js:1-45` swaps textContent for `[data-en][data-pt]` nodes and visibility for `[data-language-block]` blocks; sets `document.documentElement.lang` (`lang-toggle.js:24-34`)
- Nav: `.nav-links` desktop list (`site-nav.html:28-35`), `.nav-more-nav` mobile `<details>` dropdown (`site-nav.html:11-25`); all entries carry `data-pt`/`data-en`
- Structured-data precedent: `_data/resume.yml` (person/education/skills) - data files are valid content carriers
- CSS design system: bento-grid/bento-card (`site.css:911-990`), `.post-item`/`.posts-list` (`site.css:725-759`), media queries at 1024/768/520 (`site.css:1099-1286`); 4-space indent dominant in rules; site is dark-themed with CSS vars (`site.css:5-38`)
- External convention research: IndieWeb `/favorites` and `/canon` pages are the standard pattern for personal "things I like / influential media / books" listings (indieweb.org/canon; therezaali.com/favorites; holmberg.io/bookshelf; bradfrost.com/reading) - grouped lists, bookshelf with read/reading status, human URLs
- No tests in repo; AGENTS.md: validate via `jekyll build`/preview + responsive checks

## Decisions (with rationale)
- D1 (UNCLEAR routing): adopt best-practice defaults instead of interviewing; announce them in the human TL;DR for veto. Rationale: request is fuzzy ("coisas que eu gosto, experiências e livros") and user asked "how could this be added".
- D2: one page `/favoritos/`, three sections. Rationale: IndieWeb convention + site topology; minimal nav surface; reversible.
- D3: `_data/*.yml` as content source rendered by Liquid loops. Rationale: resume.yml precedent; keeps future edits to one YAML file per category, no HTML surgery.
- D4: bilingual via per-item `data-pt`/`data-en` attributes; long section intros via `data-language-block` blocks. Rationale: existing toggle handles both with zero JS changes.
- D5: bookshelf list-only; no new collections, no per-book pages, no _config.yml changes. Rationale: book reviews were not requested; scope guard.
- D6: placeholder examples marked `# EXEMPLO` so the user swaps in real content. Rationale: never fabricate the user's personal data.

## Scope IN
- Create `_data/favoritos.yml`, `_data/experiencias.yml`, `_data/livros.yml` with schema + 1-2 placeholder entries each (marked as examples)
- Create `favoritos/index.html` (layout: null, permalink: /favoritos/, og_type: website) rendering the three sections; section intros bilingual via data-language-block; per-item pt/en via data-pt/data-en
- Add "Favoritos" nav entry in `_includes/site-nav.html` (both `.nav-links` and `.nav-more-nav`)
- Append styles to `assets/site.css` (favorites grid reusing bento classes where possible, timeline, bookshelf) with responsive rules aligned to existing breakpoints
- Verify: `jekyll build` exit 0, `_site/favoritos/index.html` generated with expected Liquid output; `jekyll serve` render check + lang toggle behavior

## Scope OUT (Must NOT have)
- NO new collections, NO per-book/project detail pages, NO `_config.yml` changes (baseurl/url/permalink are global: AGENTS.md)
- NO edits to `assets/lang-toggle.js` - the existing toggle must cover the new content unchanged
- NO changes to existing pages' content (index.html, about.html, posts/, _projetos/, _posts/) except the shared `site-nav.html` include
- NO new external scripts/fonts/CDNs beyond what site-head already loads
- NO fabricated personal content shipped as real: placeholder entries only, clearly marked for replacement
- NO RSS/JSON feeds, no social share buttons, no analytics changes

## Open questions
- none - UNCLEAR route: all forks resolved by research + adopted defaults (vetoable at the gate)

## Approval gate
status: awaiting-approval
<!-- When exploration is exhausted and unknowns are answered, set status: awaiting-approval. -->
<!-- That durable record is the loop guard: on a later turn read it and resume at the gate instead of re-running exploration. -->