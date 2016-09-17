module Bits.Footer exposing (render)

import Html exposing (Html, div, footer, span, text)
import Html.Attributes exposing (title)
import Material.Button as Button
import Material.Icon as Icon
import Material.Options as Options
import Material.Typography as Typo

import CSSModules exposing (cssmodule)
import Messages exposing (Msg(..))
import Model exposing (Model)
import Routing exposing (Page(..))
import Types exposing (Mdl)


render : Model -> Html Msg
render model =
  div
    [ cssmodule model "Footer.wrapper" ]
    [
      div
        [ cssmodule model "Footer.info" ]
        [ info (count model) ]
    , footer
        [ cssmodule model "Footer.bit" ]
        [ navigation model ]
    ]


navigation : Model -> Html Msg
navigation model =
  case model.page of
    Index ->
      div
        []
        [ (button model "settings" GoToSettings "Show settings")
        , (
            if model.collectionIsEmpty == False then
              (button model "arrow_forward" SelectRandomQuote "Show another quote")
            else
              (text "")
          )
        ]

    Settings ->
      div
        []
        [ button model "format_quote" GoToIndex "Show quotes" ]


button : Model -> String -> Msg -> String -> Html Msg
button model icon clickMsg theTitle =
  Options.span
      [ Options.attribute <| title theTitle ]
      [ Button.render Mdl [0] model.mdl
        [ Button.onClick clickMsg ]
        [ Icon.i icon ]
      ]


info : String -> Html Msg
info label =
  Options.styled span
    [ Typo.menu ]
    [ text label ]


count : Model -> String
count model =
  let
    index = (List.length model.collectionSeen)
    total = (List.length model.collection)
  in
    if (total > 0) && (model.fetchError == False) then
      (toString index) ++ " of " ++ (toString total)
    else
      ""
