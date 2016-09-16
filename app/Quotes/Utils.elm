module Quotes.Utils exposing (..)

import Array
import Base64
import Json.Decode as Json exposing ((:=), andThen, object1, object2)
import Random exposing (Generator)
import Random.Array
import Result

import Types exposing (Quote, QuoteTuple)


{-| Convert a QuoteTuple to a Quote
-}
tupleToRecord : QuoteTuple -> Quote
tupleToRecord tuple =
  let
    quote   = (fst tuple)
    author  = (snd tuple)
    id      = Result.withDefault "undefined" (Base64.encode (author ++ quote))
  in
    { quote = quote, author = author, id = id }


{-| Get a random quote
-}
randomGenerator : List Quote -> List String -> Generator (Maybe Quote)
randomGenerator collection collectionSeen =
  collection
    |> filterSeen collectionSeen
    |> Array.fromList
    |> Random.Array.sample


{-| Filter out the "seen" quotes
-}
filterSeen : List String -> List Quote -> List Quote
filterSeen collectionSeen collection =
  let
    isSeen = \quote ->
      if (List.member quote.id collectionSeen) then False
      else True
  in
    List.filter isSeen collection


{-| Build the list of "seen" quote ids.
Should:
  + Filter out old/non-existing ids
  + Add the id of a given quote (if there is one) to the list
  + Clear list if given quote is Nothing
-}
buildSeenList model quote =
  case quote of
    Just quote' ->
      model.collectionSeen
      |> List.filter (\id -> List.member id model.collectionIds)
      |> List.append [quote'.id]

    Nothing ->
      []



-- Json


decode : Json.Decoder (List QuoteTuple)
decode =
  Json.oneOf
  [ ("data" := decodeArray)
  , decodeArray
  ]


decodeArray : Json.Decoder (List QuoteTuple)
decodeArray =
  Json.list (
    object2 (,)
      ("quote" := Json.string)
      ("author" := Json.string)
  )
