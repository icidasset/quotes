module Screen exposing (..)

-- 🌳


type Screen
    = Add AddContext
    | Index



-- ADD


type alias AddContext =
    { author : String
    , quote : String
    }


mapAdd : (AddContext -> AddContext) -> Screen -> Screen
mapAdd fn screen =
    case screen of
        Add a ->
            Add (fn a)

        s ->
            s


add : Screen
add =
    Add { author = "", quote = "" }
