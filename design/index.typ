// Build the design book: npm run design:pdf (from the repository root).
// The order comes from index.md: each "## Part ..." heading starts a part and
// each linked chapter below it is rendered, in order, with cmarker.
#import "@preview/cmarker:0.1.10"

#let sans = ("Inter", "Inter Display", "Noto Sans", "DejaVu Sans", "Liberation Sans")
#let mono = ("DejaVu Sans Mono", "Liberation Mono")

// Dark palette. The logo is a monochrome rendition of branding/sekkos.svg in
// assets/sekkos-logo.svg, tinted #555555 for this cover.
#let bg = rgb("#111111")
#let ink = rgb("#fafafa")
#let muted = rgb("#9a9a9a")
#let faint = rgb("#6f6f6f")
#let rule-color = rgb("#303030")
#let surface = rgb("#1a1a1a")
#let accent = rgb("#b69cff")
#let code-ink = rgb("#e5dcff")

// Remove a leading YAML frontmatter block, if a chapter gains one later.
#let strip-frontmatter(s) = {
  if s.starts-with("---\n") or s.starts-with("---\r\n") {
    let parts = s.split(regex("\r?\n---\r?\n"))
    parts.slice(1).join("\n---\n")
  } else { s }
}

// Normalise a relative path such as services/../system-design/architecture.md.
#let normalise(p) = {
  let out = ()
  for s in p.split("/") {
    if s == "" or s == "." { continue }
    if s == ".." { if out.len() > 0 { let _ = out.pop() } } else { out.push(s) }
  }
  out.join("/")
}

#let dir-of(p) = {
  let i = p.split("/")
  if i.len() < 2 { "" } else { i.slice(0, i.len() - 1).join("/") }
}

#let index-src = strip-frontmatter(read("index.md"))
#let title = {
  let m = index-src.match(regex("(?m)^# +(.+?)\s*$"))
  if m == none { "Design" } else { m.captures.at(0) }
}

// Parts come from the index headings; chapters come from the linked list under
// each heading. Part folders have descriptive names; the roman numerals used in
// the book come from the heading order, so rearranging parts cannot desync them.
#let roman = ("I", "II", "III", "IV", "V", "VI", "VII", "VIII", "IX", "X")
#let parts = {
  let out = ()
  for raw in index-src.split("\n") {
    let line = raw.trim()
    let p = line.match(regex("^## Part [IVXL]+ — (.+?)\s*$"))
    if p != none {
      out.push((numeral: roman.at(out.len(), default: ""), name: p.captures.at(0), chapters: ()))
      continue
    }
    let c = line.match(regex("^-\s+\[(.+?)\]\((.+?\.md)\)(?:\s+—.*)?$"))
    if c != none and out.len() > 0 {
      let last = out.pop()
      last.chapters.push((title: c.captures.at(0), path: normalise(c.captures.at(1))))
      out.push(last)
    }
  }
  out
}

// Look up a part's numeral by its title for the running part heading.
#let numeral-for(name) = {
  for part in parts {
    if part.name == name { return part.numeral }
  }
  ""
}

// GitHub-style heading slugs, matching cmarker's heading-labels default.
#let slug(s) = s.lower().replace(regex("[^a-z0-9 _-]"), "").replace(" ", "-")

// Links to chapters become links inside the PDF; web links stay web links.
// Links to source files outside the design book remain plain text.
#let chapter-link(dir, path) = (dest, ..args) => {
  let body = args.pos().at(0, default: none)
  if type(dest) != str or dest.starts-with("http:") or dest.starts-with("https:") or dest.starts-with("mailto:") {
    return link(dest, ..args)
  }
  if dest.starts-with("#") {
    let name = path + ":" + slug(dest.slice(1))
    return context {
      if query(label(name)).len() > 0 { link(label(name), body) } else { body }
    }
  }
  let (file, ..anchor) = dest.split("#")
  if file == "" { return body }
  let target = normalise(if dir == "" { file } else { dir + "/" + file })
  if not target.ends-with(".md") { target += ".md" }
  let name = if anchor.len() > 0 { target + ":" + slug(anchor.at(0)) } else { target }
  context {
    if query(label(name)).len() > 0 { link(label(name), body) } else { body }
  }
}

#let chapter-image(dir) = (src, ..args) => {
  let p = if src.starts-with("/") { src } else { "design/" + normalise(if dir == "" { src } else { dir + "/" + src }) }
  image(p, ..args)
}

