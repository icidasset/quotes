module Alias exposing (..)

import Html exposing (Html)
import Material
import Model exposing (Model)
import Update exposing (Msg)


type alias Mdl = Material.Model
type alias Renderer = Model -> Html Msg
