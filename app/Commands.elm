module Commands exposing (keepState, fetchQuotes)

import Array exposing (Array)
import Http
import Json.Decode as Json exposing ((:=), andThen, object1, object2)
import Task

import Messages exposing (Msg(..))
import Model exposing (Model, toUserData)
import Ports exposing (..)


keepState : Model -> Cmd Msg
keepState model =
  localStorage (toUserData model)


fetchQuotes : Model -> Cmd Msg
fetchQuotes model =
  Task.perform FetchFail FetchSucceed (Http.get decodeQuotes model.collectionUrl)


decodeQuotes : Json.Decoder (Array (String, String))
decodeQuotes =
  Json.oneOf
  [ ("data" := decodeQuotesArray)
  , decodeQuotesArray
  ]


decodeQuotesArray : Json.Decoder (Array (String, String))
decodeQuotesArray =
  Json.array (
    object2 (,)
      ("quote" := Json.string)
      ("author" := Json.string)
  )