// Status lives in a blockquote metadata block; read it without forcing every
// chapter to adopt YAML frontmatter.
#let status-of(src) = {
  let m = src.match(regex("(?m)^>\s*\*\*Status:\*\*\s*(.+?)\s*$"))
  if m == none { none } else { m.captures.at(0) }
}

#let updated-of(src) = {
  let m = src.match(regex("(?m)^>\s*\*\*Last updated:\*\*\s*(.+?)\s*$"))
  if m == none { none } else { m.captures.at(0) }
}

#set document(title: title, author: "SekkOS")
#set text(font: sans, size: 10.5pt, lang: "en", fill: ink)
#set par(justify: false, leading: 0.7em, spacing: 1.05em)
#set heading(numbering: none)
#show heading: set text(weight: "semibold", fill: ink)
#show heading.where(level: 1): it => {
  pagebreak(weak: true)
  v(1.5em)
  block(below: 1.4em, width: 100%)[
    #text(11pt, fill: accent, weight: "bold", tracking: 1.2pt)[PART #numeral-for(if it.body.has("text") { it.body.text } else { "" })]
    #v(0.4em)
    #text(30pt, weight: "bold", fill: ink)[#it.body]
    #v(0.3em)
    #line(length: 100%, stroke: 1pt + accent)
  ]
}
#show heading.where(level: 2): it => {
  v(1.4em)
  block(width: 100%, stroke: (left: 2pt + accent), inset: (left: 9pt), below: 0.7em)[
    #text(19pt, weight: "semibold", fill: ink)[#it.body]
  ]
}
#show heading.where(level: 3): it => {
  v(1.1em)
  text(14pt, weight: "semibold", fill: ink, it)
  v(0.3em)
}
#show raw: set text(font: mono, size: 9pt, fill: code-ink)
#show raw.where(block: true): block.with(fill: surface, stroke: 0.5pt + rule-color, inset: 9pt, radius: 3pt, width: 100%)
#show quote: it => block(width: 100%, inset: (left: 9pt), stroke: (left: 1.5pt + faint))[
  #set text(fill: muted, size: 9.5pt)
  #it
]
#show link: set text(fill: accent)
#show table: set text(size: 9pt, fill: ink)
#set table(stroke: 0.5pt + rule-color, inset: 6pt, fill: rgb("#151515"))
#show table.cell.where(y: 0): set text(weight: "bold", fill: accent, size: 9pt)
#set list(indent: 1em)
#set enum(indent: 1em)

// Cover: logo from ./assets (a monochrome copy of branding/sekkos.svg),
// title anchored to the lower left.
#page(paper: "a4", fill: bg, margin: (x: 2.4cm, y: 2.4cm), numbering: none)[
  #grid(
    columns: (1fr,),
    rows: (1fr, auto),
    align(center + horizon)[#image("assets/sekkos.svg", width: 8.5cm)],
    align(bottom + left)[
      #text(38pt, weight: "bold", fill: ink)[#title]
      #v(0.35em)
      #text(11pt, fill: muted)[Design source of truth · #datetime.today().display("[day] [month repr:long] [year]")]
    ],
  )
]

#set page(paper: "a4", fill: bg, margin: (x: 2.2cm, y: 2.4cm), numbering: "1",
  footer: context [
    #text(8.5pt, fill: faint)[#title #h(1fr) #counter(page).display()]
  ])

#text(24pt, weight: "bold", fill: ink)[Contents]
#v(1em)
#outline(title: none, depth: 2, indent: auto)

#for part in parts {
  heading(level: 1, numbering: none)[#part.name]
  for chapter in part.chapters {
    let dir = dir-of(chapter.path)
    let src = read(chapter.path)
    let (_, body) = cmarker.render-with-metadata(
      src,
      metadata-block: "frontmatter-yaml",
      h1-level: 2,
      set-document-title: false,
      label-prefix: chapter.path + ":",
      scope: (
        link: chapter-link(dir, chapter.path),
        image: chapter-image(dir),
      ),
    )
    [#metadata(chapter.path)#label(chapter.path)]
    body
    let status = status-of(src)
    let updated = updated-of(src)
    if status != none or updated != none {
      align(right)[
        #text(8.5pt, fill: faint)[
          #if status != none [#status] #if status != none and updated != none [ · ] #if updated != none [Updated #updated]
        ]
      ]
    }
  }
}
