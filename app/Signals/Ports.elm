port module Signals.Ports exposing (..)

import Model.Types exposing (UserDataModel)



-- Ports


port localStorage : UserDataModel -> Cmd msg
