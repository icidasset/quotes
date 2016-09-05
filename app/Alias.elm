module Alias exposing (..)

import Html exposing (Html)
import Material
import Messages exposing (Msg)
import Model exposing (Model)


type alias Mdl = Material.Model
type alias Renderer = Model -> Html Msg
