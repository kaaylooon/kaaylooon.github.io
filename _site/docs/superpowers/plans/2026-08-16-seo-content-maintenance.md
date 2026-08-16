# SEO, Conteúdo e Manutenção do Site — Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Aplicar as melhorias validadas de uma revisão do site: Open Graph por página, sitemap via `jekyll-sitemap` (com Gemfile), página `/projetos/`, CTAs em posts/projetos e renomeação da imagem do post do livro.

**Architecture:** Site Jekyll estático com layouts por tipo de página (`_layouts/`) e includes compartilhadas (`_includes/`). Mudanças concentram-se em `_config.yml`, `_includes/site-head.html`, `_includes/site-nav.html`, layouts de posts/projetos e front matter de conteúdo. O sitemap passa a ser gerado pelo plugin `jekyll-sitemap` em vez de um arquivo manual.

**Tech Stack:** Jekyll 4.4 (Ruby 3.1), `jekyll-sitemap` via Bundler, ImageMagick (`convert`) para WebP. Sem framework de testes — verificação é por `bundle exec jekyll build` + inspeção do HTML gerado em `_site/`.

## Global Constraints

- Ambiente local: Ruby 3.1.2, Jekyll 4.4.1, Bundler 2.6.9. `jekyll-sitemap` ainda NÃO instalado (instalar via `bundle install`).
- Indentação de 2 espaços em HTML/Liquid; manter padrão de comentários e ordem das seções existentes.
- Textos bilíngues: todo texto visível novo usa `data-pt`/`data-en` (pt é o default no HTML).
- Não deletar `assets/2026-06-12  -  02h05m.png` nem `assets/auriuminitium.png` (órfãs, decisão do usuário).
- Não converter em massa imagens de projetos para WebP (fora de escopo).
- Não alterar `scripts/generate_resume.rb`.
- Home (`index.html`) mantém nav "Projetos" com scroll para `/#projetos`; demais páginas apontam para `/projetos/`.
- `_config.yml` já exclui `Gemfile`/`Gemfile.lock` da build via `exclude` — não remover.
- Valores de config honestos: `author: Kaylon Souza`, `github_username: kaaylooon`, `linkedin_username: kaylonsouza` (não inventar handles).
- Commits: exigem autorização explícita do usuário antes de qualquer `git commit`.

---

### Task 1: Gemfile, config e sitemap via plugin

**Files:**
- Create: `Gemfile`
- Modify: `_config.yml` (adicionar `author`, `github_username`, `linkedin_username`, `plugins`)
- Delete: `sitemap.xml` (manual, substituído pelo plugin)
- Modify: `AGENTS.md` (seção "Build, Test, and Development Commands")

**Interfaces:**
- Consumes: nada.
- Produces: `site.author`, `site.github_username`, `site.linkedin_username`, `site.plugins` — usados pela Task 2 (`site-head.html`). `bundle exec jekyll build` — usado por todas as tasks seguintes. `_site/sitemap.xml` gerado automaticamente.

- [ ] **Step 1: Criar o Gemfile**

```ruby
source "https://rubygems.org"

gem "jekyll", "~> 4.4"
gem "jekyll-sitemap"
gem "webrick"
```

- [ ] **Step 2: Instalar dependências**

Run: `bundle install`
Expected: instala `jekyll-sitemap` (e dependências); cria `Gemfile.lock`. `webrick` é necessário para `bundle exec jekyll serve` em Ruby ≥ 3.0.

- [ ] **Step 3: Atualizar `_config.yml`**

Adicionar ao topo (após `description`), mantendo indentação de 2 espaços:

```yaml
author: Kaylon Souza
github_username: kaaylooon
linkedin_username: kaylonsouza
```

E adicionar na raiz do arquivo:

```yaml
plugins:
  - jekyll-sitemap
```

- [ ] **Step 4: Remover o sitemap manual**

Run: `git rm sitemap.xml`
Expected: `sitemap.xml` removido do working tree e do índice. O plugin gera `_site/sitemap.xml` na build (nunca commitar um sitemap manual).

- [ ] **Step 5: Atualizar `AGENTS.md` — seção "Build, Test, and Development Commands"**

Substituir o texto atual (que afirma não existir Gemfile e usa `jekyll` direto) por:

