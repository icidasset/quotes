module Update exposing (..)

import Dict
import Material
import Maybe exposing (Maybe)
import Navigation
import Time

import Commands exposing (..)
import CSSModules
import Messages exposing (Msg(..))
import Model exposing (Model, UserDataModel, fromUserData, initialUserData)
import Quotes.Utils
import Routing exposing (LocationResult, toPage)


type alias ProgramFlag =
  { cssmodules : Maybe CSSModules.Flag
  , userData : Maybe UserDataModel
  }



-- Model


updateModel : Msg -> Model -> (Model, Cmd Msg)
updateModel msg model =
  case msg of
    -- Pages
    GoToIndex ->
      model ! [Navigation.newUrl "/"]

    GoToSettings ->
      model ! [Navigation.newUrl "/settings"]

    -- Go fetch
    FetchSucceed collection ->
      let
        collection' = List.map Quotes.Utils.tupleToRecord collection
        collectionIds = List.map (\q -> q.id) collection'
        cmdSelectRandomQuote = selectRandomQuote collection' model.collectionSeen
      in
        { model |
            collection = collection'
          , collectionIds = collectionIds
          , fetchInProgress = False
          , fetchError = False
        } ! [cmdSelectRandomQuote]

    FetchFail error ->
      { model |
          fetchInProgress = False
        , fetchError = True
      } ! []

    -- User interactions
    SetCollectionUrl url ->
      let
        newModel = { model | collectionUrl = url }
        cmdKeepState = keepState newModel
        cmdFetchQuotes = fetchQuotes newModel
      in
        newModel ! [cmdKeepState, cmdFetchQuotes]

    -- Selection process
    SetSelectedQuote quote ->
      let
        newModel = { model |
          collectionSeen = Quotes.Utils.buildSeenList model quote
        , selectedQuote = quote
        }
      in
        newModel ! [keepState newModel]

    SelectRandomQuote ->
      model ! [selectRandomQuote model.collection model.collectionSeen]

    -- Time
    SetInitialTime time ->
      let
        timestamp = Time.inMilliseconds time
      in
        { model | initialTimestamp = timestamp } ! []

    -- Material Design
    Mdl msg' ->
      Material.update msg' model



-- Navigation


urlUpdated : LocationResult -> Model -> (Model, Cmd Msg)
urlUpdated result model =
  { model | page = (toPage result) } ! []



-- Subscriptions


subscriptions : Model -> Sub Msg
subscriptions model =
  Sub.none



-- Init


setInitialModel : ProgramFlag -> LocationResult -> (Model, Cmd Msg)
setInitialModel flag result =
  let
    model = toPage result
    |> Model.initial
    |> CSSModules.init flag.cssmodules
    |> fromUserData flag.userData
  in
    { model | fetchInProgress = True } !
    [ fetchQuotes model
    , setInitialTime
    ]
