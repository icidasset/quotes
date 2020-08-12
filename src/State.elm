module State exposing (..)

import Browser exposing (UrlRequest)
import Browser.Navigation as Navigation
import Confirm
import List.Extra as List
import Page
import Ports
import Quote exposing (..)
import Radix exposing (..)
import Random
import Return exposing (andThen, return)
import Time
import Url exposing (Url)



-- 🌳


init : Flags -> Url -> Navigation.Key -> ( Model, Cmd Msg )
init flags url navKey =
    let
        initialSeed =
            Random.initialSeed flags.currentTime

        quotes =
            Maybe.withDefault [] flags.quotes

        selectedQuote =
            if flags.authenticated then
                pickRandomQuote
                    initialSeed
                    flags.selectionHistory
                    quotes

            else
                ( Nothing, initialSeed )

        ( selectionHistory, selectionHistoryCmd ) =
            if flags.authenticated then
                maybeAddToSelectionHistory
                    flags.selectionHistory
                    quotes
                    (Tuple.first selectedQuote)

            else
                ( flags.selectionHistory, Cmd.none )
    in
    ( -----------------------------------------
      -- Model
      -----------------------------------------
      { authenticated = flags.authenticated
      , confirmation = Nothing
      , currentTime = Time.millisToPosix flags.currentTime
      , navKey = navKey
      , page = Page.fromUrl url
      , quotes = quotes
      , selectedQuote = selectedQuote
      , selectionHistory = selectionHistory
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

        ImportedQuotes a ->
            importedQuotes a

        LinkClicked a ->
            linkClicked a

        RemoveConfirmation ->
            removeConfirmation

        SelectNextQuote ->
            selectNextQuote

        SignIn ->
            signIn

        UrlChanged a ->
            urlChanged a



-- 📰


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.batch
        [ Ports.importedQuotes ImportedQuotes
        , Time.every (60 * 1000) GotCurrentTime
        ]



-- 🛠  ▒▒  CRUD


addQuote : Page.AddContext -> Manager
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
            , author = String.trim properties.author
            , quote = String.trim properties.quote
            }

        newCollection =
            model.quotes ++ [ quote ]

        ( selectionHistory, selectionHistoryCmd ) =
            maybeAddToSelectionHistory
                model.selectionHistory
                newCollection
                (Just quote)
    in
    [ Ports.addQuote quote
    , Ports.triggerRepaint ()
    , selectionHistoryCmd

    --
    , { from = model.page, to = Page.Index }
        |> Page.path
        |> Navigation.pushUrl model.navKey
    ]
        |> Cmd.batch
        |> return
            { model
                | quotes = newCollection
                , selectedQuote = Tuple.mapFirst (\_ -> Just quote) model.selectedQuote
                , selectionHistory = selectionHistory
            }


gotAddInputForAuthor : String -> Manager
gotAddInputForAuthor input model =
    (\c -> { c | author = input })
        |> (\map -> Page.mapAdd map model.page)
        |> (\page -> { model | page = page })
        |> Return.singleton


gotAddInputForQuote : String -> Manager
gotAddInputForQuote input model =
    (\c -> { c | quote = input })
        |> (\map -> Page.mapAdd map model.page)
        |> (\page -> { model | page = page })
        |> Return.singleton


removeQuote : Quote -> Manager
removeQuote quote model =
    -----------------------------------------
    -- Confirmed
    -----------------------------------------
    if model.confirmation == Just Confirm.QuoteRemoval then
        quote
            |> Ports.removeQuote
            |> return
                { model
                    | quotes = List.filter (.id >> (/=) quote.id) model.quotes
                    , selectionHistory = List.remove quote.id model.selectionHistory
                }
            |> andThen selectNextQuote

    else
        -----------------------------------------
        -- Not yet
        -----------------------------------------
        Return.singleton { model | confirmation = Just Confirm.QuoteRemoval }



-- 🛠  ▒▒  OTHER


gotCurrentTime : Time.Posix -> Manager
gotCurrentTime time model =
    Return.singleton { model | currentTime = time }


importedQuotes : List Quote -> Manager
importedQuotes quotes model =
    case model.quotes of
        [] ->
            selectNextQuote { model | quotes = quotes }

        _ ->
            Return.singleton { model | quotes = model.quotes ++ quotes }


linkClicked : UrlRequest -> Manager
linkClicked request model =
    case request of
        Browser.Internal url ->
            return model (Navigation.pushUrl model.navKey <| Url.toString url)

        Browser.External href ->
            return model (Navigation.load href)


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


signIn : Manager
signIn model =
    return model (Ports.signIn ())


urlChanged : Url -> Manager
urlChanged url model =
    Return.singleton { model | page = Page.fromUrl url }



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
            ( [], Ports.saveSelectionHistory [] )


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
