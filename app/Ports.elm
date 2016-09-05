port module Ports exposing (..)

import Model exposing (UserDataModel)


port localStorage : UserDataModel -> Cmd msg
