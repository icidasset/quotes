module Bits.Pages exposing (render)

import Html exposing (div, text)
import Html.Events exposing (onClick)
import Material.Card as Card

import Alias exposing (Renderer)
import CSSModules exposing (cssmodule)
import Routing exposing (Page(..))
import Update exposing (Msg(..))


render : Renderer
render model =
  case model.page of
    Index ->
      text "Hello"

    Settings ->
      Card.view
        []
        [ Card.title
            []
            [ Card.head [] [ text "World" ] ]
        ]
