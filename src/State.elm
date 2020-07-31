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
                flags.selectionHistory
                quotes

        ( selectionHistory, selectionHistoryCmd ) =
            maybeAddToSelectionHistory
                flags.selectionHistory
                quotes
                (Tuple.first selectedQuote)
    in
    ( -----------------------------------------
      -- Model
      -----------------------------------------
      { authenticated = flags.authenticated
      , confirmation = Nothing
      , currentTime = Time.millisToPosix flags.currentTime
      , quotes = quotes
      , selectedQuote = selectedQuote
      , selectionHistory = selectionHistory
      , screen = Index
      }
      -----------------------------------------
      -- Command
      -----------------------------------------
    , selectionHistoryCmd
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

        SelectNextQuote ->
            selectNextQuote

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


selectNextQuote : Manager
selectNextQuote model =
    let
        selectedQuote =
            pickRandomQuote
                (Tuple.second model.selectedQuote)
                model.selectionHistory
                model.quotes

        ( selectionHistory, selectionHistoryCmd ) =
            maybeAddToSelectionHistory
                model.selectionHistory
                model.quotes
                (Tuple.first selectedQuote)
    in
    return
        { model
            | selectedQuote = selectedQuote
            , selectionHistory = selectionHistory
        }
        selectionHistoryCmd


showScreen : Screen -> Manager
showScreen screen model =
    Return.singleton { model | screen = screen }


signIn : Manager
signIn model =
    return model (Ports.signIn ())



-- ㊙️


maybeAddToSelectionHistory : List String -> List Quote -> Maybe Quote -> ( List String, Cmd Msg )
maybeAddToSelectionHistory selectionHistory quotes maybeQuote =
    case maybeQuote of
        Just quote ->
            let
                new =
                    if List.length selectionHistory + 1 > List.length quotes then
                        [ quote.id ]

                    else
                        quote.id :: selectionHistory
            in
            ( new, Ports.saveSelectionHistory new )

        Nothing ->
            ( selectionHistory, Cmd.none )


pickRandomQuote : Random.Seed -> List String -> List Quote -> ( Maybe Quote, Random.Seed )
pickRandomQuote seed selectionHistory quotes =
    let
        unselectedQuotes =
            if List.length selectionHistory + 1 > List.length quotes then
                quotes

            else
                List.filter
                    (\q -> List.notMember q.id selectionHistory)
                    quotes
    in
    seed
        |> Random.step (Random.int 0 <| List.length unselectedQuotes - 1)
        |> Tuple.mapFirst (\idx -> List.getAt idx unselectedQuotes)
