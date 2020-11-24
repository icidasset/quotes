port module Ports exposing (..)

import Quote exposing (Quote)
import Radix exposing (Initialisation)
import UserData exposing (UserData)



-- 📣


port addQuote : Quote -> Cmd msg


port removeQuote : Quote -> Cmd msg


port saveSelectionHistory : List String -> Cmd msg


port signIn : () -> Cmd msg


port triggerRepaint : () -> Cmd msg



-- 📰


port importedQuotes : (List Quote -> msg) -> Sub msg


port initialise : (Initialisation -> msg) -> Sub msg


port loadUserData : (UserData -> msg) -> Sub msg
