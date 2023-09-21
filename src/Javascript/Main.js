//
// | (• ◡•)| (❍ᴥ❍ʋ)


import * as odd from "@oddjs/odd"
import * as fission from "@oddjs/odd/compositions/fission"


// 🚀

const Elm = /** @type {*} */ (window).Elm

/** @type {*} */
const elm = Elm.Main.init({
  flags: {
    currentTime: Date.now()
  }
})

/** @type {odd.FileSystem | null} */
let fs

/** @type {odd.AppInfo} */
const appInfo = { creator: "icidasset", name: "Quotes" }

/** @type {odd.Configuration} */
const config = {
  namespace: appInfo,
  debug: true,
}

const components = await fission.components(config, { environment: "development" })

odd
  .program(config, components)
  .then(async program => {
    let { has } = await program.authority.has([
      odd.authority.account,
      odd.authority.fileSystem.rootAccess
    ])

    console.log("Connected:", has)

    // @ts-ignore
    window.program = program

    // Continue initialisation process in Elm app
    elm.ports.initialise.send({
      authenticated: has,
    })

    // The file system,
    // we'll use this later (see CRUD functions below)
    fs = await program.fileSystem.load(
      await program.account.volume()
    )

    // Communicate with Elm app
    elm.ports.addQuote.subscribe(addQuote)
    elm.ports.removeQuote.subscribe(removeQuote)
    elm.ports.saveSelectionHistory.subscribe(saveSelectionHistory)
    elm.ports.signIn.subscribe(() => { /* TODO */ })
    elm.ports.triggerRepaint.subscribe(triggerRepaint)

    // Continue Elm initialisation
    elm.ports.loadUserData.send({
      quotes: await loadQuotes(),
      selectionHistory: await retrieveSelectionHistory(),
    })

  })



// CRUD


/**
 * @typedef {Object} Quote
 * @property {string} id
 */

/** @type {Quote[]} */
let collection = []


function collectionPath() {
  return odd.path.appData(
    appInfo,
    odd.path.file("Collection", "quotes.json")
  )
}


/**
 * Add a `Quote` to the file system.
 *
 * @param {Quote} quote
 */
async function addQuote(quote) {
  console.log("✍ Adding quote", quote)
  collection = [...collection, quote]
  return await fs?.write(
    collectionPath(),
    "utf8",
    toJSON(collection),
  )
}


/**
 * Remove a `Quote` from the file system.
 *
 * @param {Quote} quote
 */
async function removeQuote(quote) {
  console.log("✍ Removing quote", quote)
  const collectionWithoutQuote = collection.filter(q => q.id !== quote.id)
  collection = collectionWithoutQuote

  return await fs?.write(
    collectionPath(),
    "utf8",
    toJSON(collection)
  )
}


/**
 * Get the JSON-encoded `Quote`s from the file system,
 * and then decode them.
 */
async function loadQuotes() {
  console.log("✨ Loading quotes")

  if (fs && await fs.exists(collectionPath())) {
    collection = await fs.read(collectionPath(), "utf8").then(json => {
      return JSON.parse(json)
    })
  } else {
    collection = []
  }

  return collection
}



// SELECTION HISTORY


function historyPath() {
  return odd.path.appData(
    appInfo,
    odd.path.file("History", "selection.json")
  )
}


async function retrieveSelectionHistory() {
  const json = await fs?.read(historyPath(), "utf8").catch(_ => null)
  return json ? JSON.parse(json) : []
}


/** @param {string[]} listOfQuoteIds */
async function saveSelectionHistory(listOfQuoteIds) {
  console.log("👨‍🏫 Saving history", listOfQuoteIds)
  return await fs?.write(
    historyPath(),
    "utf8",
    toJSON(listOfQuoteIds)
  )
}



// 🔬


/**
 * Import a list of quotes.
 *
 * @param {Record<string, any>[]} rawList
 */
async function importList(rawList) {
  const timestamp = Date.now()
  const list = rawList
    .filter(quote => quote.author && quote.quote)
    .map((quote, idx) => ({ ...quote, id: `${timestamp}-${idx + 1}` }))

  // Save to file system
  console.log("🧳 Starting import", list)

  const existingQuotes = collection
  const newCollection = [...existingQuotes, ...list]

  await fs?.write(
    collectionPath(),
    "utf8",
    toJSON(newCollection)
  )

  console.log("🧳 Finished import")

  // Notify Elm app of imported quotes
  elm.ports.importedQuotes.send(list)
}


/**
 * Transform into a JSON Blob.s
 *
 * @param {any} value
 * @returns {string}
 */
function toJSON(value) {
  return JSON.stringify(value)
}



// 💩


/**
 * We have this because of an edge-case with -webkit-fill-available.
 * When you focus on an input field on iOS it zooms in, which is fine.
 * But if you then remove that element, -webkit-fill-available doesn't reset properly.
 * Hence this function.
 */
function triggerRepaint() {
  setTimeout(() => document.body.style.transform = "scale(1)", 0)
  setTimeout(() => document.body.style.transform = "", 16)
  setTimeout(() => document.body.style.transform = "scale(1)", 160)
  setTimeout(() => document.body.style.transform = "", 176)
  setTimeout(() => document.body.style.transform = "scale(1)", 320)
  setTimeout(() => document.body.style.transform = "", 336)
}
