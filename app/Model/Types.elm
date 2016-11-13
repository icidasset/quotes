module Model.Types exposing (..)

import Debounce
import Dict exposing (Dict)
import Http
import Material
import Maybe exposing (Maybe, withDefault)
import Time exposing (Time)
import TouchEvents as TE

import Css.Modules
import Quotes.Types exposing (..)
import Routing exposing (Page)



-- Model


type alias Model = Css.Modules.Model (SystemDataModel UserDataModel)


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
  , touchPositionY : Maybe Float
  }


type alias UserDataModel =
  { collectionSeen : List String
  , collectionUrl : String
  }



-- Messages


type Msg =
  DebounceFetch (Debounce.Msg Msg)
  | FetchFail Http.Error
  | FetchSucceed (List QuoteTuple)
  | GoToIndex
  | GoToSettings
  | Mdl (Material.Msg Msg)
  | OnTouchStart TE.Touch
  | OnTouchEnd TE.Touch
  | ResetSeen
  | SelectRandomQuote
  | SetCollectionUrl String
  | SetSelectedQuote (Maybe Quote)
