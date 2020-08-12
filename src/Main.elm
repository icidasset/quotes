module Main exposing (main)

import Browser
import Radix exposing (..)
import State
import View



-- ⛩


main : Program Flags Model Msg
main =
    Browser.application
        { init = State.init
        , view = View.view
        , update = State.update
        , subscriptions = State.subscriptions

        --
        , onUrlChange = UrlChanged
        , onUrlRequest = LinkClicked
        }
