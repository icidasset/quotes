//
// | (• ◡•)| (❍ᴥ❍ʋ)


const sdk = fissionSdk
const uuid = "icidasset/Quotes"


// 🚀


let app, fs


sdk.isAuthenticated().then(({ authenticated, newUser, session, throughLobby }) => {

  // The file system
  fs = session && session.fs

  // Initialise Elm app
  app = Elm.Main.init({
    flags: {
      authenticated,
      newUser,
      throughLobby,
      username: session && session.username
    }
  })

  // Communicate with Elm app
  // app.ports.addQuote.subscribe(async quote => {
  //   await addQuote(quote)
  //   app.ports.addedQuoteSuccessfully.send()
  // })

  // app.ports.loadQuotes.subscribe(async () => {
  //   const quotes = await loadQuotes(quote)
  //   app.ports.loadedQuotesSuccessfully.send(quotes)
  // })

})



// CRUD


async function addQuote(quote) {
  return await fs.write(
    fs.appPath.private(uuid, quote.id),
    JSON.stringify(quote)
  )
}


async function loadQuotes() {
  const files = await fs.ls(
    fs.appPath.private(uuid)
  ).catch(
    _ => []
  )

  // TODO
  return []
}
