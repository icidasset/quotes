module Model exposing (..)

import Debounce
import Dict exposing (Dict)
import Material
import Maybe exposing (Maybe, withDefault)

import CSSModules
import Messages exposing (Msg)
import Routing exposing (Page)
import Types exposing (Quote)


type alias Model = CSSModules.Model (SystemDataModel UserDataModel)


type alias SystemDataModel a =
  { a |

    collection : List Quote
  , collectionIds : List String
  , collectionIsEmpty : Bool
  , fetchDebounce : Debounce.Model Msg
  , fetchInProgress : Bool
  , fetchError : Bool
  , mdl : Material.Model
  , page : Page
  , selectedQuote : Maybe Quote
  , touchPositionX : Maybe Float
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
