open Js.Array2

let nonEmptyString = s => s != ""

let regexChunks = %re("/(.+?[\.,!;:])\s/")

let regexWords = %re("/\s+/")

let getTextFromPassage = (passage: Model.passage) => {
  passage.verses->map(v => v.text)->joinWith(" ")
}

let getPassageById = (passages: array<Model.passage>, id: int) => {
  passages->find(p => p.id == id)
}

let getCustomSplitText = (str, regex: Js.Re.t) => {
  str
  ->Js.String2.splitByRe(regex)
  ->map(Js.Option.getWithDefault(""))
  ->map(String.trim)
  ->filter(nonEmptyString)
}

let getChunksFromText = str => {
  str->getCustomSplitText(regexChunks)
}

let createWord = (str, index) => {
  let word: Model.word = {text: str, visible: index !== 0 && mod(index, 5) !== 0} // Make the first word and every fifth word after that invisible.
  word
}

let getWordsFromText = str => {
  str->getCustomSplitText(regexWords)->mapi(createWord)
}

let getWordsFromPassage = (passage: Model.passage) => {
  passage->getTextFromPassage->getWordsFromText
}

let getChunksFromPassage = (passage: Model.passage) => {
  passage->getTextFromPassage->getChunksFromText
}

// if anything goes wrong, redirect to the passages list
let getPassageForPage = (router: Next.Router.router, passages: array<Model.passage>) => {
  open Belt

  Js.Dict.get(router.query, "id")
  ->Option.flatMap(Belt.Int.fromString)
  ->Option.flatMap(id => getPassageById(passages, id))
}
