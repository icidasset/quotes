module Model exposing (..)

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
    mdl : Material.Model
  , page : Page
  }



-- Initial State


initial : Page -> Model
initial page =
  { collectionUrl = ""
  , cssmodules = Dict.empty
  , mdl = Material.model
  , page = page
  }



-- User-data helpers

initialUserData : UserDataModel
initialUserData =
  { collectionUrl = "" }


toUserData : Model -> UserDataModel
toUserData model =
  { collectionUrl = model.collectionUrl }


fromUserData : Model -> Maybe UserDataModel -> Model
fromUserData model userData =
  let
    userData' = withDefault initialUserData userData
  in
    { model | collectionUrl = userData'.collectionUrl }
