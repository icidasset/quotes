//
// | (• ◡•)| (❍ᴥ❍ʋ)


const wn = webnative


// 🍱


const PERMISSIONS = {
  app: {
    name: "Quotes",
    creator: "icidasset"
  }
}


wn.setup.debug({ enabled: true })


// wn.setup.endpoints({
//   api: "https://runfission.net",
//   lobby: "https://auth.runfission.net",
//   user: "fissionuser.net"
// })



// 🚀


let elm, fs


elm = Elm.Main.init({
  flags: {
    currentTime: Date.now()
  }
})


wn.initialise({ permissions: PERMISSIONS })
  .then(async state => {
    const { authenticated, newUser, throughLobby, username } = state

    // Continue initialisation process in Elm app
    elm.ports.initialise.send({
      authenticated: authenticated || false,
    })

    // The file system,
    // we'll use this later (see CRUD functions below)
    fs = state.fs

    // Communicate with Elm app
    elm.ports.addQuote.subscribe(addQuote)
    elm.ports.removeQuote.subscribe(removeQuote)
    elm.ports.saveSelectionHistory.subscribe(saveSelectionHistory)
    elm.ports.signIn.subscribe(() => wn.redirectToLobby(PERMISSIONS))
    elm.ports.triggerRepaint.subscribe(triggerRepaint)

    // Continue Elm initialisation
    if (authenticated) elm.ports.loadUserData.send({
      quotes:             await loadQuotes(),
      selectionHistory:   await retrieveSelectionHistory(),
    })

  })



// CRUD


let collection


function collectionPath() {
  return fs.appPath(
    wn.path.file("Collection", "quotes.json")
  )
}


/**
 * Add a `Quote` to the file system.
 */
async function addQuote(quote) {
  console.log("✍ Adding quote", quote)
  collection = [ ...collection, quote ]
  return await fs.write(
    collectionPath(),
    toJsonBlob(collection),
    { publish: true }
  )
}


/**
 * Remove a `Quote` from the file system.
 */
async function removeQuote(quote) {
  console.log("✍ Removing quote", quote)
  const collectionWithoutQuote = collection.filter(q => q.id !== quote.id)
  collection = collectionWithoutQuote

  return await fs.write(
    collectionPath(),
    toJsonBlob(collection),
    { publish: true }
  )
}


/**
 * Get the JSON-encoded `Quote`s from the file system,
 * and then decode them.
 */
async function loadQuotes() {
  console.log("✨ Loading quotes")

  if (await fs.exists(collectionPath())) {
    collection = await fs.read(collectionPath()).then(JSON.parse)
  } else {
    collection = []
  }

  return collection
}



// SELECTION HISTORY


function historyPath() {
  return fs.appPath(
    wn.path.file("History", "selection.json")
  )
}


async function retrieveSelectionHistory() {
  const json = await fs.read(historyPath()).catch(_ => null)
  return json ? JSON.parse(json) : []
}


async function saveSelectionHistory(listOfQuoteIds) {
  console.log("👨‍🏫 Saving history", listOfQuoteIds)
  return await fs.write(
    historyPath(),
    toJsonBlob(listOfQuoteIds),
    { publish: true }
  )
}



// 🔬


/**
 * Import a list of quotes.
 */
async function importList(rawList) {
  const timestamp = Date.now()
  const list = rawList
    .filter(quote => quote.author && quote.quote)
    .map((quote, idx) => ({ ...quote, id: `${timestamp}-${idx + 1}` }))

  // Save to file system
  console.log("🧳 Starting import", list)

  const existingQuotes = collection
  const newCollection = [ ...existingQuotes, ...list ]

  await fs.write(
    collectionPath(),
    toJsonBlob(newCollection)
  )

  console.log("🧳 Finished import")

  // Notify Elm app of imported quotes
  elm.ports.importedQuotes.send(list)
}


/**
 * Transform into a JSON Blob.
 */
function toJsonBlob(value) {
  return new Blob(
    [ JSON.stringify(value) ],
    { type: "text/plain" }
  )
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
