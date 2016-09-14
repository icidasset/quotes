module Commands exposing (keepState, fetchQuotes, setInitialTime)

import Array exposing (Array)
import Http
import Json.Decode as Json exposing ((:=), andThen, object1, object2)
import Task
import Time

import Messages exposing (Msg(..))
import Model exposing (Model, toUserData)
import Ports exposing (..)



-- Keep state


keepState : Model -> Cmd Msg
keepState model =
  localStorage (toUserData model)



-- Quotes


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



-- Time


setInitialTime : Cmd Msg
setInitialTime =
  Task.perform noOp SetInitialTime Time.now


noOp =
  (\_ -> Debug.crash "")
