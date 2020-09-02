//
// | (• ◡•)| (❍ᴥ❍ʋ)


const wn = webnative


// 🍱


wn.setup.debug({ enabled: true })



// 🚀


let elm, fs, pre


wn.initialise({
    app: {
      name: "Quotes",
      creator: "icidasset"
    }
  })

  .catch(temporaryAlphaCodeHandler)

  .then(async ({ prerequisites, scenario, state }) => {
    const { authenticated, newUser, throughLobby, username } = state

    // Expose prerequisites
    pre = prerequisites

    // The file system,
    // we'll use this later (see CRUD functions below)
    fs = state.fs

    // Initialise Elm app
    elm = Elm.Main.init({
      flags: {
        authenticated,

        currentTime:        Date.now(),
        newUser:            newUser || null,
        throughLobby:       throughLobby || false,
        username:           username || null
      }
    })

    // Communicate with Elm app
    elm.ports.addQuote.subscribe(addQuote)
    elm.ports.removeQuote.subscribe(removeQuote)
    elm.ports.saveSelectionHistory.subscribe(saveSelectionHistory)
    elm.ports.signIn.subscribe(() => wn.redirectToLobby(prerequisites))
    elm.ports.triggerRepaint.subscribe(triggerRepaint)

    // Continue Elm initialisation
    if (authenticated) elm.ports.loadUserData.send({
      quotes:             await loadQuotes(),
      selectionHistory:   await retrieveSelectionHistory(),
    })

  })



// CRUD


/**
 * Add a `Quote` to the file system.
 */
async function addQuote(quote) {
  console.log("✍ Adding quote", quote)
  return await transaction(
    fs.write,
    fs.appPath([ "Collection", `${quote.id}.json` ]),
    toJsonBlob(quote)
  )
}


/**
 * Remove a `Quote` from the file system.
 */
async function removeQuote(quote) {
  console.log("✍ Removing quote", quote)
  return await transaction(
    fs.rm,
    fs.appPath([ "Collection", `${quote.id}.json` ])
  )
}


/**
 * Get the JSON-encoded `Quote`s from the file system,
 * and then decode them.
 */
function loadQuotes() {
  const quotesPath =
    fs.appPath([ "Collection" ])

  return fs
    // List collection.
    // If the path doesn't exist, return an empty object.
    .ls(quotesPath)
    .catch(_ => {})
    .then(a => a || {})

    // Transform the object into a list,
    // and retrieve each quote.
    .then(Object.keys)
    .then(links => Promise.all(
      links
        .filter(name => name.endsWith(".json"))
        .map(name => fs.cat(`${quotesPath}/${name}`).then(JSON.parse))
    ))
}



// SELECTION HISTORY


function historyPath() {
  return fs.appPath([ "History", "selection.json" ])
}


async function retrieveSelectionHistory() {
  const json = await fs.read(historyPath()).catch(_ => null)
  return json ? JSON.parse(json) : []
}


async function saveSelectionHistory(listOfQuoteIds) {
  console.log("👨‍🏫 Saving history", listOfQuoteIds)
  await transaction(
    fs.write,
    historyPath(),
    toJsonBlob(listOfQuoteIds)
  )
}



// 🔬


/**
 * Import a list of quotes.
 * TODO: Make this more performant
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
 * TODO:
 * Remove this temporary code when the alpha-tester folks
 * have upgraded their code. Later we'll have filesystem versioning.
 */
async function temporaryAlphaCodeHandler(err) {
  console.error(err)

  if (
    err.message.indexOf("Could not find header value: metadata") > -1 ||
    err.message.indexOf("Could not find index for node") > -1 ||
    err.message.indexOf("Could not parse a valid private tree using the given key") > -1
  ) {
    const result = confirm("Thanks for testing the alpha version of the webnative sdk. We refactored the file system which is not backwards compatible. Do you want to create a new file system?")

    if (result) {
      fs = await wn.fs.empty({ keyName: "filesystem-lobby", prerequisites: pre })
      await saveSelectionHistory([]) // do a crud operation to trigger a mutation + publicise
      return fs
    }

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



// TRANSACTIONS
// ⚠️ Will be removed soon


const transactionQueue = []


/**
 * Process the next item in the transaction queue.
 */
function nextTransaction() {
  const nextAction = transactionQueue.shift()
  if (nextAction) setTimeout(nextAction, 16)
  else fs.publicise()
}


/**
 * The Fission filesystem doesn't support parallel writes yet.
 * This function is a way around that.
 *
 * @param method The filesystem method to run
 * @param methodArguments The arguments for the given filesystem method
 */
async function transaction(method, ...methodArguments) {
  transactionQueue.push(async () => {
    await method.apply(fs, methodArguments)
    nextTransaction()
  })

  if (transactionQueue.length === 1) {
    nextTransaction()
  }
}



// SHARED WORKER
// ⚠️ To do
//
// Game plan:
// - Run `setupIpfsClient` before `initialise`
// - Run `setupIpfsIframe` before loading the file system
// - Disable automatic file-system loading by passing option to `initialise`
// - Load the file system ourselves
//
// This will be moved into the SDK later.


function setupIpfsClient() {
  ipfs = IpfsMessagePortClient.detached()
  wn.ipfs.set(ipfs)
}


function setupIpfsIframe() {
  return new Promise((resolve) => {
    const iframe = document.createElement("iframe")
    iframe.style.width = "0"
    iframe.style.height = "0"
    iframe.style.border = "none"
    document.body.appendChild(iframe)

    iframe.onload = () => {
      const channel = new MessageChannel()
      channel.port1.onmessage = ({ ports }) => {
        IpfsMessagePortClient.attach(ipfs, ports[0])
      }
      iframe.contentWindow.postMessage("CONNECT", "*", [ channel.port2 ])
      resolve()
    }

    iframe.src = "http://localhost:8001/ipfs.html"
  })
}
