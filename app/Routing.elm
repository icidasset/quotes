module Routing exposing
  ( Page(..)
  , urlParser
  )

import Navigation
import String
import UrlParser exposing (Parser, (</>), format, oneOf, s, string)



-- Public


type Page = Index | Settings


{-| Transform the locationParser to a urlParser.
-}
urlParser : Navigation.Parser Page
urlParser = Navigation.makeParser locationParser



-- Private


routes : Parser (Page -> a) a
routes = oneOf
  [ format Settings   (s "settings")
  , format Index      (s "")
  ]


{-| Parse the location info and return a `Page`.
-}
locationParser : Navigation.Location -> Page
locationParser location =
  location.pathname
    |> String.dropLeft 1
    |> UrlParser.parse identity routes
    |> Result.withDefault Index
