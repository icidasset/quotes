module Model.Utils exposing (..)

import Maybe
import Model.Types exposing (Model, UserDataModel)



-- User-data helpers


toUserData : Model -> UserDataModel
toUserData model =
  { collectionSeen = model.collectionSeen
  , collectionUrl = model.collectionUrl
  }


fromUserData : Maybe UserDataModel -> UserDataModel -> Model -> Model
fromUserData maybeUserData emptyUserData model =
  let
    userData = Maybe.withDefault emptyUserData maybeUserData
  in
    { model |

      collectionSeen = userData.collectionSeen
    , collectionUrl = userData.collectionUrl
    }
