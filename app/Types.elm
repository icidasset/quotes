module Types exposing (..)

import Material


type alias Mdl = Material.Model
type alias Quote = { quote : String, author : String, id: String }
type alias QuoteTuple = (String, String)
