module Radix exposing (..)

import Confirm exposing (Confirmation)
import Quote exposing (..)
import Random
import Screen exposing (Screen(..))
import Time



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
    , quotes : List Quote
    , selectedQuote : ( Maybe Quote, Random.Seed )
    , selectionHistory : List String
    , screen : Screen
    }



-- 📣


type
    Msg
    -----------------------------------------
    -- CRUD
    -----------------------------------------
    = AddQuote Screen.AddContext
    | GotAddInputForAuthor String
    | GotAddInputForQuote String
    | RemoveQuote Quote
      -----------------------------------------
      -- Other
      -----------------------------------------
    | GotCurrentTime Time.Posix
    | RemoveConfirmation
    | SelectNextQuote
    | ShowScreen Screen
    | SignIn


type alias Manager =
    Model -> ( Model, Cmd Msg )
