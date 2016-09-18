module Bits.Pages exposing (render)

import Regex exposing (contains, regex)
import Html exposing (Html, code, div, p, pre, span, text)
import Html.Events exposing (onClick)
import Maybe exposing (withDefault)

import Material.Card as Card
import Material.Elevation as Elevation
import Material.Options as Options exposing (cs, css, nop)
import Material.Spinner as Loading
import Material.Textfield as Textfield

import Bits.Quote
import CSSModules exposing (cssmodule)
import Messages exposing (Msg(Mdl, SetCollectionUrl))
import Model exposing (Model)
import Routing exposing (Page(..))


render : Model -> Html Msg
render model =
  case model.page of
    Index -> index model
    Settings -> settings model



-- Index

index : Model -> Html Msg
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

    else if model.collectionIsEmpty then
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


settings : Model -> Html Msg
settings model =
  Card.view
    [ cs (CSSModules.class model "Settings.bit")
    , Elevation.e2
    ]
    [ Card.title
        []
        [ Card.head [] [ text "Settings" ] ]

    , Card.text
        []
        [ text "Here you can set the url to the collection of quotes. "
        , text "Which points to a JSON document with the following structure:"
        , pre
            []
            [ code [] [ text "[{ quote: \"Quote\", author: \"Author\" }, ...]" ] ]
        , text "Or:"
        , pre
            []
            [ code [] [ text "{ data: [{ quote: \"Quote\", author: \"Author\" }, ...] }" ] ]
        ]

    , Card.actions
        [ css "padding" "8px 16px", Card.border ]
        [ p
            []
            []

        , Textfield.render Mdl [0] model.mdl
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
