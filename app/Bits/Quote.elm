module Bits.Quote exposing (render)

import ElmEscapeHtml
import Html exposing (Html, div, text)

import Css.Modules
import Model.Types exposing (Model, Msg)
import Quotes.Types exposing (Quote)


render : Quote -> Model -> Html Msg
render quote model =
  let
    cssmod = \x -> Css.Modules.cssmodule model ("Quote." ++ x)

  in
    div
      [ cssmod "bit" ]
      [ div
          [ cssmod "quote" ]
          [ text quote.quote ]

      , div
          [ cssmod "author" ]
          [ text ((ElmEscapeHtml.unescape "&mdash;&nbsp;&nbsp;") ++ quote.author) ]
      ]
