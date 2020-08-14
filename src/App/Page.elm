module Page exposing (..)

import Url exposing (Url)
import Url.Parser as Url exposing (..)



-- 🧩


type Page
    = Index
    | Add AddContext



-- ADD


type alias AddContext =
    { author : String
    , quote : String
    }


mapAdd : (AddContext -> AddContext) -> Page -> Page
mapAdd fn screen =
    case screen of
        Add a ->
            Add (fn a)

        s ->
            s


add : Page
add =
    Add { author = "", quote = "" }



-- 🛠


fromUrl : Url -> Page
fromUrl url =
    -- Hash-based routing
    { url | path = Maybe.withDefault "" url.fragment }
        |> Url.parse parser
        |> Maybe.withDefault Index


path : { from : Page, to : Page } -> String
path { from, to } =
    let
        -- For SPA routing, which we don't have atm:
        -- prefix =
        --     if from == Index then
        --         ""
        --
        --     else
        --         "../"
        prefix =
            "#/"
    in
    String.append
        prefix
        (case to of
            Add _ ->
                "add"

            Index ->
                ""
        )



-- ㊙️


parser : Parser (Page -> a) a
parser =
    oneOf
        [ map Index top
        , map add (s "add")
        ]
