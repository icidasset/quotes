module State exposing (..)

import Browser exposing (UrlRequest)
import Browser.Navigation as Navigation
import Confirm
import ContextMenu
import List.Extra as List
import Page
import Ports
import Quote exposing (..)
import Radix exposing (..)
import Random
import Return exposing (andThen, return)
import Time
import Url exposing (Url)
import UserData exposing (UserData)



-- 🌳


init : Flags -> Url -> Navigation.Key -> ( Model, Cmd Msg )
init flags url navKey =
    let
        initialSeed =
            Random.initialSeed flags.currentTime
    in
    ( -----------------------------------------
      -- Model
      -----------------------------------------
      { confirmation = Nothing
      , contextMenu = ContextMenu.init
      , currentTime = Time.millisToPosix flags.currentTime
      , isLoading = flags.authenticated
      , navKey = navKey
      , page = Page.fromUrl url
      , selectedQuote = ( Nothing, initialSeed )
      , userData = Nothing
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
        ClearHistory ->
            clearHistory

        GotCurrentTime a ->
            gotCurrentTime a

        ImportedQuotes a ->
            importedQuotes a

        LinkClicked a ->
            linkClicked a

        LoadUserData a ->
            loadUserData a

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
        , Ports.loadUserData LoadUserData
        , Time.every (60 * 1000) GotCurrentTime
        ]



-- 🛠  ▒▒  CRUD


addQuote : Page.AddContext -> Manager
addQuote properties model =
    case model.userData of
        Just userData ->
            let
                unixTime =
                    model.currentTime
                        |> Time.posixToMillis
                        |> String.fromInt

                id =
                    unixTime ++ "-" ++ String.fromInt (List.length userData.quotes)

                quote =
                    { id = id
                    , author = String.trim properties.author
                    , quote = String.trim properties.quote
                    }

                newCollection =
                    userData.quotes ++ [ quote ]

                ( selectionHistory, selectionHistoryCmd ) =
                    maybeAddToSelectionHistory
                        userData.selectionHistory
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
                        | selectedQuote = Tuple.mapFirst (\_ -> Just quote) model.selectedQuote
                        , userData =
                            Just
                                { quotes = newCollection
                                , selectionHistory = selectionHistory
                                }
                    }

        Nothing ->
            Return.singleton model


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
        let
            userData =
                Maybe.map
                    (\u ->
                        { u
                            | quotes = List.filter (.id >> (/=) quote.id) u.quotes
                            , selectionHistory = List.remove quote.id u.selectionHistory
                        }
                    )
                    model.userData
        in
        quote
            |> Ports.removeQuote
            |> return { model | userData = userData }
            |> andThen selectNextQuote

    else
        -----------------------------------------
        -- Not yet
        -----------------------------------------
        Return.singleton { model | confirmation = Just Confirm.QuoteRemoval }



-- 🛠  ▒▒  OTHER


clearHistory : Manager
clearHistory model =
    case model.userData of
        Just userData ->
            { userData | selectionHistory = [] }
                |> (\u -> { model | userData = Just u })
                |> selectNextQuote

        Nothing ->
            Return.singleton model


gotCurrentTime : Time.Posix -> Manager
gotCurrentTime time model =
    Return.singleton { model | currentTime = time }


importedQuotes : List Quote -> Manager
importedQuotes quotes model =
    case Maybe.map (\u -> ( u, u.quotes )) model.userData of
        Just ( u, [] ) ->
            selectNextQuote { model | userData = Just { u | quotes = quotes } }

        Just ( u, q ) ->
            Return.singleton { model | userData = Just { u | quotes = q ++ quotes } }

        Nothing ->
            Return.singleton model


linkClicked : UrlRequest -> Manager
linkClicked request model =
    case request of
        Browser.Internal url ->
            return model (Navigation.pushUrl model.navKey <| Url.toString url)

        Browser.External href ->
            return model (Navigation.load href)


loadUserData : UserData -> Manager
loadUserData userData model =
    let
        ( _, seed ) =
            model.selectedQuote

        quotes =
            userData.quotes

        previousSelectionHistory =
            if List.length userData.selectionHistory > List.length quotes then
                []

            else
                userData.selectionHistory

        selectedQuote =
            pickRandomQuote
                seed
                previousSelectionHistory
                quotes

        ( selectionHistory, selectionHistoryCmd ) =
            maybeAddToSelectionHistory
                previousSelectionHistory
                quotes
                (Tuple.first selectedQuote)
    in
    ( { model
        | isLoading = False
        , selectedQuote = selectedQuote
        , userData = Just { quotes = quotes, selectionHistory = selectionHistory }
      }
    , selectionHistoryCmd
    )


removeConfirmation : Manager
removeConfirmation model =
    Return.singleton { model | confirmation = Nothing }


selectNextQuote : Manager
selectNextQuote model =
    case model.userData of
        Just userData ->
            let
                selectedQuote =
                    pickRandomQuote
                        (Tuple.second model.selectedQuote)
                        userData.selectionHistory
                        userData.quotes

                ( selectionHistory, selectionHistoryCmd ) =
                    maybeAddToSelectionHistory
                        userData.selectionHistory
                        userData.quotes
                        (Tuple.first selectedQuote)
            in
            return
                { model
                    | selectedQuote = selectedQuote
                    , userData = Just { userData | selectionHistory = selectionHistory }
                }
                selectionHistoryCmd

        Nothing ->
            Return.singleton model


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
                ( x, y ) =
                    ( List.length selectionHistory
                    , List.length quotes
                    )

                new =
                    case ( selectionHistory, x == y ) of
                        ( lastSelectedId :: _, True ) ->
                            if y == 1 then
                                [ quote.id ]

                            else
                                [ quote.id, lastSelectedId ]

                        _ ->
                            quote.id :: selectionHistory
            in
            ( new, Ports.saveSelectionHistory new )

        Nothing ->
            ( [], Ports.saveSelectionHistory [] )


pickRandomQuote : Random.Seed -> List String -> List Quote -> ( Maybe Quote, Random.Seed )
pickRandomQuote seed selectionHistory quotes =
    let
        ( x, y ) =
            ( List.length selectionHistory
            , List.length quotes
            )

        filterFunction =
            case ( selectionHistory, x == y ) of
                ( lastSelectedId :: _, True ) ->
                    if y == 1 then
                        \_ -> True

                    else
                        .id >> (/=) lastSelectedId

                _ ->
                    \quote -> List.notMember quote.id selectionHistory

        unselectedQuotes =
            List.filter filterFunction quotes
    in
    seed
        |> Random.step (Random.int 0 <| List.length unselectedQuotes - 1)
        |> Tuple.mapFirst (\idx -> List.getAt idx unselectedQuotes)
