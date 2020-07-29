//
// | (• ◡•)| (❍ᴥ❍ʋ)


const sdk = fissionSdk
const uuid = "icidasset.quotes"


// 🚀


let app, fs


sdk.initialise(uuid).then(async ({ scenario, state }) => {
  const { authenticated, newUser, throughLobby, username } = state

  // The file system,
  // we'll use this later (see CRUD functions below)
  fs = state.fs

  // Initialise Elm app
  elm = Elm.Main.init({
    flags: {
      authenticated,

      currentTime:      Date.now(),
      newUser:          newUser || null,
      quotes:           authenticated ? await loadQuotes() : null,
      throughLobby:     throughLobby || false,
      username:         username || null
    }
  })

  // Communicate with Elm app
  elm.ports.addQuote.subscribe(addQuote)
  elm.ports.removeQuote.subscribe(removeQuote)
  elm.ports.signIn.subscribe(sdk.redirectToLobby)

})



// CRUD


/**
 * Add a `Quote` to the file system.
 */
async function addQuote(quote) {
  return await fs.write(
    fs.appPath.private(uuid, [ "Collection", quote.id ]),
    JSON.stringify(quote)
  )
}


/**
 * Remove a `Quote` from the file system.
 */
async function removeQuote(quote) {
  return await fs.rm(
    fs.appPath.private(uuid, [ "Collection", quote.id ])
  )
}


/**
 * Get the JSON-encoded `Quote`s from the file system,
 * and then decode them.
 */
function loadQuotes() {
  const quotesPath =
    fs.appPath.private(uuid, [ "Collection" ])

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

    // Log to console
    .then(list => {
      console.log(list)
      return list
    })
}
