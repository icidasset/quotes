import Model.Init
import Model.Update
import Navigation
import Routing exposing (urlParser)
import Signals.Subscriptions
import View exposing (view)


main =
  Navigation.programWithFlags urlParser
    { init = Model.Init.withProgramFlags
    , view = view
    , update = Model.Update.withMessage
    , urlUpdate = Model.Update.withPage
    , subscriptions = Signals.Subscriptions.batch
    }
