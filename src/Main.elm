module Main exposing (main)

import Browser
import Html exposing (Html)
import Html.Events as E
import Ports
import Quote exposing (..)
import Return exposing (return)
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
    | SignIn


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case ( model, msg ) of
        -----------------------------------------
        -- Added quote
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
        -- Got current time
        -----------------------------------------
        ( Authenticated a, GotCurrentTime time ) ->
            { a | currentTime = time }
                |> Authenticated
                |> Return.singleton

        -----------------------------------------
        -- Sign in
        -----------------------------------------
        ( _, SignIn ) ->
            return model (Ports.signIn ())

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
            case quotes of
                quote :: _ ->
                    quoteView quote

                [] ->
                    [ Html.text "Haven't got any quotes yet." ]

        NotAuthenticated ->
            notAuthenticated



-- QUOTES


quoteView : Quote -> List (Html Msg)
quoteView quote =
    [ Html.div
        [ T.flex
        , T.font_display
        , T.h_screen
        , T.items_center
        , T.justify_center
        , T.text_gray_800
        ]
        [ -----------------------------------------
          -- Quote
          -----------------------------------------
          Html.div
            [ T.max_w_xl ]
            [ Html.div
                [ T.leading_snug
                , T.text_4xl
                , T.text_justify
                ]
                [ Html.text quote.quote ]

            -- Author
            ---------
            , Html.div
                [ T.font_bold
                , T.mt_5
                , T.text_sm
                ]
                [ Html.text ("— " ++ quote.author) ]
            ]
        ]
    ]



-- NOT AUTHENTICATED


notAuthenticated : List (Html Msg)
notAuthenticated =
    [ Html.button
        [ E.onClick SignIn

        --
        , T.rounded
        ]
        [ Html.text "Sign in with Fission" ]
    ]
