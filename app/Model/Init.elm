module Model.Init exposing (..)

import Debounce
import Dict
import Material

import Css.Modules
import Model.Types exposing (..)
import Model.Utils exposing (..)
import Routing exposing (Page)
import Signals.Commands exposing (fetchQuotes)


type alias ProgramFlags =
  { cssmodules : Maybe Css.Modules.Flag
  , userData : Maybe UserDataModel
  }


withProgramFlags : ProgramFlags -> Page -> (Model, Cmd Msg)
withProgramFlags flags page =
  let
    model = initial page
      |> Css.Modules.init flags.cssmodules
      |> fromUserData flags.userData emptyUserData
  in
    { model | fetchInProgress = True } !
    [ fetchQuotes model ]



-- Private


defaultCollectionUrl : String
defaultCollectionUrl = "https://keymaps.herokuapp.com/public/1/quotes"


emptyUserData : UserDataModel
emptyUserData =
  { collectionSeen = []
  , collectionUrl = defaultCollectionUrl
  }


initial : Page -> Model
initial page =
  { collection = []
  , collectionIds = []
  , collectionIsEmpty = True
  , collectionSeen = []
  , collectionUrl = defaultCollectionUrl
  , cssmodules = Dict.empty
  , fetchDebounce = Debounce.init
  , fetchError = False
  , fetchInProgress = False
  , mdl = Material.model
  , page = page
  , selectedQuote = Nothing
  , touchPositionX = Nothing
  , touchPositionY = Nothing
  }
