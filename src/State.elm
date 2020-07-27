module State exposing (..)

import Confirm
import List.Extra as List
import Ports
import Quote exposing (..)
import Radix exposing (..)
import Random
import Return exposing (return)
import Screen exposing (..)
import Time



-- 🌳


init : Flags -> ( Model, Cmd Msg )
init flags =
    let
        quotes =
            Maybe.withDefault [] flags.quotes

        selectedQuote =
            pickRandomQuote
                (Random.initialSeed flags.currentTime)
                quotes
    in
    ( -----------------------------------------
      -- Model
      -----------------------------------------
      { authenticated = flags.authenticated
      , confirmation = Nothing
      , currentTime = Time.millisToPosix flags.currentTime
      , quotes = quotes
      , selectedQuote = selectedQuote
      , screen = Index
      }
      -----------------------------------------
      -- Command
      -----------------------------------------
    , Cmd.none
    )



-- 📣


update : Msg -> Model -> ( Model, Cmd Msg )
update msg =
    case msg of
        -----------------------------------------
        -- CRUD
        -----------------------------------------
        AddQuote a ->
            addQuote a

        GotAddInputForAuthor a ->
            gotAddInputForAuthor a

        GotAddInputForQuote a ->
            gotAddInputForQuote a

        RemoveQuote a ->
            removeQuote a

        -----------------------------------------
        -- Other
        -----------------------------------------
        GotCurrentTime a ->
            gotCurrentTime a

        RemoveConfirmation ->
            removeConfirmation

        ShowScreen a ->
            showScreen a

        SignIn ->
            signIn



-- 📰


subscriptions : Model -> Sub Msg
subscriptions _ =
    Time.every (60 * 1000) GotCurrentTime



-- 🛠  ▒▒  CRUD


addQuote : Screen.AddContext -> Manager
addQuote properties model =
    let
        unixTime =
            model.currentTime
                |> Time.posixToMillis
                |> String.fromInt

        id =
            unixTime ++ "-" ++ String.fromInt (List.length model.quotes)

        quote =
            { id = id
            , author = properties.author
            , quote = properties.quote
            }
    in
    return
        { model
            | quotes = model.quotes ++ [ quote ]
            , screen = Index
            , selectedQuote = Tuple.mapFirst (\_ -> Just quote) model.selectedQuote
        }
        (Ports.addQuote quote)


gotAddInputForAuthor : String -> Manager
gotAddInputForAuthor input model =
    (\c -> { c | author = input })
        |> (\map -> Screen.mapAdd map model.screen)
        |> (\screen -> { model | screen = screen })
        |> Return.singleton


gotAddInputForQuote : String -> Manager
gotAddInputForQuote input model =
    (\c -> { c | quote = input })
        |> (\map -> Screen.mapAdd map model.screen)
        |> (\screen -> { model | screen = screen })
        |> Return.singleton


removeQuote : Quote -> Manager
removeQuote quote model =
    -----------------------------------------
    -- Confirmed
    -----------------------------------------
    if model.confirmation == Just Confirm.QuoteRemoval then
        let
            quotes =
                List.filter (.id >> (/=) quote.id) model.quotes

            selectedQuote =
                Tuple.mapFirst (\_ -> Nothing) model.selectedQuote
        in
        return
            { model
                | quotes = quotes
                , selectedQuote = selectedQuote
            }
            (Ports.removeQuote quote)

    else
        -----------------------------------------
        -- Not yet
        -----------------------------------------
        Return.singleton { model | confirmation = Just Confirm.QuoteRemoval }



-- 🛠  ▒▒  OTHER


gotCurrentTime : Time.Posix -> Manager
gotCurrentTime time model =
    Return.singleton { model | currentTime = time }


removeConfirmation : Manager
removeConfirmation model =
    Return.singleton { model | confirmation = Nothing }


showScreen : Screen -> Manager
showScreen screen model =
    Return.singleton { model | screen = screen }


signIn : Manager
signIn model =
    return model (Ports.signIn ())



-- ㊙️


pickRandomQuote : Random.Seed -> List Quote -> ( Maybe Quote, Random.Seed )
pickRandomQuote seed quotes =
    seed
        |> Random.step (Random.int 0 <| List.length quotes - 1)
        |> Tuple.mapFirst (\idx -> List.getAt idx quotes)
