module View exposing (..)

import Html exposing (Html, section, text)
import Html.Attributes exposing (..)

import CSSModules exposing (cssmodule)
import Messages exposing (Msg)
import Model exposing (Model)

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
