module Messages exposing (..)

import Http
import Material
import Time exposing (Time)
import Types exposing (Quote, QuoteTuple)


type Msg =
  FetchFail Http.Error
  | FetchSucceed (List QuoteTuple)
  | GoToIndex
  | GoToSettings
  | Mdl (Material.Msg Msg)
  | SelectRandomQuote
  | SetCollectionUrl String
  | SetSelectedQuote (Maybe Quote)
