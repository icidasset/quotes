module Commands exposing (fetchQuotes, keepState, selectRandomQuote)

import Http
import Random
import Task
import Time

import Messages exposing (Msg(..))
import Model exposing (Model, toUserData)
import Ports exposing (..)
import Quotes.Utils
import Types exposing (Quote, QuoteTuple)



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
