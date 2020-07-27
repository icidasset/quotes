port module Ports exposing (..)

import Quote exposing (Quote)



-- 📣


port addQuote : Quote -> Cmd msg


port removeQuote : Quote -> Cmd msg


port signIn : () -> Cmd msg
