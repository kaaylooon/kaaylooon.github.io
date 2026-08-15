# favoritos - Work Plan

## TL;DR (For humans)
<!-- Fill this LAST, after the detailed plan below is written, so it summarizes the REAL plan. -->
<!-- Plain English for a non-engineer: NO file paths, NO todo numbers, NO wave/agent/tool names. -->

**What you'll get:** A new "Favoritos" page on your site with three sections — things you like (grouped by category), experiences (a timeline), and books you enjoyed (a shelf with read/reading status). All content is stored in three simple text files you can edit later, and everything appears in both Portuguese and English using the language toggle you already have.

**Why this approach:** It follows the standard pattern for personal sites (a single favorites page with grouped lists), reuses the site's existing bilingual and styling machinery so nothing else has to change, and keeps all future content edits as simple as editing one YAML file per category.

**What it will NOT do:** It will not create a page per book or per item, will not touch the site's global configuration, language-switching script, or existing pages, will not add new external scripts or feeds, and will not invent real personal facts — it ships clearly-marked example entries for you to replace with your real favorites, experiences, and books.

**Effort:** Short
**Risk:** Low - purely additive page; existing pages untouched except the shared menu include
**Decisions I made for you:** (1) one page with three sections instead of three separate pages; (2) content in three `_data/*.yml` files instead of a new Jekyll collection; (3) books as a list without per-book pages; (4) bilingual via the existing toggle with zero JavaScript changes; (5) example placeholder content that you replace. All reversible - say the word and any of these changes.

Your next move: approve this plan to start work, or adjust any decision above. Full execution detail follows below.

---

