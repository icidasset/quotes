module Main exposing (main)

import Browser
import Html exposing (Html)
import Quote exposing (..)
import Return
import Tailwind as T
import Time



-- ⛩


type alias Flags =
    { authenticated : Bool
    , currentTime : Int
    , newUser : Maybe Bool
    , quotes : Maybe (List Quote)
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


type Model
    = Authenticated { currentTime : Time.Posix, quotes : List Quote }
    | NotAuthenticated


init : Flags -> ( Model, Cmd Msg )
init flags =
    ( -----------------------------------------
      -- Model
      -----------------------------------------
      if flags.authenticated then
        Authenticated
            { currentTime = Time.millisToPosix flags.currentTime
            , quotes = Maybe.withDefault [] flags.quotes
            }

      else
        NotAuthenticated
      -----------------------------------------
      -- Command
      -----------------------------------------
    , Cmd.none
    )



-- 📣


type Msg
    = AddedQuote { author : String, quote : String }
    | GotCurrentTime Time.Posix


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case ( model, msg ) of
        -----------------------------------------
        -- Added Quote
        -----------------------------------------
        ( Authenticated a, AddedQuote properties ) ->
            let
                unixTime =
                    a.currentTime
                        |> Time.posixToMillis
                        |> String.fromInt

                id =
                    unixTime ++ "-" ++ String.fromInt (List.length a.quotes)

                quote =
                    { id = id
                    , author = properties.author
                    , quote = properties.quote
                    }
            in
            { a | quotes = a.quotes ++ [ quote ] }
                |> Authenticated
                |> Return.singleton

        -----------------------------------------
        -- Got Current Time
        -----------------------------------------
        ( Authenticated a, GotCurrentTime time ) ->
            { a | currentTime = time }
                |> Authenticated
                |> Return.singleton

        -----------------------------------------
        -- -
        -----------------------------------------
        _ ->
            Return.singleton model



-- 📰


subscriptions : Model -> Sub Msg
subscriptions _ =
    Time.every (60 * 1000) GotCurrentTime



-- 🖼


view : Model -> Browser.Document Msg
view model =
    { title = "Quotes"
    , body = body model
    }


body : Model -> List (Html Msg)
body model =
    case model of
        Authenticated { quotes } ->
            [ Html.text ""
            ]

        NotAuthenticated ->
            [ Html.button
                [ T.rounded
                ]
                [ Html.text "Login with Fission" ]
            ]