```markdown
## Build, Test, and Development Commands
The repo uses Bundler (Gemfile committed). Install dependencies and build with:
- `bundle install` - install Jekyll and the jekyll-sitemap plugin.
- `bundle exec jekyll serve` - start a local preview server with live rebuilds.
- `bundle exec jekyll build` - generate the static site output for a final check.
- `git status` - verify only the intended HTML, Markdown, CSS, and asset files changed.

`sitemap.xml` is generated automatically by the jekyll-sitemap plugin at build time — do not edit or commit a manual sitemap. Open the HTML directly only for a quick sanity check, and prefer a Jekyll preview for content that uses layouts or collections.
```

- [ ] **Step 6: Verificar build + sitemap**

Run:
```bash
bundle exec jekyll build
```
Expected: exit 0, sem warnings de plugin faltando.

Run: `grep -o '/2026/' _site/sitemap.xml | wc -l && grep -c '/projetos/' _site/sitemap.xml`
Expected: contagem de posts `/2026/...` ≥ 2 (os dois posts do `_posts/`), e `/projetos/` presente (coleção). Confirmar também que `/`, `/about.html`, `/posts/` e `/projetos/` estão no sitemap.

- [ ] **Step 7: Commit** (aguardar autorização explícita do usuário)

```bash
git add Gemfile Gemfile.lock _config.yml AGENTS.md
git commit -m "feat: add jekyll-sitemap and bundler support"
```
(A deleção de `sitemap.xml` já está staged pelo `git rm` do Step 4.)

---

### Task 2: `site-head.html` — Open Graph por página e SEO

**Files:**
- Modify: `_includes/site-head.html` (bloco OG + JSON-LD)

**Interfaces:**
- Consumes: `site.github_username`, `site.linkedin_username` (Task 1); `page.image`, `page.image_alt`, `page.description`, `page.date`, `page.lang`, `page.og_type` (front matter das páginas).
- Produces: `og:image`/`twitter:image` por página, `og:image:alt`, `og:locale` dinâmico, `article:published_time`/`article:modified_time` quando `og_type == article`.

- [ ] **Step 1: Adicionar variáveis de imagem e locale no topo do include**

Após a linha 5 (`{% assign og_type = ... %}`), inserir:

```liquid
{% assign og_image = page.image | default: '/assets/particles.png' %}
{% assign og_locale = 'pt_BR' %}
{% if page.lang == 'en' %}
  {% assign og_locale = 'en_US' %}
{% endif %}
```

- [ ] **Step 2: Substituir o bloco og:image fixo**

Substituir as linhas 32-38 por:

```liquid
{% if page.image %}
<meta property="og:image" content="{{ og_image | absolute_url }}">
{% else %}
<meta property="og:image" content="{{ '/assets/particles.png' | absolute_url }}">
<meta property="og:image:width" content="1200">
<meta property="og:image:height" content="630">
{% endif %}
<meta property="og:image:alt" content="{{ page.image_alt | default: page_title | escape }}">
<meta property="og:locale" content="{{ og_locale }}">
{% if og_type == "article" and page.date %}
<meta property="article:published_time" content="{{ page.date | date_to_xmlschema }}">
<meta property="article:modified_time" content="{{ page.last_modified_at | default: page.date | date_to_xmlschema }}">
{% endif %}
```

- [ ] **Step 3: Atualizar `twitter:image`**

Substituir a linha 38 (`<meta name="twitter:image" content="{{ '/assets/particles.png' | absolute_url }}">`) por:

```liquid
<meta name="twitter:image" content="{{ og_image | absolute_url }}">
```

- [ ] **Step 4: Extrair `sameAs` do JSON-LD para o config**

No bloco `application/ld+json` (linhas 61-64), substituir:

```json
"sameAs": [
  "https://github.com/kaaylooon",
  "https://linkedin.com/in/kaylonsouza"
]
```

por:

```liquid
"sameAs": [
  "https://github.com/{{ site.github_username }}",
  "https://linkedin.com/in/{{ site.linkedin_username }}"
]
```

- [ ] **Step 5: Verificar build + tags no HTML gerado**

Run: `bundle exec jekyll build && grep -o 'og:image[^>]*' _site/2026/08/15/aurum-initium.html`
Expected: `og:image` = fallback `/assets/particles.png` COM width/height (a página ainda não tem `page.image` nesta task — a imagem própria entra na Task 4).

Run: `grep -c 'article:published_time' _site/2026/08/15/aurum-initium.html && grep -o 'og:locale[^>]*' _site/2026/08/15/aurum-initium.html`
Expected: `article:published_time` presente; `og:locale` com `pt_BR`.

Run: `grep -A 3 '"sameAs"' _site/index.html`
Expected: `github.com/kaaylooon` e `linkedin.com/in/kaylonsouza` (valores vindos do config). (JSON-LD é multi-linha; um `grep -o 'sameAs[^]]*]'` não captura.)

