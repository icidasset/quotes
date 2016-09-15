module Messages exposing (..)

import Http
import Material
import Quotes.Types exposing (Quote, QuoteTuple)
import Time exposing (Time)


type Msg =
  FetchFail Http.Error
  | FetchSucceed (List QuoteTuple)
  | GoToIndex
  | GoToSettings
  | Mdl (Material.Msg Msg)
  | SelectRandomQuote
  | SetCollectionUrl String
  | SetInitialTime Time
  | SetSelectedQuote (Maybe Quote)
