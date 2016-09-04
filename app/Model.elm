module Model exposing (..)

import Dict exposing (Dict)
import Material

import CSSModules
import Routing exposing (Page)


type alias Model = CSSModules.Model
  { mdl : Material.Model
  , page : Page
  }


initial : Page -> Model
initial page =
  { cssmodules = Dict.empty
  , mdl = Material.model
  , page = page
  }
