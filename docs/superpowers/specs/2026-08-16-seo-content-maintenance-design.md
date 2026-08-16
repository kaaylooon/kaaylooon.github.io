# Design: SEO, Conteúdo e Manutenção do Site

**Data**: 2026-08-16
**Escopo**: Implementar as melhorias válidas apontadas numa revisão do site, nas áreas de SEO/Open Graph, sitemap, página de projetos, CTAs e imagens.

## Contexto

Revisão externa listou 8 recomendações. Após auditoria do código, parte era válida, parte já estava resolvida:

**Válido e a implementar**
1. Open Graph por página (posts/projetos sem `description`/`image` próprias; hoje tudo usa og:image global `particles.png`).
2. Sitemap não inclui `site.posts` (bug real — os posts não aparecem no sitemap).
3. Não existe página centralizada `/projetos/`.
4. Posts e projetos sem CTA de contato.
5. Imagem do post do livro com nome não-descritivo e espaços URL-encoded.

**Já resolvido / questionável (não implementar)**
- `github_username` no `_config.yml`: convenção do tema Minima; sozinho não melhora ranking. Implementar apenas `author` + `github_username` como metadados honestos (não como "SEO mágico").
- `generate_resume.rb`: já automatizado (lê `_projetos` + `_data/resume.yml`, gera `.tex`, compila PDF via `pdflatex`). Sem mudanças.
- Acessibilidade: layouts já usam `<main>`, `<article>`, `<footer>`, `aria-label`, nav semântica. Sem mudanças.

## Decisões (aprovadas pelo usuário)

| Decisão | Escolha |
|---|---|
| Sitemap | Plugin `jekyll-sitemap` + criação de `Gemfile`; remover `sitemap.xml` manual (o plugin gera na build) |
| Nav "Projetos" | Home mantém scroll para `/#projetos`; demais páginas apontam para `/projetos/` |
| Imagens órfãs (`2026-06-12  -  02h05m.png`, `auriuminitium.png`) | Manter no repo (não deletar) |

## Workstreams

### WS1 — SEO & Open Graph por página

- **`_config.yml`**: adicionar `author: Kaylon Souza`, `github_username: kaaylooon`, `linkedin_username: kaylonsouza`, e `plugins: [jekyll-sitemap]`.
- **`_includes/site-head.html`**:
  - `og:image` por página: `page.image` (com `| absolute_url`), fallback `/assets/particles.png`; adicionar `og:image:alt`.
  - `og:locale` por página: `page.lang` mapeado (`pt` → `pt_BR`, `en` → `en_US`), fallback `pt_BR`.
  - Tags `article:published_time` / `article:modified_time` quando `og_type == article` (posts e projetos), usando `page.date` e `page.last_modified_at | default: page.date`.
  - JSON-LD `sameAs` passa a ler de `_config.yml` (`github_username`, `linkedin_username`), mantendo os URLs reais atuais.
- **Posts**:
  - `2026-08-15-aurum-initium.md`: adicionar `description` e `image: /assets/capa-aurum-initium.webp`.
  - `2026-06-26-journal.md`: adicionar `description` (sem imagem → fallback `particles.png`).
- **Projetos**: já possuem `description`/`image` — nada a mudar; passam a emitir og:image própria.

### WS2 — Sitemap via plugin

- Criar `Gemfile` com `gem "jekyll"` e `gem "jekyll-sitemap"` (mais `webrick` para servir localmente em Ruby ≥ 3). Instalar via `bundle install`.
- Adicionar `plugins: [jekyll-sitemap]` no `_config.yml`.
- Remover `sitemap.xml` manual (o plugin gera `sitemap.xml` na build cobrindo pages, posts e collections).
- **`AGENTS.md`**: atualizar a seção de comandos — `bundle exec jekyll serve`/`bundle exec jekyll build` passam a ser o wrapper preferido (o próprio AGENTS.md previa isso).
- `_config.yml` já exclui `Gemfile`/`Gemfile.lock` da build (`exclude`) — mantido.

### WS3 — Página `/projetos/`

- **Padronização (decisão do usuário)**: `projetos/index.html` é uma cópia estrutural de `posts/index.html`, reutilizando o layout `archive` — mesma estrutura, mesmo estilo de lista, conteúdo diferente.
- **`_layouts/archive.html`**: parametrizar a meta de contagem — se `page.archive_projects` for `true`, mostra `site.projetos | size` com ícone `bi-folder2` e rótulos "projetos"/"projects"; caso contrário mantém o comportamento atual (posts, `bi-journal-text`, "publicações"/"posts"). `posts/index.html` não muda (defaults idênticos ao comportamento atual).
- Novo **`projetos/index.html`**: front matter `layout: archive`, `archive_projects: true`, `title: "Projetos"`, `description`, `permalink: /projetos/`; conteúdo: parágrafo intro + `<div class="project-list">` com o grid de `project-card.html` (mesma include da home).
- **`_includes/site-nav.html`**: variável `projetos_href` (default `/projetos/`); `index.html` passa `projetos_href: "/#projetos"` para manter scroll na home. Aplicar nos dois pontos do nav (desktop `.nav-links` e mobile `.nav-more-nav`).
- **`_layouts/projeto.html`**: back-link "Voltar" passa de `/#projetos` para `/projetos/`.
- **`_includes/site-footer.html`**: sem mudanças.

### WS4 — CTA em posts e projetos

- **`_layouts/posts.html`** e **`_layouts/projeto.html`**: bloco de contato no fim do `<main>`, antes do pager — card bilíngue (`data-pt`/`data-en`) com e-mail e GitHub, reutilizando as classes `contact-card`/`contact-panel` existentes no `site.css`.

### WS5 — Imagem do post do livro

- `git mv "assets/2026-06-12  -  02h08m.png"` → `assets/capa-aurum-initium.png`.
- Converter para `assets/capa-aurum-initium.webp` via ImageMagick (`convert -quality 85`). PNG original mantido no repo (fonte), post referencia o `.webp`.
- Atualizar `_posts/2026-08-15-aurum-initium.md` para referenciar `/assets/capa-aurum-initium.webp`.
- Manter órfãs (`2026-06-12  -  02h05m.png`, `auriuminitium.png`) intactas.

## Fora de escopo

- Conversão em massa de imagens de projetos para WebP.
- Deletar imagens órfãs.
- Mudanças em `generate_resume.rb`.
- Melhorias de acessibilidade (já adequada).

## Verificação

- `bundle exec jekyll build` sem erros.
- `_site/sitemap.xml` gerado pelo plugin, contendo: `/`, `/about.html`, `/posts/`, `/projetos/`, todos os posts (`/2026/...`) e projetos.
- Páginas de posts com `og:image`/`og:description`/`article:published_time` corretos no HTML gerado.
- `/projetos/` renderizando grid com todos os 6 projetos.
- Home: nav "Projetos" mantém `/#projetos`; demais páginas apontam para `/projetos/`.
- Post do livro referencia `.webp` e o arquivo existe.
- `git status` mostra apenas arquivos pretendidos (HTML, Markdown, CSS, imagem, Gemfile, AGENTS.md).