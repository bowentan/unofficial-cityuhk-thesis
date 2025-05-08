#import "@preview/hydra:0.6.1": hydra, selectors.custom

#import "front-page.typ": *

#set document(
  title: [CityU HK PhD Thesis Template],
  author: "Bowen Tan",
  date: none,
)

#let chapter = heading.with(level: 1, offset: 0, supplement: [Chapter])

// HACK: workaround for incorrect jumping from ref to figures when `placement` is set
// See issue here: https://github.com/typst/typst/issues/4359
#let fig-place(placement, body) = {
  place(placement, float: true, scope: "parent", body)
}

#let thesis(
  title: (en: none, zh: none),
  author: (firstname: none, surname: none, firstname-zh: none, surname-zh: none),
  dept: (en: none, zh: none),
  degree: (en: none, zh: none, abbr: none),
  date: (en: none, zh: none),
  supervisor: (title: none, name: none, dept: none, university: none),
  panel-members: (),
  examiners: (),
  abstract: none,
  ack: none,
  bib: bibliography,
  extras: none,
  body,
) = {
  set page(
    "a4",
    margin: (top: 42mm, bottom: 42mm, left: 32.7mm, right: 32.7mm),
    numbering: "i",
  )
  set text(
    font: "Times New Roman",
    size: 12pt,
  )

  make-title-page(
    title: title,
    author: author,
    dept: dept,
    degree: degree,
    date: date,
  )

  make-abstract-page(abstract)

  make-panel-page(
    author: (
      surname: author.surname,
      firstname: author.firstname,
    ),
    degree: degree.en,
    dept: dept.en,
    supervisor: supervisor,
    panel-members: panel-members,
    examiners: examiners,
  )

  make-ack-page(ack)

  make-toc()

  make-list-of-figures()

  make-list-of-tables()

  set page(numbering: "1")
  counter(page).update(1)

  set par(leading: 0.75em, justify: true, spacing: 1em, first-line-indent: 1.5em)

  // For figure and tables
  set figure.caption(separator: " ")
  show figure.caption: it => {
    set align(left)
    set par(justify: true, leading: 0.5em)
    it
  }
  show figure.where(kind: image): set figure(
    supplement: [Fig.],
    numbering: (..nums) => box[#context counter(heading.where(level: 1)).at(here()).first().#nums.at(0)],
  )
  show figure.where(kind: table): set figure(
    supplement: [Table],
    numbering: (..nums) => box[#context counter(heading.where(level: 1)).at(here()).first().#nums.at(0)],
  )

  //For equations
  set math.equation(
    numbering: (..n) => box[
      (#context counter(heading.where(level: 1)).get().first().#n.at(0))
    ],
  )
  show ref: it => context {
    let el = it.element
    if el != none and el.func() == math.equation {
      link(
        el.location(),
        box[
          Equation
          #counter(heading.where(level: 1)).at(el.location()).first().#counter(math.equation).at(el.location()).first()
        ],
      )
    } else {
      // Other references as usual.
      it
    }
  }

  // For chapters
  let chapter-sel = heading.where(level: 1)
  show chapter-sel: it => {
    pagebreak(weak: true)

    // counter(heading).step()
    counter(figure.where(kind: image)).update(0)
    counter(figure.where(kind: table)).update(0)
    // counter(math.equation).update(0)

    set align(left)
    block(inset: (top: 4.2em, bottom: 1em))[
      // #v(7em)
      #set text(size: 25pt)
      #set par(first-line-indent: 0em)
      *Chapter #counter(heading).display(it.numbering)*
      #linebreak()
      #v(0.6em)
      *#it.body*
      // #v(1.4em)
    ]
  }

  let display-chapter(ctx, chapter) = {
    [Chapter ]
    if chapter.has("numbering") and chapter.numbering != none {
      numbering(chapter.numbering, ..counter(chapter-sel).at(chapter.location()))
      [. ]
    }
    chapter.body
  }
  set page(
    header: context if calc.even(counter(page).get().first()) {
      let chap = hydra(chapter-sel, display: display-chapter)
      let sec = hydra(custom(heading.where(level: 1), ancestors: chapter-sel))

      set align(left)
      chap
      // if chap != none and sec != none [ --- ]
      // sec
    } else {
      align(right, hydra(custom(heading.where(level: 2), ancestors: chapter-sel), use-last: true))
    },
  )

  set heading(offset: 1, numbering: "1.1")
  show heading.where(offset: 1): it => {
    set text(size: calc.max(17pt - 2.5pt * (it.level - 2), 12pt))
    if it.level <= 3 {
      block(inset: (top: 0.7em, bottom: 0.5em))[
        #counter(heading).display(it.numbering) #h(0.8em) #it.body
      ]
    } else {
      block(inset: (top: 0em, bottom: 0.8em))[
        #it.body
      ]
    }
  }

  set enum(indent: 1.2em)

  body

  pagebreak()

  // For reference sections
  set heading(offset: 0, numbering: none)
  show heading.where(level: 1): it => [
    #v(4.5em)
    #set text(size: 25pt)
    #it.body
    #v(0.6em)
  ]
  set page(header: none)
  if bib != none { bib }

  if extras != none {
    pagebreak()
    extras
  }
}

