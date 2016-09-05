module Messages exposing (..)

import Array exposing (Array)
import Http
import Material


type Msg =
  FetchFail Http.Error
  | FetchSucceed (Array (String, String))
  | GoToIndex
  | GoToSettings
  | Mdl (Material.Msg Msg)
  | SetCollectionUrl String
