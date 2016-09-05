module Model exposing (..)

import Array exposing (Array)
import Dict exposing (Dict)
import Material
import Maybe exposing (Maybe, withDefault)

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
