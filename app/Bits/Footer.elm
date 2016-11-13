module Bits.Footer exposing (render)

import Html exposing (Html, div, footer, span, text)
import Html.Attributes exposing (title)
import Material.Button as Button
import Material.Icon as Icon
import Material.Options as Options
import Material.Typography as Typo

import Css.Modules exposing (cssmodule)
import Model.Types exposing (Model, Msg(..))
import Routing exposing (Page(..))


render : Model -> Html Msg
render model =
  div
    [ cssmodule model "Footer.wrapper" ]
    [
      div
        [ cssmodule model "Footer.info" ]
        [ if (model.fetchError == False) && (model.page == Index) then
            info (count model)
          else
            text ""
        ]
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
        [ button model "format_quote" GoToIndex "Show quotes"
        , button model "settings_backup_restore" ResetSeen "Reset quotes history (counter)"
        ]


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
    if total > 0 then
      (toString index) ++ " of " ++ (toString total)
    else
      ""
