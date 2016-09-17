module Messages exposing (..)

import Http
import Material
import Time exposing (Time)
import TouchEvents as TE
import Types exposing (Quote, QuoteTuple)


type Msg =
  FetchFail Http.Error
  | FetchSucceed (List QuoteTuple)
  | GoToIndex
  | GoToSettings
  | Mdl (Material.Msg Msg)
  | OnTouchStart TE.Touch
  | OnTouchEnd TE.Touch
  | SelectRandomQuote
  | SetCollectionUrl String
  | SetSelectedQuote (Maybe Quote)
