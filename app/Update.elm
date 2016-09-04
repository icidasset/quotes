module Update exposing (..)

import Material
import Navigation

import CSSModules
import Model exposing (Model)
import Routing exposing (LocationResult, toPage)


type Msg =
  GoToIndex
  | GoToSettings
  | Mdl (Material.Msg Msg)



-- Model


updateModel : Msg -> Model -> (Model, Cmd Msg)
updateModel msg model =
  case msg of
    -- Pages
    GoToIndex ->
      model ! [Navigation.newUrl "/"]

    GoToSettings ->
      model ! [Navigation.newUrl "/settings"]

    -- Material Design
    Mdl msg' ->
      Material.update msg' model



-- Navigation


urlUpdated : LocationResult -> Model -> (Model, Cmd Msg)
urlUpdated result model =
  { model | page = (toPage result) } ! []



-- Init


setInitialModel : Maybe CSSModules.Flag -> LocationResult -> (Model, Cmd Msg)
setInitialModel maybe result =
  let
    model = toPage result
    |> Model.initial
    |> CSSModules.init maybe
  in
    model ! []
