module View exposing (..)

import Html exposing (Html, section, text)
import Html.Attributes exposing (..)
import TouchEvents as TE

import Bits.Pages
import Bits.Footer
import Css.Modules exposing (cssmodule)
import Model.Types exposing (Model, Msg(..))


view : Model -> Html Msg
view model =
  section
    [ cssmodule model "Main.bit"
    , TE.onTouchEvent TE.TouchStart OnTouchStart
    , TE.onTouchEvent TE.TouchEnd OnTouchEnd
    ]
    [
      (Bits.Footer.render model),
      (Bits.Pages.render model)
    ]
