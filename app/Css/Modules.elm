module Css.Modules exposing (Css, Flag, Model, Signature, class, cssmodule, decode, init)

{-| This library provides a way to use (PostCSS) CSS Modules with Elm.

A CSS-Modules dictionary is sent to Elm through a `Program` flag,
which has the following format:

    { "Main.component": "something" }

# Program
@docs init

# Lookup
@docs get

-}

import Dict exposing (Dict)
import Html exposing (Attribute)
import Html.Attributes
import Json.Decode exposing (Decoder, dict, string)


type alias Css a = Signature a
type alias Dictionary = Dict String String
type alias Flag = Json.Decode.Value
type alias Model a = { a | cssmodules : Dictionary }
type alias Signature a = String -> Attribute a


{-| The init function used with a `Program`.
Used like so:

    init : Maybe Css.Modules.Flag -> (Model, Cmd Msg)
    init possibleFlag = Css.Modules.init possibleFlag initialModelOfYourApp ! []

Where `initialModelOfYourApp` is a record that uses `Css.Modules.Model`.

    initialModelOfYourApp : Css.Modules.Model PrivateModel
    initialModelOfYourApp =
      { cssmodules = Dict.empty
      , somethingOfPrivateModel = ...
      }
-}
init : Maybe Flag -> Model a -> Model a
init maybe model =
  case maybe of
    Just flag -> { model | cssmodules = decode flag }
    Nothing   -> { model | cssmodules = Dict.empty }


{-| Decode the `Css.Modules.Flag`.
-}
decode : Flag -> Dictionary
decode flag =
  Json.Decode.decodeValue (dict string) flag
  |> Result.withDefault Dict.empty


{-| Get a className for a given cssmodule.
If the cssmodule is not found, it returns an empty string.
-}
class : Model a -> String -> String
class model moduleName =
  let
    className = Dict.get moduleName (model.cssmodules)
  in
    case className of
      Just cn -> cn
      Nothing -> ""


{-| Same as `class`, but returns a `Html.Attribute`.

    let
      cssmoduleName = "Main.component"
    in
      div [ Css.Modules.cssmodule model cssmoduleName ]

You can also use it like so:

    view model =
      let
        cssmodule = (Css.Modules.cssmodule model)
      in
        div [ cssmodule "Main.component" ]
-}
cssmodule : Model a -> Signature b
cssmodule model moduleName =
  Html.Attributes.class (class model moduleName)
