module View exposing (view)

import Browser
import Confirm
import Html exposing (Html)
import Html.Attributes as A
import Html.Events as E
import Material.Icons.Round as Icons
import Material.Icons.Types exposing (Coloring(..))
import Quote exposing (..)
import Radix exposing (..)
import Screen exposing (AddContext, Screen(..))
import Tailwind as T



-- 🖼


view : Model -> Browser.Document Msg
view model =
    { title = "Quotes"
    , body = [ container model (body model) ]
    }


body : Model -> List (Html Msg)
body model =
    if model.authenticated then
        -----------------------------------------
        -- Authenticated
        -----------------------------------------
        [ case model.screen of
            Add a ->
                add model a

            Index ->
                index model

        -- Navigation
        -------------
        , navigation model
        ]

    else
        -----------------------------------------
        -- Not authenticated
        -----------------------------------------
        [ Html.button
            (List.append
                buttonAttributes
                [ E.onClick SignIn
                , T.bg_purple
                ]
            )
            [ Html.text "Sign in with Fission" ]
        ]



-- ADD


add : Model -> AddContext -> Html Msg
add model context =
    Html.form
        [ E.onSubmit (AddQuote context)

        --
        , T.max_w_md
        , T.mx_auto
        , T.px_4
        , T.w_full
        ]
        [ -----------------------------------------
          -- Author
          -----------------------------------------
          label "Author"
        , Html.input
            ("Marcus Aurelius"
                |> textfieldAttributes
                |> List.append
                    [ A.required True
                    , E.onInput GotAddInputForAuthor
                    ]
            )
            []

        -----------------------------------------
        -- Quote
        -----------------------------------------
        , label "Quote"
        , Html.textarea
            ("""
             Very little is needed to make a happy life;
             it is all within yourself, in your way of thinking.
             """
                |> String.trim
                |> String.split "\n"
                |> List.map String.trim
                |> String.join "\n"
                |> textfieldAttributes
                |> List.append
                    [ A.required True
                    , E.onInput GotAddInputForQuote

                    --
                    , T.h_40
                    , T.resize_none
                    ]
            )
            []

        -----------------------------------------
        -- ➕
        -----------------------------------------
        , Html.div
            [ T.text_center ]
            [ Html.button
                (List.append
                    buttonAttributes
                    [ A.type_ "submit"
                    , T.bg_teal
                    ]
                )
                [ Html.text "Add Quote" ]
            ]
        ]


label : String -> Html Msg
label l =
    Html.label
        [ T.block
        , T.font_medium
        , T.mb_2
        , T.text_base01
        , T.text_xxs
        , T.tracking_pushing_it
        , T.uppercase

        -- Dark mode
        ------------
        , T.dark__text_base04
        ]
        [ Html.text l ]


textfieldAttributes : String -> List (Html.Attribute Msg)
textfieldAttributes placeholder =
    [ A.placeholder placeholder

    --
    , T.appearance_none
    , T.bg_white
    , T.block
    , T.font_display
    , T.italic
    , T.leading_relaxed
    , T.mb_8
    , T.p_4
    , T.placeholder_base04
    , T.placeholder_opacity_100
    , T.rounded
    , T.text_base00
    , T.text_base
    , T.w_full

    -- Dark mode
    ------------
    , T.dark__bg_white_05
    , T.dark__placeholder_white
    , T.dark__placeholder_opacity_20
    , T.dark__text_base06
    ]



-- INDEX


index : Model -> Html Msg
index model =
    case model.selectedQuote of
        ( Just quote, _ ) ->
            quoteView quote

        ( Nothing, _ ) ->
            note "Nothing here yet, want to add a quote?"


quoteView : Quote -> Html Msg
quoteView quote =
    Html.div
        [ T.font_display
        , T.max_w_xl
        ]
        [ -----------------------------------------
          -- Quote
          -----------------------------------------
          Html.div
            [ T.leading_snug
            , T.text_4xl
            , T.text_justify
            ]
            [ Html.text quote.quote ]

        -----------------------------------------
        -- Author
        -----------------------------------------
        , Html.div
            [ T.font_semibold
            , T.mt_5
            , T.text_base04
            , T.text_sm

            -- Dark mode
            ------------
            , T.dark__text_base03
            ]
            [ Html.span [ T.inline_block, T.mr_2 ] [ Html.text "—" ]
            , Html.span [ T.inline_block ] [ Html.text quote.author ]
            ]
        ]



-- ㊙️


buttonAttributes : List (Html.Attribute Msg)
buttonAttributes =
    [ T.antialiased
    , T.appearance_none
    , T.inline_block
    , T.font_medium
    , T.px_5
    , T.py_3
    , T.rounded_full
    , T.text_sm
    , T.text_white
    ]


container : Model -> List (Html Msg) -> Html Msg
container model =
    (case model.confirmation of
        Just _ ->
            [ E.onClick RemoveConfirmation ]

        Nothing ->
            []
    )
        |> List.append containerStyles
        |> Html.div


containerStyles : List (Html.Attribute Msg)
containerStyles =
    [ T.flex
    , T.h_screen
    , T.items_center
    , T.justify_center
    , T.text_base00

    -- Dark mode
    ------------
    , T.dark__text_base06
    ]


navigation : Model -> Html Msg
navigation model =
    Html.div
        [ T.bottom_0
        , T.left_1over2
        , T.fixed
        , T.mb_12
        , T.neg_translate_x_1over2
        , T.text_base04
        , T.transform

        -- Dark mode
        ------------
        , T.dark__text_base03
        ]
        (case model.screen of
            Add _ ->
                -----------------------------------------
                -- Show
                -----------------------------------------
                [ Html.button
                    [ A.title "Show a quote"
                    , E.onClick (ShowScreen Screen.Index)
                    ]
                    [ Icons.format_quote 26 Inherit
                    ]
                ]

            Index ->
                -----------------------------------------
                -- Add
                -----------------------------------------
                [ Html.button
                    [ A.title "Add a quote"
                    , E.onClick (ShowScreen Screen.add)
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
                        Html.button
                            [ A.title "Remove this quote"
                            , E.onClick (RemoveQuote quote)
                            , T.ml_5

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
                ]
        )


note : String -> Html Msg
note theNote =
    Html.div
        [ T.font_display
        , T.italic
        , T.opacity_70
        , T.text_lg
        ]
        [ Html.text theNote ]
