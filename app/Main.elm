import Navigation

import Routing exposing (urlParser)
import Update exposing (setInitialModel, subscriptions, updateModel, urlUpdated)
import View exposing (view)


main =
  Navigation.programWithFlags urlParser
    { init = setInitialModel
    , view = view
    , update = updateModel
    , urlUpdate = urlUpdated
    , subscriptions = subscriptions
    }
