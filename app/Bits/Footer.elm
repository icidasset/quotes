module Bits.Footer exposing (render)

import Html exposing (Html, div, footer, text)
import Material.Button as Button
import Material.Icon as Icon

import Alias exposing (Mdl, Renderer)
import CSSModules exposing (cssmodule)
import Messages exposing (Msg(..))
import Model exposing (Model)
import Routing exposing (Page(..))


render : Renderer
render model =
  footer
    [ cssmodule model "Footer.bit" ]
    [ navigation model ]


navigation : Model -> Html Msg
navigation model =
  case model.page of
    Index ->
      div [] (button model "settings" GoToSettings "Show settings")

    Settings ->
      div [] (button model "format_quote" GoToIndex "Show quotes")


button : Model -> String -> Msg -> String -> List (Html Msg)
button model icon clickMsg title =
  [ Button.render Mdl [0] model.mdl
      [ Button.onClick clickMsg
      ]
      [ Icon.i icon ]
  ]
