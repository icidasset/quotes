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

  // Debugging
  debugFileSystem(fs)

})



// CRUD


/**
 * Add a `Quote` to the file system.
 */
async function addQuote(quote) {
  log("✍ Adding quote", quote)
  return await fs.write(
    fs.appPath.private(UUID, [ "Collection", quote.id ]),
    JSON.stringify(quote)
  )
}


/**
 * Remove a `Quote` from the file system.
 */
async function removeQuote(quote) {
  log("✍ Removing quote", quote)
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
  const json = await fs.read(historyPath()).catch(_ => null)
  return json ? JSON.parse(json) : []
}


function saveSelectionHistory(listOfQuoteIds) {
  log("👨‍🏫 Saving history", listOfQuoteIds)
  return fs.write(
    historyPath(),
    JSON.stringify(listOfQuoteIds)
  )
}



// 🦉


/**
 * Don't mind me.
 */
function debugFileSystem(fs) {
  if (!fs) return

  fs.syncHooks.push(cid => {
    console.log("Filesystem change registered 👩‍🔬", cid)
  })
}


/**
 * Get all your logs here folks.
 */
function log(...args) {
  console.log(...args)
}


/**
 * Import a list of quotes.
 */
async function importList(rawList) {
  const timestamp = Date.now()
  const list = rawList
    .filter(item => item.author && item.quote)
    .map((item, idx) => ({ ...item, id: `${timestamp}-${idx + 1}` }))

  // Notify Elm app of imported quotes
  elm.ports.importedQuotes.send(list)

  // Save to file system
  await list.reduce(async (acc, item) => {
    await acc
    await addQuote(item)
  }, Promise.resolve(null))
}
