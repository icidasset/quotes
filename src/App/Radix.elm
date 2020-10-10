module Radix exposing (..)

import Browser exposing (UrlRequest)
import Browser.Navigation as Navigation
import Confirm exposing (Confirmation)
import Page exposing (Page)
import Quote exposing (..)
import Random
import Time
import Url exposing (Url)
import UserData exposing (UserData)



-- ⛩


type alias Flags =
    { authenticated : Bool
    , currentTime : Int
    , newUser : Maybe Bool
    , throughLobby : Bool
    , username : Maybe String
    }



-- 🌳


type alias Model =
    { confirmation : Maybe Confirmation
    , currentTime : Time.Posix
    , isLoading : Bool
    , navKey : Navigation.Key
    , page : Page
    , selectedQuote : ( Maybe Quote, Random.Seed )
    , userData : Maybe UserData
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
    | ClearHistory
    | GotCurrentTime Time.Posix
    | ImportedQuotes (List Quote)
    | LinkClicked UrlRequest
    | LoadUserData UserData
    | RemoveConfirmation
    | SelectNextQuote
    | SignIn
    | UrlChanged Url


type alias Manager =
    Model -> ( Model, Cmd Msg )
