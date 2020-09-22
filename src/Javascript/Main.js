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


wn.initialise({ permissions: PERMISSIONS })
  .catch(temporaryAlphaCodeHandler)
  .then(async state => {
    const { authenticated, newUser, throughLobby, username } = state

    // The file system,
    // we'll use this later (see CRUD functions below)
    fs = state.fs

    // Initialise Elm app
    elm = Elm.Main.init({
      flags: {
        authenticated:      authenticated || false,

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
    elm.ports.signIn.subscribe(() => wn.redirectToLobby(PERMISSIONS))
    elm.ports.triggerRepaint.subscribe(triggerRepaint)

    // Continue Elm initialisation
    if (authenticated) elm.ports.loadUserData.send({
      quotes:             await loadQuotes(),
      selectionHistory:   await retrieveSelectionHistory(),
    })

  })



// CRUD


function collectionPath() {
  return fs.appPath([ "Collection", "quotes.json" ])
}


async function collection() {
  if (await fs.exists(collectionPath())) {
    return fs.read(collectionPath()).then(JSON.parse)
  } else {
    return []
  }
}


/**
 * Add a `Quote` to the file system.
 */
async function addQuote(quote) {
  console.log("✍ Adding quote", quote)
  const existingQuotes = await collection()

  return await transaction(
    fs.write,
    collectionPath(),
    toJsonBlob([ ...existingQuotes, quote ])
  )
}


/**
 * Remove a `Quote` from the file system.
 */
async function removeQuote(quote) {
  console.log("✍ Removing quote", quote)
  const existingQuotes = await collection()
  const collectionWithoutQuote = existingQuotes.filter(q => q.id !== quote.id)

  return await transaction(
    fs.write,
    collectionPath(),
    toJsonBlob(collectionWithoutQuote)
  )
}


/**
 * Get the JSON-encoded `Quote`s from the file system,
 * and then decode them.
 */
function loadQuotes() {
  console.log("Load quotes")
  return collection()
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
 */
async function importList(rawList) {
  const timestamp = Date.now()
  const list = rawList
    .filter(quote => quote.author && quote.quote)
    .map((quote, idx) => ({ ...quote, id: `${timestamp}-${idx + 1}` }))

  // Save to file system
  console.log("🧳 Starting import", list)

  const existingQuotes = await collection()
  const newCollection = [ ...existingQuotes, ...list ]

  return await transaction(
    fs.write,
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
      fs = await wn.fs.empty({ keyName: "filesystem-lobby", permissions: PERMISSIONS })
      await saveSelectionHistory([]) // do a crud operation to trigger a mutation + publish
      return wn.initialise({ permissions: PERMISSIONS })
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


const transactions = {
  queue: [],
  finished: true
}


/**
 * Process the next item in the transaction queue.
 */
async function nextTransaction() {
  transactions.finished = false
  if (nextTransactionWithoutPublish()) return
  await fs.publish()
  if (nextTransactionWithoutPublish()) return
  transactions.finished = true
}

function nextTransactionWithoutPublish() {
  const nextAction = transactions.queue.shift()
  if (nextAction) {
    setTimeout(nextAction, 16)
    return true
  } else {
    return false
  }
}


/**
 * The Fission filesystem doesn't support parallel writes yet.
 * This function is a way around that.
 *
 * @param method The filesystem method to run
 * @param methodArguments The arguments for the given filesystem method
 */
async function transaction(method, ...methodArguments) {
  transactions.queue.push(async () => {
    await method.apply(fs, methodArguments)
    await nextTransaction()
  })

  if (transactions.finished) {
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
