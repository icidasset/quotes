module Routing exposing (..)

import String

import Navigation
import UrlParser exposing (Parser, (</>), format, oneOf, s, string)


type alias LocationResult =
  Result String Page


type Page =
  Index
  | Settings


matchers : Parser (Page -> a) a
matchers =
  oneOf
    [ format Settings   (s "settings")
    , format Index      (s "")
    ]


{-| Parse the location info and return a `Page` or an error `String`.
Uses the `matcher` above to find a page based on the `pathname`.
If the matcher doesn't find anything an error is returned.
-}
locationParser : Navigation.Location -> LocationResult
locationParser location =
  location.pathname
  |> String.dropLeft 1
  |> UrlParser.parse identity matchers


{-| Transform the locationParser to a urlParser.
-}
urlParser : Navigation.Parser LocationResult
urlParser = Navigation.makeParser locationParser


{-| Transform the result from the locationParser to a Page.
If we have an error, ie. the page wasn't found, we go to the `Index` Page.
-}
toPage : LocationResult -> Page
toPage result =
  case result of
    Ok page -> page
    Err _ -> Index
