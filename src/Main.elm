module Main exposing (main)

import Browser
import Html exposing (Html)



-- ⛩


type alias Flags =
    { authenticated : Bool
    , newUser : Maybe Bool
    , throughLobby : Bool
    , username : Maybe String
    }


main : Program Flags Model Msg
main =
    Browser.document
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }



-- 🌳


type alias Model =
    {}


init : Flags -> ( Model, Cmd Msg )
init flags =
    ( {}, Cmd.none )



-- 📣


type Msg
    = Bypass


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    ( {}, Cmd.none )



-- 📰


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.none



-- 🖼


view : Model -> Browser.Document Msg
view model =
    { title = "Quotes"
    , body =
        [ Html.text "Todo"
        ]
    }