- [ ] **Step 6: Commit** (aguardar autorização explícita do usuário)

```bash
git add _includes/site-head.html
git commit -m "feat: per-page open graph and locale metadata"
```

---

### Task 3: Renomear imagem do post + WebP

**Files:**
- Rename: `assets/2026-06-12  -  02h08m.png` → `assets/capa-aurum-initium.png`
- Create: `assets/capa-aurum-initium.webp` (convertido)

**Interfaces:**
- Consumes: nada.
- Produces: `assets/capa-aurum-initium.webp` — referenciado na Task 4 (front matter do post).

- [ ] **Step 1: Renomear com git mv**

```bash
git mv "assets/2026-06-12  -  02h08m.png" assets/capa-aurum-initium.png
```
Expected: arquivo renomeado, rastreado pelo git.

- [ ] **Step 2: Converter para WebP**

```bash
convert assets/capa-aurum-initium.png -quality 85 assets/capa-aurum-initium.webp
```
Expected: arquivo `capa-aurum-initium.webp` criado (ImageMagick 6.9+ com libwebp confirmado no ambiente).

- [ ] **Step 3: Verificar**

Run: `ls -la assets/capa-aurum-initium.png assets/capa-aurum-initium.webp && file assets/capa-aurum-initium.webp`
Expected: ambos existem; `.webp` reconhecido como WebP. A imagem órfã `assets/2026-06-12  -  02h05m.png` e `assets/auriuminitium.png` permanecem intactas.

- [ ] **Step 4: Commit** (aguardar autorização explícita do usuário)

```bash
git add assets/capa-aurum-initium.png assets/capa-aurum-initium.webp
git commit -m "chore: rename book cover image and add webp"
```

---

### Task 4: Front matter dos posts (description + image)

**Files:**
- Modify: `_posts/2026-08-15-aurum-initium.md`
- Modify: `_posts/2026-06-26-journal.md`

**Interfaces:**
- Consumes: `assets/capa-aurum-initium.webp` (Task 3).
- Produces: `page.description`/`page.image`/`page.image_alt` nos posts — consumidos pela Task 2 no `site-head.html`.

- [ ] **Step 1: Atualizar `_posts/2026-08-15-aurum-initium.md`**

Substituir o front matter (linhas 1-5) por:

```yaml
---
layout: posts
title: "O meu livro de matemática: Aurum Initium"
date: 2026-08-15
description: "Um livro de matemática elementar em construção: base sólida, tópicos conectados por intuição e interpretação geométrica."
image: "/assets/capa-aurum-initium.webp"
image_alt: "Captura do livro Aurum Initium"
---
```

E atualizar a referência da imagem no corpo (linha 7):

```markdown
![Captura do livro](/assets/capa-aurum-initium.webp)
```

- [ ] **Step 2: Atualizar `_posts/2026-06-26-journal.md`**

Adicionar `description` ao front matter (após `date`), mantendo as demais linhas:

```yaml
---
layout: posts
title: "ITA - 2022: z = 5 - 5i, f(n) = |z^(2n+1) + conjugado(z)^(2n+1)|"
date: 2026-06-26
description: "Resolução comentada de uma questão do ITA 2022 sobre números complexos: somatório de f(n) e potências de |z|."
---
```

(Sem `image` — cai no fallback `particles.png`.)

- [ ] **Step 3: Verificar build + tags por post**

Run: `bundle exec jekyll build && grep -o 'og:image[^>]*' _site/2026/08/15/aurum-initium.html`
Expected: `og:image` apontando para `/assets/capa-aurum-initium.webp`, sem width/height (imagem própria definida).

Run: `grep -o 'og:description[^>]*' _site/2026/06/26/journal.html`
Expected: description presente e sem espaços URL-encoded.

Run: `grep -o 'src="/assets/capa-aurum-initium.webp"' _site/2026/08/15/aurum-initium.html`
Expected: imagem do post referencia o WebP.

- [ ] **Step 4: Commit** (aguardar autorização explícita do usuário)

```bash
git add _posts/2026-08-15-aurum-initium.md _posts/2026-06-26-journal.md
git commit -m "feat: add per-post descriptions and open graph image"
```

---

### Task 5: Página `/projetos/` (cópia de `/posts/`) + navegação

**Files:**
- Create: `projetos/index.html` (usa o layout `archive` existente — padronização com `posts/index.html`)
- Modify: `_layouts/archive.html` (parametrizar meta de contagem via `page.archive_projects`)
- Modify: `_includes/site-nav.html` (link "Projetos" → `projetos_href`)
- Modify: `index.html` (passar `projetos_href="/#projetos"` no include do nav)
- Modify: `_layouts/projeto.html` (back-link → `/projetos/`)

