//
// | (• ◡•)| (❍ᴥ❍ʋ)


const UUID = "icidasset.quotes"
const sdk = fissionSdk


// 🚀


let app, fs


sdk.initialise().then(async ({ scenario, state }) => {
  const { authenticated, newUser, throughLobby, username } = state

  // The file system,
  // we'll use this later (see CRUD functions below)
  fs = state.fs

  // Initialise Elm app
  elm = Elm.Main.init({
    flags: {
      authenticated,

      currentTime:        Date.now(),
      newUser:            newUser || null,
      quotes:             authenticated ? await loadQuotes() : null,
      selectionHistory:   authenticated ? await retrieveSelectionHistory() : [],
      throughLobby:       throughLobby || false,
      username:           username || null
    }
  })

  // Communicate with Elm app
  elm.ports.addQuote.subscribe(addQuote)
  elm.ports.removeQuote.subscribe(removeQuote)
  elm.ports.saveSelectionHistory.subscribe(saveSelectionHistory)
  elm.ports.signIn.subscribe(sdk.redirectToLobby)

})



// CRUD


/**
 * Add a `Quote` to the file system.
 */
async function addQuote(quote) {
  return await fs.write(
    fs.appPath.private(UUID, [ "Collection", quote.id ]),
    JSON.stringify(quote)
  )
}


/**
 * Remove a `Quote` from the file system.
 */
async function removeQuote(quote) {
  return await fs.rm(
    fs.appPath.private(UUID, [ "Collection", quote.id ])
  )
}


/**
 * Get the JSON-encoded `Quote`s from the file system,
 * and then decode them.
 */
function loadQuotes() {
  const quotesPath =
    fs.appPath.private(UUID, [ "Collection" ])

  return fs
    // List collection.
    // If the path doesn't exist, return an empty object.
    .ls(quotesPath)
    .catch(_ => {})
    .then(a => a || {})

    // Transform the object into a list,
    // and retrieve each quote.
    .then(Object.entries)
    .then(links => Promise.all(
      links.map(([name, _]) => fs.cat(`${quotesPath}/${name}`).then(JSON.parse))
    ))
}



// SELECTION HISTORY


function historyPath() {
  return fs.appPath.private(UUID, [ "History", "selection.json" ])
}


async function retrieveSelectionHistory() {
  // const json = await fs.read(historyPath()).catch(_ => null)
  // return json ? JSON.parse(json) : []
  return []
}


function saveSelectionHistory(listOfQuoteIds) {
  console.log("Save", JSON.stringify(listOfQuoteIds))
  // return fs.write(
  //   historyPath(),
  //   JSON.stringify(listOfQuoteIds)
  // )
}
