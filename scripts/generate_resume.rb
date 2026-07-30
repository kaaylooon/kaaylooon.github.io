#!/usr/bin/env ruby
# frozen_string_literal: true

require "date"
require "fileutils"
require "tmpdir"
require "yaml"

ROOT = File.expand_path("..", __dir__)
PROJECTS_DIR = File.join(ROOT, "_projetos")
CONFIG_PATH = File.join(ROOT, "_config.yml")
DATA_PATH = File.join(ROOT, "_data", "resume.yml")
OUTPUT_DIR = File.join(ROOT, "assets", "resume")
OUTPUT_TEX = File.join(OUTPUT_DIR, "kaylon-souza-cv.tex")
OUTPUT_PDF = File.join(OUTPUT_DIR, "kaylon-souza-cv.pdf")

def parse_front_matter(path)
  content = File.read(path)
  match = content.match(/\A---\s*\n(.*?)\n---\s*\n?(.*)\z/m)
  raise "front matter ausente em #{path}" unless match

  data = YAML.safe_load(match[1], permitted_classes: [Date], aliases: true) || {}
  [data, match[2].to_s]
end

def slug_from(path)
  File.basename(path, File.extname(path))
end

def clean_markdown_line(line)
  value = line.dup
  value.gsub!(/`([^`]+)`/, "\\1")
  value.gsub!(/\[([^\]]+)\]\([^)]+\)/, "\\1")
  value.gsub!(/\*\*([^*]+)\*\*/, "\\1")
  value.gsub!(/\*([^*]+)\*/, "\\1")
  value.gsub!(/_([^_]+)_/, "\\1")
  value.gsub!(/\s+/, " ")
  value.strip
end

def extract_bullets(body)
  body.each_line.filter_map do |line|
    next unless line.lstrip.start_with?("- ")

    item = clean_markdown_line(line.sub(/^\s*-\s+/, ""))
    item unless item.empty?
  end
end

def extract_summary(body, fallback)
  paragraph = body.split(/\n{2,}/).map { |chunk| clean_markdown_line(chunk) }.find { |chunk| !chunk.empty? }
  paragraph.nil? || paragraph.empty? ? fallback.to_s : paragraph
end

LATEX_ESCAPE_MAP = {
  "\\" => "\\textbackslash{}",
  "{" => "\\{",
  "}" => "\\}",
  "$" => "\\$",
  "&" => "\\&",
  "#" => "\\#",
  "%" => "\\%",
  "_" => "\\_",
  "~" => "\\textasciitilde{}",
  "^" => "\\textasciicircum{}"
}.freeze

def latex_escape(text)
  text.to_s.gsub(/[\\{}$&#%_~^]/) { |char| LATEX_ESCAPE_MAP.fetch(char) }
end

def render_header(person)
  contact_line = []
  contact_line << "\\raisebox{-0.1\\height}\\faPhone\\ #{latex_escape(person.fetch("phone"))}"
  contact_line << "\\href{mailto:#{latex_escape(person.fetch("email"))}}{\\raisebox{-0.2\\height}\\faEnvelope\\ \\underline{#{latex_escape(person.fetch("email"))}}}"

  header_links = []
  if person["website"]
    header_links << "\\href{#{latex_escape(person.dig("website", "url"))}}{\\raisebox{-0.2\\height}\\faGlobe\\ \\underline{#{latex_escape(person.dig("website", "label"))}}}"
  end
  header_links << "\\href{#{latex_escape(person.dig("linkedin", "url"))}}{\\raisebox{-0.2\\height}\\faLinkedin\\ \\underline{#{latex_escape(person.dig("linkedin", "label"))}}}"
  header_links << "\\href{#{latex_escape(person.dig("github", "url"))}}{\\raisebox{-0.2\\height}\\faGithub\\ \\underline{#{latex_escape(person.dig("github", "label"))}}}"

  <<~LATEX
    \\begin{center}
        {\\Huge \\scshape #{latex_escape(person.fetch("name"))}} \\\\ \\vspace{1pt}
        #{latex_escape(person.fetch("location"))} \\\\ \\vspace{1pt}
        \\small #{contact_line.join(" ~\n        ")} \\\\
        #{header_links.join(" ~\n        ")}
        \\vspace{-8pt}
    \\end{center}
  LATEX
end

def render_projects(projects)
  lines = []
  lines << "\\section{Projetos}"
  lines << "\\resumeSubHeadingListStart"

  projects.each do |project|
    techs = Array(project["technologies"]).map { |item| latex_escape(item) }.join(", ")
    project_title = "\\textbf{#{latex_escape(project.fetch("title"))}}"
    if project["url"] && !project["url"].empty?
      project_title = "\\href{#{latex_escape(project.fetch("url"))}}{#{project_title}}"
    end
    heading = project_title
    heading = "#{heading} | \\emph{#{techs}}" unless techs.empty?
    lines << "\\resumeProjectHeading{#{heading}}{#{latex_escape(project.fetch("date", ""))}}"
    lines << "\\resumeItemListStart"
    Array(project["bullets"]).each do |bullet|
      lines << "  \\resumeItem{#{latex_escape(bullet)}}"
    end
    lines << "\\resumeItemListEnd"
    lines << ""
  end

  lines << "\\resumeSubHeadingListEnd"
  lines.join("\n")
end

def render_skills(skills)
  body = skills.map do |group|
    "\\textbf{#{latex_escape(group.fetch("label"))}}{: #{latex_escape(Array(group["items"]).join(", "))}} \\\\"
  end.join("\n ")

  <<~LATEX
    \\section{Competências Técnicas}
    \\begin{itemize}[leftmargin=0.15in, label={}]
    \\small{\\item{
     #{body}
    }}
    \\end{itemize}
  LATEX
end

def render_extras(extras)
  body = extras.map do |item|
    "\\textbf{#{latex_escape(item.fetch("label"))}:} #{latex_escape(item.fetch("value"))} \\\\"
  end.join("\n\n ")

  <<~LATEX
    \\section{Habilidades Extras}
    \\begin{itemize}[leftmargin=0.15in, label={}]
    \\small{\\item{
     #{body}
    }}
    \\end{itemize}
  LATEX
end

def render_education(education)
  lines = []
  lines << "\\section{Formação}"
  lines << "\\resumeSubHeadingListStart"
  education.each do |item|
    lines << "  \\resumeSubheading"
    lines << "      {#{latex_escape(item.fetch("institution"))}}{#{latex_escape(item.fetch("period"))}}"
    lines << "      {#{latex_escape(item.fetch("degree"))}}{#{latex_escape(item.fetch("location"))}}"
  end
  lines << "\\resumeSubHeadingListEnd"
  lines.join("\n")
end

def build_site_url(base_url, page_url)
  normalized_base = base_url.to_s.sub(%r{/\z}, "")
  normalized_page = page_url.to_s.start_with?("/") ? page_url.to_s : "/#{page_url}"
  "#{normalized_base}#{normalized_page}"
end

def build_project_entry(slug, front_matter, body, override)
  bullets = Array(override["bullets"])
  bullets = extract_bullets(body) if bullets.empty?
  bullets = [extract_summary(body, front_matter["description"])] if bullets.empty?

  {
    "slug" => slug,
    "title" => override["title"] || front_matter.fetch("title"),
    "date" => override["date"] || front_matter["date"] || front_matter["status"] || "",
    "url" => override["url"] || front_matter["project_url"] || build_site_url(SITE_URL, front_matter["permalink"] || "/projetos/#{slug}/"),
    "technologies" => override["technologies"] || front_matter["stack"].to_s.split(/[·|]/).map(&:strip).reject(&:empty?),
    "bullets" => bullets
  }
end

site_config = YAML.safe_load(File.read(CONFIG_PATH), permitted_classes: [Date], aliases: true) || {}
SITE_URL = build_site_url(site_config["url"], site_config["baseurl"])
resume_data = YAML.safe_load(File.read(DATA_PATH), permitted_classes: [Date], aliases: true)
include_slugs = Array(resume_data.dig("projects", "include"))
overrides = resume_data.dig("projects", "overrides") || {}

project_paths = Dir[File.join(PROJECTS_DIR, "*.md")].each_with_object({}) do |path, acc|
  acc[slug_from(path)] = path
end

projects = include_slugs.map do |slug|
  path = project_paths[slug]
  next unless path

  front_matter, body = parse_front_matter(path)
  build_project_entry(slug, front_matter, body, overrides.fetch(slug, {}))
end.compact

missing = include_slugs - projects.map { |project| project["slug"] }
raise "projetos ausentes no currículo: #{missing.join(', ')}" unless missing.empty?

latex = <<~LATEX
  \\documentclass[letterpaper,11pt]{article}

  \\usepackage{latexsym}
  \\usepackage[empty]{fullpage}
  \\usepackage{titlesec}
  \\usepackage{marvosym}
  \\usepackage[usenames,dvipsnames]{color}
  \\usepackage{enumitem}
  \\usepackage[hidelinks]{hyperref}
  \\usepackage{fancyhdr}
  \\usepackage[portuguese]{babel}
  \\usepackage{tabularx}
  \\usepackage{fontawesome5}
  \\usepackage{multicol}
  \\setlength{\\multicolsep}{-3.0pt}
  \\setlength{\\columnsep}{-1pt}
  \\input{glyphtounicode}
  \\hypersetup{
    pdftitle={Kaylon Souza - Currículo},
    pdfauthor={Kaylon Souza},
    pdfsubject={Currículo técnico},
    pdfkeywords={Kaylon Souza, currículo, personal page, Node.js, Python, TypeScript, React Native, Flask, JavaScript, software}
  }

  \\pagestyle{fancy}
  \\fancyhf{}
  \\fancyfoot{}
  \\renewcommand{\\headrulewidth}{0pt}
  \\renewcommand{\\footrulewidth}{0pt}

  \\addtolength{\\oddsidemargin}{-0.6in}
  \\addtolength{\\evensidemargin}{-0.5in}
  \\addtolength{\\textwidth}{1.19in}
  \\addtolength{\\topmargin}{-.7in}
  \\addtolength{\\textheight}{1.4in}

  \\urlstyle{same}
  \\raggedbottom
  \\raggedright
  \\setlength{\\tabcolsep}{0in}

  \\titleformat{\\section}{
    \\vspace{-4pt}\\scshape\\raggedright\\large\\bfseries
  }{}{0em}{}[\\color{black}\\titlerule \\vspace{-5pt}]

  \\pdfgentounicode=1

  \\newcommand{\\resumeItem}[1]{
    \\item\\small{{#1 \\vspace{-2pt}}}
  }
  \\newcommand{\\resumeSubheading}[4]{
    \\vspace{-2pt}\\item
      \\begin{tabular*}{1.0\\textwidth}[t]{l@{\\extracolsep{\\fill}}r}
        \\textbf{#1} & \\textbf{\\small #2} \\\\
        \\textit{\\small #3} & \\textit{\\small #4} \\\\
      \\end{tabular*}\\vspace{-7pt}
  }
  \\newcommand{\\resumeProjectHeading}[2]{
      \\item
      \\begin{tabular*}{1.001\\textwidth}{l@{\\extracolsep{\\fill}}r}
        \\small#1 & \\textbf{\\small #2}\\\\
      \\end{tabular*}\\vspace{-7pt}
  }
  \\newcommand{\\resumeSubHeadingListStart}{\\begin{itemize}[leftmargin=0.0in, label={}]}
  \\newcommand{\\resumeSubHeadingListEnd}{\\end{itemize}}
  \\newcommand{\\resumeItemListStart}{\\begin{itemize}}
  \\newcommand{\\resumeItemListEnd}{\\end{itemize}\\vspace{-5pt}}

  \\begin{document}

  #{render_header(resume_data.fetch("person"))}

  \\section{Resumo}
  #{latex_escape(resume_data.fetch("summary"))}

  #{render_education(Array(resume_data["education"]))}

  #{render_projects(projects)}

  #{render_skills(Array(resume_data["skills"]))}

  #{render_extras(Array(resume_data["extras"]))}

  \\end{document}
LATEX

FileUtils.mkdir_p(OUTPUT_DIR)
File.write(OUTPUT_TEX, latex)

tmp_dir = Dir.mktmpdir("resume-build-")
begin
  FileUtils.cp(OUTPUT_TEX, File.join(tmp_dir, File.basename(OUTPUT_TEX)))
  Dir.chdir(tmp_dir) do
    system("pdflatex", "-interaction=nonstopmode", File.basename(OUTPUT_TEX), out: File::NULL, err: File::NULL) or raise "falha ao compilar PDF"
  end

  built_pdf = File.join(tmp_dir, File.basename(OUTPUT_PDF))
  raise "PDF não foi gerado" unless File.exist?(built_pdf)

  FileUtils.cp(built_pdf, OUTPUT_PDF)
ensure
  FileUtils.remove_entry(tmp_dir)
end

puts "Gerado:"
puts "  #{OUTPUT_TEX}"
puts "  #{OUTPUT_PDF}"
