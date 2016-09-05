module Bits.Pages exposing (render)

import Regex exposing (contains, regex)
import Html exposing (div, text)
import Html.Events exposing (onClick)

import Material.Card as Card
import Material.Elevation as Elevation
import Material.Options exposing (css, nop)
import Material.Textfield as Textfield

import Alias exposing (Renderer)
import CSSModules exposing (cssmodule)
import Routing exposing (Page(..))
import Update exposing (Msg(Mdl, SetCollectionUrl))


render : Renderer
render model =
  case model.page of
    Index ->
      text "Index"

    Settings ->
      settings model



-- Settings


settings : Renderer
settings model =
  Card.view
    [ Elevation.e2 ]
    [ Card.title
        []
        [ Card.head [] [ text "Settings" ] ]

    , Card.actions
        [ css "padding" "8px 16px" ]
        [ Textfield.render Mdl [0] model.mdl
          [ Textfield.label "Quotes JSON URL"
          , Textfield.floatingLabel
          , Textfield.text'
          , Textfield.value model.collectionUrl
          , Textfield.onInput SetCollectionUrl
          , validateUrlInput model.collectionUrl
          ]
        ]

    ]


validateUrlInput string =
  if contains (regex "^https?://\\w+") string then
    nop

  else
    Textfield.error "Invalid url"
