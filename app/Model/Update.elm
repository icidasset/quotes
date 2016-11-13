module Model.Update exposing (..)

import Debounce
import Dict
import Material
import Maybe exposing (Maybe, withDefault)
import Navigation
import Task
import Time exposing (millisecond)
import TouchEvents as TE exposing (Direction(..))

import Model.Types exposing (..)
import Quotes.Utils
import Routing exposing (Page(..))
import Signals.Commands exposing (..)



-- Model


withMessage : Msg -> Model -> (Model, Cmd Msg)
withMessage msg model =
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
        len = (List.length ids) == 0
      in
        { model |
          collection = col
        , collectionIds = ids
        , collectionIsEmpty = len
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

    DebounceFetch a ->
      let
        (deb, eff) = Debounce.update (1000 * millisecond) a model.fetchDebounce
        new = { model | fetchDebounce = deb }
      in
        new ! [ Cmd.map (\r -> case r of
                  Err b -> DebounceFetch b
                  Ok  b -> b) eff ]

    -- User interactions
    SetCollectionUrl url ->
      let
        new = { model | collectionUrl = url, fetchInProgress = True }
        ftc = makeCmd (DebounceFetch (Debounce.Bounce (fetchQuotes new)))
      in
        new ! [keepState new, ftc]

    -- Selection process
    SetSelectedQuote quote ->
      let
        new = { model |
          collectionSeen = Quotes.Utils.buildSeenList model quote
        , selectedQuote = if quote == Nothing then model.selectedQuote else quote
        }
      in
        new

        !

        if (quote == Nothing) && (model.collectionIsEmpty == False) then
          [keepState new, nextQuote new]
        else
          [keepState new]

    SelectRandomQuote ->
      let
        new = model
      in
        new ! [nextQuote new]

    ResetSeen ->
      let
        new = { model | collectionSeen = [] }
      in
        new ! [nextQuote new]

    -- Touch events
    OnTouchStart touchEvent ->
      let
        new = { model |
          touchPositionX = Just touchEvent.clientX
        , touchPositionY = Just touchEvent.clientY
        }
      in
        new ! []

    OnTouchEnd touchEvent ->
      let
        startX = withDefault 0 model.touchPositionX
        startY = withDefault 0 model.touchPositionY

        endX = touchEvent.clientX
        endY = touchEvent.clientY

        diffX = abs (endX - startX)
        diffY = abs (endY - startY)

        horizontalDirection = TE.getDirectionX startX endX

        pag = model.page
        new = model
      in
        if (pag == Index) && (diffY <= 100) && (diffX >= 125) && (horizontalDirection == Left) then
          new ! [nextQuote new]
        else
          new ! []

    -- Material Design
    Mdl msg' ->
      Material.update msg' model


nextQuote : Model -> Cmd Msg
nextQuote model =
  selectRandomQuote model.collection model.collectionSeen


makeCmd : a -> Cmd a
makeCmd =
  Task.perform (Debug.crash << toString) identity << Task.succeed



-- Navigation


withPage : Page -> Model -> (Model, Cmd Msg)
withPage page model =
  { model | page = page } ! []