**Interfaces:**
- Consumes: `_includes/project-card.html` (include existente, usado na home); layout `archive` (usado por `posts/index.html`).
- Produces: `site.projetos` listados em `/projetos/`; variável `projetos_href` do nav (default `/projetos/`); flag `page.archive_projects` consumida por `_layouts/archive.html`.

- [ ] **Step 1: Parametrizar `_layouts/archive.html`**

Inserir após `{% include site-nav.html %}` (linha 16) e ANTES do `<main>`:

```liquid
{% assign archive_projects = page.archive_projects | default: false %}
{% if archive_projects %}
  {% assign archive_count = site.projetos | size %}
  {% assign archive_icon = "bi-folder2" %}
  {% assign archive_label_pt = "projetos" %}
  {% assign archive_label_en = "projects" %}
{% else %}
  {% assign archive_count = site.posts | size %}
  {% assign archive_icon = "bi-journal-text" %}
  {% assign archive_label_pt = "publicações" %}
  {% assign archive_label_en = "posts" %}
{% endif %}
```

Substituir a linha 26 (meta do `post-header`) por:

```html
<span class="date"><i class="bi {{ archive_icon }}"></i> {{ archive_count }} <span data-en="{{ archive_label_en }}" data-pt="{{ archive_label_pt }}">{{ archive_label_pt }}</span></span>
```

- [ ] **Step 2: Criar `projetos/index.html`** (espelha `posts/index.html`)

```yaml
---
layout: archive
title: "Projetos"
description: "Projetos desenvolvidos por Kaylon Souza — aplicações web, mobile e desktop."
permalink: /projetos/
archive_projects: true
---
<p data-en="A complete list of projects developed by Kaylon Souza — web, mobile and desktop applications." data-pt="Lista completa de projetos desenvolvidos por Kaylon Souza — aplicações web, mobile e desktop.">Lista completa de projetos desenvolvidos por Kaylon Souza — aplicações web, mobile e desktop.</p>

<div class="project-list">
  {% assign featured_projects = site.projetos | where: "featured", true | sort: "path" %}
  {% assign regular_projects = site.projetos | where_exp: "p", "p.featured != true" | sort: "path" %}
  {% assign sorted_projects = featured_projects | concat: regular_projects %}
  {% for projeto in sorted_projects %}
    {% include project-card.html projeto=projeto %}
  {% endfor %}
</div>
```

- [ ] **Step 3: Atualizar `_includes/site-nav.html`**

Adicionar após a linha 3 (`{% assign posts_anchor = ... %}`):

```liquid
{% assign projetos_href = include.projetos_href | default: page.projetos_href | default: "/projetos/" %}
```

Substituir nas DUAS ocorrências de `{{ home_href | relative_url }}#projetos` (linha 18 mobile, linha 29 desktop):

```liquid
<a href="{{ projetos_href | relative_url }}" data-en="Projects" data-pt="Projetos">Projetos</a>
```

(Manter o `class="nav-more-nav"`/`<li>` wrappers exatamente como estão.)

- [ ] **Step 4: Atualizar `index.html` — nav com scroll na home**

Na chamada do include (linha 20), adicionar `projetos_href`:

```liquid
{% include site-nav.html posts_path="/" posts_anchor="#posts" projetos_href="/#projetos" %}
```

- [ ] **Step 5: Atualizar `_layouts/projeto.html` — back-link**

Substituir na linha 29:

```html
<a href="/#projetos" class="back-link">
```

por:

```html
<a href="/projetos/" class="back-link">
```

- [ ] **Step 6: Verificar build + navegação**

Run: `bundle exec jekyll build && grep -c 'project-card' _site/projetos/index.html`
Expected: 6 ocorrências (6 projetos via include `project-card`).

Run: `grep -o '6 <span data-en="projects" data-pt="projetos">projetos</span>' _site/projetos/index.html && grep -o 'data-en="posts" data-pt="publicações">publicações' _site/posts/index.html`
Expected: `/projetos/` mostra "6 projetos" (contagem da coleção); `/posts/` mantém "publicações" (padronização sem regressão).

Run: `grep -o 'href="/#projetos"' _site/index.html | wc -l`
Expected: ≥ 2 (desktop + mobile mantêm scroll na home).

Run: `grep -o 'href="/projetos/"' _site/2026/08/15/aurum-initium.html | wc -l && grep -o 'href="/projetos/"' _site/projetos/kaappli/index.html | wc -l`
Expected: nav do post aponta para `/projetos/` (≥ 2) e back-link do projeto também (≥ 1).

