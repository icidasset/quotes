module Commands exposing (fetchQuotes, keepState, setInitialTime, selectRandomQuote)

import Http
import Random
import Task
import Time

import Messages exposing (Msg(..))
import Model exposing (Model, toUserData)
import Ports exposing (..)
import Quotes.Types exposing (Quote, QuoteTuple)
import Quotes.Utils



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



-- Time


setInitialTime : Cmd Msg
setInitialTime =
  Task.perform noOp SetInitialTime Time.now


noOp =
  (\_ -> Debug.crash "")
