module Model exposing (..)

import Array exposing (Array)
import Dict exposing (Dict)
import Material
import Maybe exposing (Maybe, withDefault)
import Random
import Task exposing (toMaybe)
import Time exposing (Time)

import CSSModules
import Routing exposing (Page)


type alias Model = CSSModules.Model (SystemDataModel UserDataModel)


type alias UserDataModel =
  { collectionUrl : String
  }


type alias SystemDataModel a =
  { a |

    fetchInProgress : Bool
  , fetchError : Bool
  , initialTimestamp : Time
  , mdl : Material.Model
  , page : Page
  , quotes : Array (String, String)
  }



-- Initial State


initial : Page -> Model
initial page =
  { collectionUrl = ""
  , cssmodules = Dict.empty
  , fetchError = False
  , fetchInProgress = False
  , initialTimestamp = 0.0
  , mdl = Material.model
  , page = page
  , quotes = Array.empty
  }



-- User-data helpers

initialUserData : UserDataModel
initialUserData =
  { collectionUrl = "" }


toUserData : Model -> UserDataModel
toUserData model =
  { collectionUrl = model.collectionUrl }


fromUserData : Maybe UserDataModel -> Model -> Model
fromUserData userData model =
  let
    userData' = withDefault initialUserData userData
  in
    { model | collectionUrl = userData'.collectionUrl }



-- Quote helpers

getRandomQuote : Model -> Maybe { quote : String, author : String }
getRandomQuote model =
  let
    index = fst (
      Random.step
        (Random.int 0 (Array.length(model.quotes) - 1))
        (Random.initialSeed (round model.initialTimestamp))
    )

    quote = Array.get index model.quotes
  in
    case quote of
      Just quote' ->
        let
          quote   = (fst quote')
          author  = (snd quote')
        in
          Just { quote = quote, author = author }
      Nothing ->
        Nothing
