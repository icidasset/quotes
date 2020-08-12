module View.Navigation exposing (iconButton, view)

import Confirm
import Html exposing (Html)
import Html.Attributes as A
import Html.Events as E
import Material.Icons.Round as Icons
import Material.Icons.Types exposing (Coloring(..))
import Page exposing (AddContext, Page(..))
import Quote exposing (..)
import Radix exposing (..)
import Tailwind as T



-- 🖼


view : Model -> Html Msg
view model =
    Html.div
        [ T.bottom_0
        , T.left_1over2
        , T.fixed
        , T.flex
        , T.items_center
        , T.mb_6
        , T.neg_translate_x_1over2
        , T.select_none
        , T.text_base04
        , T.transform

        --
        , T.md__mb_12

        -- Dark mode
        ------------
        , T.dark__text_base03
        ]
        (case model.page of
            Add _ ->
                -----------------------------------------
                -- Show
                -----------------------------------------
                [ iconButton
                    [ A.title "Show a quote"
                    , A.href (Page.path { from = model.page, to = Page.Index })
                    ]
                    [ Icons.format_quote 26 Inherit
                    ]

                -----------------------------------------
                -- 🦉
                -----------------------------------------
                -- TODO:
                -- , more
                ]

            Index ->
                -----------------------------------------
                -- Add
                -----------------------------------------
                [ iconButton
                    [ A.title "Add a quote"
                    , A.href (Page.path { from = model.page, to = Page.add })
                    ]
                    [ Icons.add_circle 24 Inherit
                    ]

                -----------------------------------------
                -- Remove
                -----------------------------------------
                , case model.selectedQuote of
                    ( Just quote, _ ) ->
                        let
                            askForConfirmation =
                                model.confirmation == Just Confirm.QuoteRemoval
                        in
                        iconButton
                            [ A.title "Remove this quote"
                            , E.onClick (RemoveQuote quote)

                            --
                            , if askForConfirmation then
                                T.text_red

                              else
                                T.text_inherit
                            ]
                            [ if askForConfirmation then
                                Icons.remove_circle 24 Inherit

                              else
                                Icons.remove_circle_outline 24 Inherit
                            ]

                    ( Nothing, _ ) ->
                        Html.text ""

                -----------------------------------------
                -- Next
                -----------------------------------------
                , case model.quotes of
                    [] ->
                        Html.text ""

                    [ _ ] ->
                        Html.text ""

                    _ ->
                        iconButton
                            [ A.title "Show another quote"
                            , E.onClick SelectNextQuote
                            ]
                            [ Icons.arrow_forward 24 Inherit
                            ]

                -----------------------------------------
                -- 🦉
                -----------------------------------------
                -- TODO:
                -- , more
                ]
        )



-- ⚗️


iconButton : List (Html.Attribute Msg) -> List (Html Msg) -> Html Msg
iconButton attributes =
    Html.a
        (List.append
            [ T.appearance_none
            , T.ml_6
            , T.rounded

            --
            , T.first__ml_0
            ]
            attributes
        )



-- ㊙️


more =
    iconButton
        [ A.title "Additional actions"
        ]
        [ Icons.more_vert 24 Inherit
        ]
