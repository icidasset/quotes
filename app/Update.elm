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
        col = List.map Quotes.Utils.tupleToRecord collection
        ids = List.map (\q -> q.id) col
        see = model.collectionSeen
      in
        { model |
          collection = col
        , collectionIds = ids
        , fetchInProgress = False
        , fetchError = False
        }

        !

        [selectRandomQuote col see]

    FetchFail error ->
      let
        new = { model |
          fetchInProgress = False
        , fetchError = True
        }
      in
        new ! []

    -- User interactions
    SetCollectionUrl url ->
      let
        new = { model | collectionUrl = url }
      in
        new ! [keepState new, fetchQuotes new]

    -- Selection process
    SetSelectedQuote quote ->
      let
        new = { model |
          collectionSeen = Quotes.Utils.buildSeenList model quote
        , selectedQuote = quote
        }
      in
        new ! [keepState new]

    SelectRandomQuote ->
      let
        col = model.collection
        see = model.collectionSeen
        new = model
      in
        new ! [selectRandomQuote col see]

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
    [ fetchQuotes model ]
