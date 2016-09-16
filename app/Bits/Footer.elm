module Bits.Footer exposing (render)

import Html exposing (Html, div, footer, text)
import Material.Button as Button
import Material.Icon as Icon

import CSSModules exposing (cssmodule)
import Messages exposing (Msg(..))
import Model exposing (Model)
import Routing exposing (Page(..))
import Types exposing (Mdl)


render : Model -> Html Msg
render model =
  footer
    [ cssmodule model "Footer.bit" ]
    [ navigation model ]


navigation : Model -> Html Msg
navigation model =
  case model.page of
    Index ->
      div [] (
        List.concat [
          (button model "settings" GoToSettings "Show settings"),
          (button model "arrow_forward" SelectRandomQuote "Show another quote")
        ]
      )

    Settings ->
      div [] (button model "format_quote" GoToIndex "Show quotes")


button : Model -> String -> Msg -> String -> List (Html Msg)
button model icon clickMsg title =
  [ Button.render Mdl [0] model.mdl
      [ Button.onClick clickMsg
      ]
      [ Icon.i icon ]
  ]