Run: `grep -c '/projetos/' _site/sitemap.xml`
Expected: `/projetos/` (a página) e os 6 projetos da coleção presentes no sitemap.

- [ ] **Step 7: Commit** (aguardar autorização explícita do usuário)

```bash
git add projetos/index.html _layouts/archive.html _includes/site-nav.html index.html _layouts/projeto.html
git commit -m "feat: add dedicated projects page"
```

---

### Task 6: CTA em posts e projetos

**Files:**
- Modify: `_layouts/posts.html` (inserir bloco antes do `<nav class="page-pager">`, linha 51)
- Modify: `_layouts/projeto.html` (inserir bloco antes do `<nav class="page-pager">`, linha 107)

**Interfaces:**
- Consumes: classes CSS existentes (`contact-section`, `contact-panel`, `contact-card`, `contact-links`, `section-heading`) — todas já usadas em `index.html` e definidas em `assets/site.css`.
- Produces: CTA bilíngue de contato no fim de cada post e projeto.

- [ ] **Step 1: Inserir CTA em `_layouts/posts.html`**

Inserir entre a linha 49 (`</div>` do `.post-content`) e a linha 51 (`<nav class="page-pager">`):

```html
    <section class="contact-section" aria-label="Contato">
        <div class="section-heading section-heading--left">
            <h2 data-en="Contact" data-pt="Contato">Contato</h2>
        </div>

        <div class="contact-panel contact-panel--featured">
            <div class="contact-intro">
                <div class="contact-status contact-status--centered">
                    <span data-en="Open to opportunities" data-pt="Aberto a oportunidades">Aberto a oportunidades</span>
                </div>
            </div>

            <div class="contact-links">
                <a class="contact-card" href="mailto:kaylon.contact@gmail.com">
                    <i class="bi bi-envelope"></i>
                    <div>
                        <div class="contact-card-label" data-en="Email" data-pt="E-mail">E-mail</div>
                        <div class="contact-card-value">kaylon.contact@gmail.com</div>
                    </div>
                </a>
                <a class="contact-card" href="https://github.com/kaaylooon" target="_blank" rel="noopener noreferrer">
                    <i class="bi bi-github"></i>
                    <div>
                        <div class="contact-card-label" data-en="GitHub" data-pt="GitHub">GitHub</div>
                        <div class="contact-card-value">kaaylooon</div>
                    </div>
                </a>
            </div>
        </div>
    </section>

```

- [ ] **Step 2: Inserir CTA em `_layouts/projeto.html`**

Inserir o MESMO bloco entre a linha 89 (`</section>` do `.project-content-section`) e a linha 91 (`{% assign ordered_projects = ... %}`), com indentação de 4 espaços (nível `.container`).

- [ ] **Step 3: Verificar build + CTA**

Run: `bundle exec jekyll build && grep -c 'contact-card' _site/2026/08/15/aurum-initium.html _site/projetos/kaappli/index.html`
Expected: ≥ 2 em cada (e-mail + GitHub).

Run: `grep -o 'Aberto a oportunidades' _site/2026/08/15/aurum-initium.html`
Expected: CTA bilíngue presente (pt default).

- [ ] **Step 4: Commit** (aguardar autorização explícita do usuário)

```bash
git add _layouts/posts.html _layouts/projeto.html
git commit -m "feat: add contact cta to posts and projects"
```

---

### Verificação final (pós-Task 6)

- [ ] `bundle exec jekyll build` exit 0, sem warnings.
- [ ] `_site/sitemap.xml` contém: `/`, `/about.html`, `/posts/`, `/projetos/`, 2 posts (`/2026/...`), 6 projetos (`/projetos/<slug>/`).
- [ ] Post `aurum-initium` tem `og:image` = `/assets/capa-aurum-initium.webp` e `article:published_time`.
- [ ] Post `journal` tem `og:description`; `og:image` fallback = `/assets/particles.png` com width/height.
- [ ] `/projetos/` renderiza os 6 projetos; nav da home mantém `/#projetos`; nav das demais páginas aponta `/projetos/`; back-link dos projetos aponta `/projetos/`.
- [ ] CTA presente no fim de posts e projetos.
- [ ] `git status`: apenas arquivos pretendidos (HTML, Markdown, CSS/asset, Gemfile, AGENTS.md). `assets/capa-aurum-initium.png/.webp` rastreados; `2026-06-12  -  02h08m.png` removido; órfãs intactas.