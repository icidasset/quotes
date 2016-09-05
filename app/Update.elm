module Update exposing (..)

import Dict
import Material
import Maybe exposing (Maybe)
import Navigation

import CSSModules
import Model exposing (Model, UserDataModel, fromUserData, initialUserData, toUserData)
import Ports exposing (..)
import Routing exposing (LocationResult, toPage)


type Msg =
  GoToIndex
  | GoToSettings
  | Mdl (Material.Msg Msg)
  | SetCollectionUrl String


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

    -- User interactions
    SetCollectionUrl url ->
      keepState { model | collectionUrl = url }

    -- Material Design
    Mdl msg' ->
      Material.update msg' model


keepState : Model -> (Model, Cmd Msg)
keepState model =
  (model, localStorage (toUserData model))



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
  in
    (fromUserData model flag.userData) ! []
