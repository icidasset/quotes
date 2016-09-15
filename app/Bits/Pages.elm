module Bits.Pages exposing (render)

import Regex exposing (contains, regex)
import Html exposing (Html, div, span, text)
import Html.Events exposing (onClick)
import Maybe exposing (withDefault)

import Material.Card as Card
import Material.Elevation as Elevation
import Material.Options exposing (css, nop)
import Material.Spinner as Loading
import Material.Textfield as Textfield

import Alias exposing (Renderer)
import Bits.Quote
import CSSModules exposing (cssmodule)
import Messages exposing (Msg(Mdl, SetCollectionUrl))
import Model exposing (Model)
import Quotes.Types
import Routing exposing (Page(..))


render : Renderer
render model =
  case model.page of
    Index -> index model
    Settings -> settings model



-- Index

index : Renderer
index model =
  let
    i = \msg -> info model (msg ++ " …") ""
    iSub = \msg -> \sub -> info model (msg ++ " …") sub
  in
    if model.fetchInProgress == True then
      Loading.spinner
        [ Loading.active True ]

    else if model.fetchError == True then
      iSub "Could not fetch quotes" "Are you sure you put in the correct url?"

    else if List.length(model.collection) == 0 then
      i "No quotes found"

    else
      case model.selectedQuote of
        Just quote -> Bits.Quote.render quote model
        Nothing -> i "No quotes found"


{-| Show info (message).
txt = Main text (large text)
sub = Sub text (small text)
-}
info : Model -> String -> String -> Html Msg
info model txt sub =
  div
    [ cssmodule model "Info.bit" ]
    [ div [] [ text txt ]
    , div [ cssmodule model "Info.sub-text" ] [ text sub ]
    ]



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
