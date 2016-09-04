module View exposing (..)

import Html exposing (Html, section, text)
import Html.Attributes exposing (..)

import CSSModules exposing (cssmodule)
import Model exposing (Model)
import Update exposing (Msg)

import Bits.Pages
import Bits.Footer


view : Model -> Html Msg
view model =
  section
    [ cssmodule model "Main.component" ]
    [
      (Bits.Footer.render model),
      (Bits.Pages.render model)
    ]
