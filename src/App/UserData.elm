module UserData exposing (..)

import Quote exposing (Quote)



-- 🧩


type alias UserData =
    { quotes : List Quote
    , selectionHistory : List String
    }
