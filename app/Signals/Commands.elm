module Signals.Commands exposing (..)

import Http
import Random
import Task
import Time

import Model.Types exposing (Model, Msg(..))
import Model.Utils exposing (toUserData)
import Quotes.Types exposing (Quote, QuoteTuple)
import Quotes.Utils
import Signals.Ports exposing (..)



-- Keep state


keepState : Model -> Cmd Msg
keepState model =
  localStorage (toUserData model)



-- Quotes


fetchQuotes : Model -> Cmd Msg
fetchQuotes model =
  Task.perform FetchFail FetchSucceed (Http.get Quotes.Utils.decode model.collectionUrl)


selectRandomQuote : List Quote -> List String -> Cmd Msg
selectRandomQuote collection collectionSeen =
  Random.generate
    (SetSelectedQuote)
    (Quotes.Utils.randomGenerator collection collectionSeen)
