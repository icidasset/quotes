module Radix exposing (..)

import Browser exposing (UrlRequest)
import Browser.Navigation as Navigation
import Confirm exposing (Confirmation)
import Page exposing (Page)
import Quote exposing (..)
import Random
import Time
import Url exposing (Url)



-- ⛩


type alias Flags =
    { authenticated : Bool
    , currentTime : Int
    , newUser : Maybe Bool
    , quotes : Maybe (List Quote)
    , selectionHistory : List String
    , throughLobby : Bool
    , username : Maybe String
    }



-- 🌳


type alias Model =
    { authenticated : Bool
    , confirmation : Maybe Confirmation
    , currentTime : Time.Posix
    , navKey : Navigation.Key
    , page : Page
    , quotes : List Quote
    , selectedQuote : ( Maybe Quote, Random.Seed )
    , selectionHistory : List String
    }



-- 📣


type
    Msg
    -----------------------------------------
    -- CRUD
    -----------------------------------------
    = AddQuote Page.AddContext
    | GotAddInputForAuthor String
    | GotAddInputForQuote String
    | RemoveQuote Quote
      -----------------------------------------
      -- Other
      -----------------------------------------
    | GotCurrentTime Time.Posix
    | ImportedQuotes (List Quote)
    | LinkClicked UrlRequest
    | RemoveConfirmation
    | SelectNextQuote
    | SignIn
    | UrlChanged Url


type alias Manager =
    Model -> ( Model, Cmd Msg )
