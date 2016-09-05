module Bits.Pages exposing (render)

import Array
import Regex exposing (contains, regex)
import Html exposing (div, text)
import Html.Events exposing (onClick)
import Maybe exposing (withDefault)

import Material.Card as Card
import Material.Elevation as Elevation
import Material.Options exposing (css, nop)
import Material.Spinner as Loading
import Material.Textfield as Textfield
import Random

import Alias exposing (Renderer)
import CSSModules exposing (cssmodule)
import Messages exposing (Msg(Mdl, SetCollectionUrl))
import Routing exposing (Page(..))


render : Renderer
render model =
  case model.page of
    Index -> index model
    Settings -> settings model



-- Index

index : Renderer
index model =
  if model.fetchInProgress == True then
    Loading.spinner
      [ Loading.active True ]

  else if Array.length(model.quotes) == 0 then
    text "No quotes found"

  else
    -- let
    --   index = fst (
    --     Random.step
    --       (Random.int 0 (Array.length(model.quotes) - 1))
    --       (Random.initialSeed 535235345)
    --   )
    --
    --   quote = Array.get index model.quotes
    -- in
    --   case quote of
    --     Just quote' -> text quote'
    --     Nothing -> text "No quotes found"

    text (toString model.quotes)



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
  if string == "" then
    nop

  else if contains (regex "^https?://\\w+") string then
    nop

  else
    Textfield.error "Invalid url"