> TL;DR (machine): Short effort / Low risk - additive /favoritos/ page (3 sections: favorites, timeline, bookshelf) driven by 3 _data/*.yml files, bilingual via existing data-pt/data-en toggle, nav link + CSS appended.

## Scope
### Must have
- New standalone page at `/favoritos/` (`favoritos/index.html`, `layout: null`, `permalink: /favoritos/`) with three sections in this order: "Coisas que eu gosto" (favorites), "Experiências" (timeline), "Livros" (bookshelf).
- Three data files: `_data/favoritos.yml` (grouped favorites), `_data/experiencias.yml` (chronological timeline), `_data/livros.yml` (books with status lido|lendo).
- Every section, group, item, and status label rendered bilíngue: page-level bilingual via `data-pt`/`data-en` attributes and `data-language-block` blocks exactly as the existing toggle (`assets/lang-toggle.js`) expects; data-driven items emit `<span data-pt="..." data-en="...">` so the existing toggle swaps text with zero JS changes.
- "Favoritos" entry added to both nav surfaces: desktop `.nav-links` and mobile `.nav-more-nav` in `_includes/site-nav.html`.
- Styles appended to `assets/site.css` for favorites list, timeline, and bookshelf, with responsive behavior at the existing 768px and 520px breakpoints.
- 1-2 clearly-marked placeholder entries per section (`# EXEMPLO - substitua`) so the page renders meaningfully; the user replaces them with real content after execution.
- Verification: `jekyll build` exit 0 and `_site/favoritos/index.html` generated; `jekyll serve` + HTTP 200 check; rendered HTML contains the expected Liquid output (sections, data-pt/data-en spans, nav link).

### Must NOT have (guardrails, anti-slop, scope boundaries)
- NO new Jekyll collections, NO per-book/per-item detail pages, NO changes to `_config.yml` (collections/permalink/baseurl are global - AGENTS.md).
- NO edits to `assets/lang-toggle.js` - the existing toggle must cover the new content unchanged.
- NO changes to the content of existing pages (`index.html`, `about.html`, `posts/`, `_projetos/`, `_posts/`) other than the shared `_includes/site-nav.html` include.
- NO new external scripts/fonts/CDN beyond what `site-head.html` already loads; NO RSS/JSON feeds; NO analytics or social widgets.
- NO fabricated personal data presented as real: every shipped entry is a placeholder explicitly commented `# EXEMPLO - substitua`; nothing about Kaylon's actual favorites/experiences/books is invented.
- NO empty sections: if a data file is empty the section still renders with its bilingual heading and an empty list (no crash), but at handoff every section must contain at least its placeholder entries.
- NO `style.css` (the stray legacy file) edits - only `assets/site.css` may change.

## Verification strategy
> Zero human intervention - all verification is agent-executed.
- Test decision: none (repo has no test framework; Jekyll build + rendered-HTML assertions replace unit tests) + agent-executed QA per todo and in the final verification wave.
- Evidence: `.omo/evidence/task-<N>-favoritos.txt` (outside ulw-loop use `.omo/evidence/`)
- Primary commands: `jekyll build` (must exit 0), `jekyll serve` (background) + `curl -s -o /dev/null -w "%{http_code}" http://localhost:4000/favoritos/` (must print 200), `grep`/`rg` assertions against `_site/favoritos/index.html` and `_site/index.html`.
- If `jekyll` is not installed on the worker machine, the worker marks the todo QA BLOCKED and records the missing command - never fakes a passing build.

## Execution strategy
### Parallel execution waves
> Target 5-8 todos per wave. Fewer than 3 (except the final) means you under-split.
- Wave 1 (parallel): T1 (favoritos.yml), T2 (experiencias.yml), T3 (livros.yml) - three independent data files.
- Wave 2 (parallel): T4 (page `favoritos/index.html`), T5 (nav entry), T6 (CSS) - T4 needs the data files from Wave 1; T5 and T6 are independent of each other and of the data files (but T6's selectors are dictated by T4's markup, so follow the class names in T4 exactly).
- Wave 3: none - final verification wave runs after all todos.

### Dependency matrix
| Todo | Depends on | Blocks | Can parallelize with |
| --- | --- | --- | --- |
| T1 | none | T4 | T2, T3 |
| T2 | none | T4 | T1, T3 |
| T3 | none | T4 | T1, T2 |
| T4 | T1, T2, T3 | F3 (real manual QA) | T5, T6 |
| T5 | none | F3 | T1, T2, T3, T4, T6 |
| T6 | none (but must use T4's class names) | F3 | T1, T2, T3, T4, T5 |

## Todos
> Implementation + Test = ONE todo. Never separate.
<!-- APPEND TASK BATCHES BELOW THIS LINE WITH edit/apply_patch - never rewrite the headers above. -->
- [x] 1. `_data/favoritos.yml` - grouped "things I like" data file
  What to do / Must NOT do: Create `_data/favoritos.yml` as a top-level list of groups. Each group: `categoria: {pt: <string>, en: <string>}` and `itens:` (list). Each item: `nome: {pt, en}` and optional `nota: {pt, en}`. Ship exactly 2 groups with 1-2 placeholder items each, every entry carrying a `# EXEMPLO - substitua` comment. Do NOT invent real favorites (a category name like "Música" with an invented album is fine as placeholder - it is commented as example). Do NOT touch any other file.
  Parallelization: Wave 1 | Blocked by: none | Blocks: T4
  References (executor has NO interview context - be exhaustive): `_data/resume.yml:1-40` (YAML style precedent - quoted strings, hyphen lists); `assets/lang-toggle.js:3,9-13` (toggle reads `[data-en][data-pt]` textContent at load); `_includes/site-nav.html:17-23` (how bilingual labels are written elsewhere). Schema exactly:
    ```yaml
    - categoria:
        pt: "..."   # EXEMPLO - substitua
        en: "..."
      itens:
        - nome:
            pt: "..."
            en: "..."
          nota:
            pt: "..."
            en: "..."
    ```
  Acceptance criteria (agent-executable): `jekyll build` exits 0 with the file present (Jekyll parses all `_data` at startup; bad YAML fails the build). File parses as YAML with `grep -c "categoria:" _data/favoritos.yml` returning 2 and itens present under each group. Every string value is quoted in YAML.
  QA scenarios (name the exact tool + invocation): happy: `jekyll build 2>&1 | tee .omo/evidence/task-1-favoritos.txt; echo $?` prints 0. failure: temporarily append `- [1, 2` (an unclosed YAML flow sequence - a guaranteed Psych::SyntaxError, unlike `- :bad` which only trips safe_load's DisallowedClass) to the file, run `jekyll build` and confirm non-zero exit, then restore the file and confirm exit 0 again. Evidence `.omo/evidence/task-1-favoritos.txt`
  Commit: Y | `chore: add favorites data file`
- [x] 2. `_data/experiencias.yml` - experiences timeline data file
  What to do / Must NOT do: Create `_data/experiencias.yml` as a top-level list ordered oldest-to-newest. Each entry: `periodo: <string>`, `titulo: {pt, en}`, optional `descricao: {pt, en}`. Ship 2 placeholder entries with `# EXEMPLO - substitua` comments. Do NOT invent real experiences (e.g. "2024 - Primeira medalha olímpica" is a placeholder, not a documented fact - it is commented as example). Do NOT sort at render time; the renderer will reverse the list so newest appears first.
  Parallelization: Wave 1 | Blocked by: none | Blocks: T4
  References (executor has NO interview context - be exhaustive): `_data/resume.yml:18-22` (period-style string precedent); `assets/lang-toggle.js:3,9-13`; schema exactly:
    ```yaml
    - periodo: "2024"
      titulo:
        pt: "..."
        en: "..."
      descricao:
        pt: "..."
        en: "..."
    ```
  Acceptance criteria (agent-executable): `jekyll build` exits 0. `grep -c "periodo:" _data/experiencias.yml` returns 2. All strings quoted.
  QA scenarios: happy: `jekyll build 2>&1 | tee .omo/evidence/task-2-favoritos.txt; echo $?` prints 0. failure: delete the file, run `jekyll build` - must still exit 0 (Jekyll tolerates missing `_data`), restore it, confirm exit 0. Evidence `.omo/evidence/task-2-favoritos.txt`
  Commit: Y | `chore: add experiences data file`
- [x] 3. `_data/livros.yml` - bookshelf data file
  What to do / Must NOT do: Create `_data/livros.yml` as a top-level list. Each entry: `titulo: <string>`, `autor: <string>`, `ano: <integer>`, `status: lido|lendo` (values exactly these lowercase pt words - the page maps them to bilingual labels), optional `nota: {pt, en}`. Ship 2 placeholder books with `# EXEMPLO - substitua` comments. Do NOT invent real books the user read (placeholder titles are ok when commented as example). Do NOT add per-book pages or `repo`/`link` fields (not requested).
  Parallelization: Wave 1 | Blocked by: none | Blocks: T4
  References (executor has NO interview context - be exhaustive): `_data/resume.yml:18-22` (structure precedent); `_projetos/kaappli.md:1-8` (front matter status-string precedent `status: "Concluído"`); schema exactly:
    ```yaml
    - titulo: "..."       # EXEMPLO - substitua
      autor: "..."
      ano: 2024
      status: lido        # lido | lendo
      nota:
        pt: "..."
        en: "..."
    ```
  Acceptance criteria (agent-executable): `jekyll build` exits 0. `grep -c "status: lido\|status: lendo" _data/livros.yml` returns 2. `ano` values are integers, not strings.
  QA scenarios: happy: `jekyll build 2>&1 | tee .omo/evidence/task-3-favoritos.txt; echo $?` prints 0. failure: set `status: "lendo agora"` (invalid value) and confirm the page still builds (renderer must handle unknown status by falling back to "lendo" label logic - see T4); then restore a valid value. Evidence `.omo/evidence/task-3-favoritos.txt`
  Commit: Y | `chore: add bookshelf data file`
- [x] 4. `favoritos/index.html` - the /favoritos/ page rendering the three sections
  What to do / Must NOT do: Create `favoritos/index.html` modeled on `about.html` and `posts/index.html`. Front matter: `layout: null`, `permalink: /favoritos/`, `title: "Favoritos"`, `description:` (bilingual-agnostic one-liner), `og_type: website`. Full HTML document: include `site-head.html`, `site-nav.html`, back-link to `/` (same markup as `about.html:22-24`), a `post-header` h1 "Favoritos" with `data-pt`/`data-en`, then three `<section>`s in order: `#gostos` (h2 "Coisas que eu gosto"/"Things I like"), `#experiencias` (h2 "Experiências"/"Experiences"), `#livros` (h2 "Livros"/"Books"). Each section: optional short intro paragraph using `data-language-block="pt"` and `data-language-block="en"` (pattern from `about.html:32-51`). Render data with Liquid loops over `site.data.favoritos` / `site.data.experiencias` / `site.data.livros`. Every rendered string MUST be wrapped in `<span data-pt="{{ X.pt }}" data-en="{{ X.en }}">{{ X.pt }}</span>` (or the en default inside) so the existing toggle works. Experiencias: `{% for exp in site.data.experiencias reversed %}` - newest first; show `periodo`, title span, optional description span. Livros: map `status` `lido` -> label spans "Lido"/"Read", `lendo` -> "Lendo"/"Reading", default (unknown) -> "Lendo"/"Reading"; render title, autor, ano, nota span; use class names: `.livro-item`, `.livro-meta`, `.livro-status`, `.livro-status--lido`, `.livro-status--lendo`. Gostos: `{% for grupo in site.data.favoritos %}` render categoria span as `<h3>` and each item as `<li class="favorito-item">` with nome span and optional nota span. Classes for gostos: `.favorito-grupo`, `.favorito-item`, `.favorito-nota`; for experiencias: `.timeline`, `.timeline-item`, `.timeline-periodo`, `.timeline-titulo`, `.timeline-descricao`. Include `site-footer.html` and the lang-toggle script tag (`about.html:55-57`). Two-space HTML/Liquid indentation (AGENTS.md). Must NOT add per-item links/pages, must NOT touch JS, must NOT use `style.css`.
  Parallelization: Wave 2 | Blocked by: T1, T2, T3 | Blocks: F3
  References (executor has NO interview context - be exhaustive): `about.html:1-7` (layout: null front matter precedent) + `about.html:8-60` (full standalone document incl. head/nav/footer/lang-toggle + data-language-block pattern at 32-51); `posts/index.html:1-6` (permalink: /posts/ page precedent - NOTE posts/index.html uses `layout: archive`, not null; do NOT copy that layout); `about.html:22-24` (back-link markup - the ONLY back-link reference, posts/index.html:30-32 does not exist); `assets/lang-toggle.js:3,9-13,16-22` (both toggle mechanisms); `_config.yml:11-14` (collections - DO NOT add one); `AGENTS.md` (two-space indentation; keep content files in pattern).
  Acceptance criteria (agent-executable): `jekyll build` exits 0. `test -f _site/favoritos/index.html` succeeds. `grep -c 'data-pt=' _site/favoritos/index.html` >= 10 (placeholders + labels). `grep -c 'data-language-block' _site/favoritos/index.html` >= 2 (pt + en intro if intros used; if no intros used, >= 0 is acceptable - but every rendered item still carries data-pt/data-en). `grep -c 'id="gostos"\|id="experiencias"\|id="livros"' _site/favoritos/index.html` returns 3.
  QA scenarios: happy: `jekyll serve --port 4000` in background, `curl -s -o /dev/null -w "%{http_code}" http://localhost:4000/favoritos/` prints 200, then `curl -s http://localhost:4000/favoritos/ | grep -c 'data-pt='` >= 10; kill the server. failure: temporarily rename `_data/livros.yml` out of the way, rebuild - page must build and the #livros section render with its heading and an empty list (no Liquid crash), then restore. Evidence `.omo/evidence/task-4-favoritos.txt`
  Commit: Y | `feat: add favoritos page`
- [x] 5. `_includes/site-nav.html` - add "Favoritos" to desktop and mobile nav
  What to do / Must NOT do: In `_includes/site-nav.html` add exactly two entries pointing to `/favoritos/`: (a) inside `.nav-more-nav` after the Posts link (line ~23) an `<a href="/favoritos/" data-en="Favorites" data-pt="Favoritos">Favoritos</a>`; (b) inside `.nav-links` after the Posts `<li>` (line ~33) `<li><a href="/favoritos/" data-en="Favorites" data-pt="Favoritos">Favoritos</a></li>`. Use plain `/favoritos/` href (site baseurl is empty), matching the `/posts/` link style at `site-nav.html:23,33`. Must NOT reorder existing entries, must NOT touch other files.
  Parallelization: Wave 2 | Blocked by: none | Blocks: F3
  References (executor has NO interview context - be exhaustive): `_includes/site-nav.html:11-35` (both nav surfaces and the exact bilingual link pattern); `posts/index.html:5` (`permalink: /posts/` precedent for the target URL).
  Acceptance criteria (agent-executable): `jekyll build` exits 0. `grep -c 'href="/favoritos/"' _site/index.html` returns 2. `grep -c 'href="/favoritos/"' _site/favoritos/index.html` returns 1 (its own nav include).
  QA scenarios: happy: after `jekyll serve`, `curl -s http://localhost:4000/ | grep -c 'href="/favoritos/"'` prints 2. failure: curl `/favoritos/` returns 200 (the target resolves - if it returned 404 the nav link would be broken); assert with `curl -s -o /dev/null -w "%{http_code}" http://localhost:4000/favoritos/` == 200. Evidence `.omo/evidence/task-5-favoritos.txt`
  Commit: Y | `feat: add favoritos to nav`
- [x] 6. `assets/site.css` - styles for favorites, timeline, and bookshelf
  What to do / Must NOT do: Append (do not rewrite) a clearly-delimited block at the end of `assets/site.css` styling exactly the class names from T4: `.favorito-grupo`, `.favorito-item`, `.favorito-nota`, `.timeline`, `.timeline-item`, `.timeline-periodo`, `.timeline-titulo`, `.timeline-descricao`, `.livro-item`, `.livro-meta`, `.livro-status`, `.livro-status--lido`, `.livro-status--lendo`. Use the existing design tokens (`var(--bg-card)`, `var(--border-color)`, `var(--card-radius)`, `var(--text-dim)`, `var(--accent-blue)` - see `site.css:5-38`) and match the existing card aesthetic. Add responsive rules inside the existing `@media (max-width: 768px)` and `@media (max-width: 520px)` blocks (or in appended equivalent blocks) so timeline/livro/favorito layouts collapse to a single column on mobile. Follow the file's dominant indentation (4-space inside rules). Do NOT edit `style.css`, do NOT restyle any existing component, do NOT change existing selectors.
  Parallelization: Wave 2 | Blocked by: none (but must target T4 class names) | Blocks: F3
  References (executor has NO interview context - be exhaustive): `assets/site.css:5-38` (tokens), `assets/site.css:911-990` (bento card visual language to match), `assets/site.css:1099-1286` (existing breakpoints 1024/768/520), `assets/site.css:725-759` (list layout precedent).
  Acceptance criteria (agent-executable): `jekyll build` exits 0. `grep -c '\.livro-item' assets/site.css` >= 1 and `grep -c '\.timeline-item' assets/site.css` >= 1 and `grep -c '\.favorito-item' assets/site.css` >= 1. `grep -c '@media (max-width: 768px)' assets/site.css` >= 1 (existing or appended).
  QA scenarios: happy: build + `curl -s http://localhost:4000/favoritos/ | grep -c 'livro-status'` >= 2 and same >= 2 for `timeline-item`; confirms markup+CSS class alignment. failure: grep `_site/favoritos/index.html` for `class="timeline-item"` matches present (if T6 CSS names diverged from T4 markup there would be zero matches). Evidence `.omo/evidence/task-6-favoritos.txt`
  Commit: Y | `style: add favoritos styles`

## Final verification wave
> Runs in parallel after ALL todos. ALL must APPROVE. Surface results and wait for the user's explicit okay before declaring complete.
- [ ] F1. Plan compliance audit
- [ ] F2. Code quality review
- [ ] F3. Real manual QA
- [ ] F4. Scope fidelity
- [ ] F5. Bilingual toggle verification - `curl -s http://localhost:4000/favoritos/` output contains both `data-pt=` and `data-en=` on the same elements for every rendered item (`grep -c 'data-en=' _site/favoritos/index.html` >= 10); confirm in the source that `assets/lang-toggle.js` is untouched (`git status` shows no change to `assets/lang-toggle.js`) and that the page includes its script tag.

## Commit strategy
- Commit per todo as it completes, short lowercase imperative subjects per AGENTS.md (existing style: `redesign`): T1 `chore: add favorites data file`, T2 `chore: add experiences data file`, T3 `chore: add bookshelf data file`, T4 `feat: add favoritos page`, T5 `feat: add favoritos to nav`, T6 `style: add favoritos styles`.
- No commit that touches `_config.yml`, `assets/lang-toggle.js`, `style.css`, or existing page content - those must never appear in the diff.

## Success criteria
- `jekyll build` exits 0; `/favoritos/` returns HTTP 200 under `jekyll serve`.
- The page shows three sections in order (gostos, experiencias, livros) with bilingual headings and per-item pt/en rendering; the existing language toggle swaps every visible string on the page without JS changes.
- Nav shows "Favoritos" on desktop (`.nav-links`) and mobile (`.nav-more-nav`); both link to `/favoritos/`.
- Responsive rendering at desktop/mobile widths with no horizontal overflow or broken layout.
- `git status` shows changes ONLY in: `_data/favoritos.yml`, `_data/experiencias.yml`, `_data/livros.yml`, `favoritos/index.html`, `_includes/site-nav.html`, `assets/site.css`. Nothing else modified.
- Every shipped data entry is commented `# EXEMPLO - substitua`; no fabricated real-world facts presented as fact.