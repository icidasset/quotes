module Model exposing (..)

import Dict exposing (Dict)
import Material
import Maybe exposing (Maybe, withDefault)
import Time exposing (Time)

import CSSModules
import Quotes.Types exposing (Quote)
import Routing exposing (Page)


type alias Model = CSSModules.Model (SystemDataModel UserDataModel)


type alias SystemDataModel a =
  { a |

    collection : List Quote
  , collectionIds : List String
  , fetchInProgress : Bool
  , fetchError : Bool
  , initialTimestamp : Time
  , mdl : Material.Model
  , page : Page
  , selectedQuote : Maybe Quote
  }


type alias UserDataModel =
  { collectionSeen : List String
  , collectionUrl : String
  }



-- Initial State


defaultCollectionUrl : String
defaultCollectionUrl = "https://keymaps.herokuapp.com/public/1/quotes"


initial : Page -> Model
initial page =
  { collection = []
  , collectionIds = []
  , collectionSeen = []
  , collectionUrl = defaultCollectionUrl
  , cssmodules = Dict.empty
  , fetchError = False
  , fetchInProgress = False
  , initialTimestamp = 0.0
  , mdl = Material.model
  , page = page
  , selectedQuote = Nothing
  }


initialUserData : UserDataModel
initialUserData =
  { collectionSeen = []
  , collectionUrl = defaultCollectionUrl
  }



-- User-data helpers

toUserData : Model -> UserDataModel
toUserData model =
  { collectionSeen = model.collectionSeen
  , collectionUrl = model.collectionUrl
  }


fromUserData : Maybe UserDataModel -> Model -> Model
fromUserData userData model =
  let
    userData' = withDefault initialUserData userData
  in
    { model |

      collectionSeen = userData'.collectionSeen
    , collectionUrl = userData'.collectionUrl
    }
