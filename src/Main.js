//
// | (• ◡•)| (❍ᴥ❍ʋ)


const UUID = "icidasset.quotes"
const sdk = fissionSdk


// 🍱


if (sdk.setup.debug) {
  sdk.setup.debug({ enabled: true })
}



// 🚀


let elm, fs


sdk
  .initialise()
  .catch(temporaryAlphaCodeHandler)
  .then(async ({ scenario, state }) => {
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
    elm.ports.triggerRepaint.subscribe(triggerRepaint)

    // Debugging
    debugFileSystem(fs)

  })



// CRUD


/**
 * Add a `Quote` to the file system.
 */
async function addQuote(quote) {
  log("✍ Adding quote", quote)
  return await transaction(
    fs.write,
    fs.appPath.private(UUID, [ "Collection", quote.id ]),
    JSON.stringify(quote)
  )
}


/**
 * Remove a `Quote` from the file system.
 */
async function removeQuote(quote) {
  log("✍ Removing quote", quote)
  return await transaction(
    fs.rm,
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
  return transaction(
    fs.write,
    historyPath(),
    JSON.stringify(listOfQuoteIds)
  )
}



// TRANSACTIONS


const transactionQueue = []


/**
 * Process the next item in the transaction queue.
 */
function nextTransaction() {
  const nextAction = transactionQueue.shift()
  if (nextAction) nextAction()
}


/**
 * The Fission filesystem doesn't support parallel writes yet.
 * This function is a way around that.
 *
 * @param method The filesystem method to run
 * @param methodArguments The arguments for the given filesystem method
 */
function transaction(method, ...methodArguments) {
  transactionQueue.push(async () => {
    await method.apply(fs, methodArguments)
    nextTransaction()
  })

  if (transactionQueue.length === 1) {
    nextTransaction()
  }
}



// 🦉


function debugFileSystem(fs) {
  if (!fs) return

  fs.syncHooks.push(cid => {
    log("Filesystem change registered 👩‍🔬", cid)
  })
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


function log(...args) {
  console.log(...args)
}


/**
 * TODO:
 * Remove this temporary code when the alpha-tester folks
 * have upgraded their code. Later we'll have filesystem versioning.
 */
async function temporaryAlphaCodeHandler(err) {
  console.error(err)

  if (
    err.message.indexOf("Could not find header value: metadata") > -1 ||
    err.message.indexOf("Could not find index for node") > -1
  ) {
    await (await sdk.fs.empty()).sync()
    alert("Thanks for testing our alpha version of the Fission SDK. We refactored the file system which is not backwards compatible, so we'll have to create a new file system for you.")
    return sdk.initialise()

  } else {
    throw new Error(err)

  }
}


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
