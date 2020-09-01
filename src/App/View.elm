module View exposing (view)

import Browser
import Confirm
import Html exposing (Html)
import Html.Attributes as A
import Html.Events as E
import Material.Icons.Round as Icons
import Material.Icons.Types exposing (Coloring(..))
import Maybe.Extra as Maybe
import Page exposing (AddContext, Page(..))
import Quote exposing (..)
import Radix exposing (..)
import Tailwind as T
import View.Navigation as Navigation
import View.Svg as Svg



-- 🖼


view : Model -> Browser.Document Msg
view model =
    { title = "Quotes"
    , body = [ container model (body model) ]
    }


body : Model -> List (Html Msg)
body model =
    if model.isLoading then
        -- TODO: Use actual loading animation (see HTML file)
        [ Html.text "Loading ..." ]

    else if Maybe.isJust model.userData then
        -----------------------------------------
        -- Authenticated
        -----------------------------------------
        [ case model.page of
            Add a ->
                add model a

            Index ->
                index model

        -- Navigation
        -------------
        , Navigation.view model
        ]

    else
        -----------------------------------------
        -- Not authenticated
        -----------------------------------------
        [ Html.h1
            [ T.font_display
            , T.font_extrabold
            , T.text_6xl
            ]
            [ Html.text "“Quotes”" ]

        --
        , Html.p
            [ T.mt_6
            , T.mx_4
            , T.text_base03
            , T.text_center

            -- Dark mode
            ------------
            , T.dark__text_base04
            ]
            ("""
             A joyful way of keeping track of your favourite quotes.
             """
                |> String.trim
                |> String.split "\n"
                |> List.map String.trim
                |> List.map (\a -> Html.span [] [ Html.text a, Html.br [] [] ])
            )

        --
        , Html.div
            [ T.mt_10 ]
            [ Html.button
                (List.append
                    buttonAttributes
                    [ E.onClick SignIn
                    , T.inline_flex
                    , T.bg_red
                    , T.items_center
                    ]
                )
                [ Html.span
                    [ T.h_4
                    , T.mr_2
                    , T.opacity_60
                    , T.w_4
                    ]
                    [ Svg.badge ]
                , Html.text "Sign in with Fission"
                ]
            ]
        ]



-- ADD


add : Model -> AddContext -> Html Msg
add model context =
    Html.form
        [ E.onSubmit (AddQuote context)

        --
        , T.max_w_md
        , T.mx_auto
        , T.px_8
        , T.w_full
        ]
        [ -----------------------------------------
          -- Quote
          -----------------------------------------
          label "quote" "Quote"
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
                    [ A.name "quote"
                    , A.required True
                    , E.onInput GotAddInputForQuote

                    --
                    , T.h_40
                    , T.resize_none
                    ]
            )
            []

        -----------------------------------------
        -- Author
        -----------------------------------------
        , label "author" "Author"
        , Html.input
            ("Marcus Aurelius"
                |> textfieldAttributes
                |> List.append
                    [ A.name "author"
                    , A.required True
                    , E.onInput GotAddInputForAuthor
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

                    -- Dark mode
                    ------------
                    , T.dark__bg_orange
                    ]
                )
                [ Html.text "Add Quote" ]
            ]
        ]


label : String -> String -> Html Msg
label n l =
    Html.label
        [ A.for n

        --
        , T.block
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
    , T.border_2
    , T.border_transparent
    , T.font_display
    , T.italic
    , T.leading_relaxed
    , T.mb_8
    , T.outline_none
    , T.p_3
    , T.placeholder_base04
    , T.placeholder_opacity_100
    , T.rounded
    , T.text_base00
    , T.text_base
    , T.w_full

    --
    , T.focus__border_teal
    , T.focus__border_opacity_50

    -- Dark mode
    ------------
    , T.dark__bg_dark_side
    , T.dark__placeholder_base02
    , T.dark__text_base06

    --
    , T.dark__focus__border_orange
    ]



-- INDEX


index : Model -> Html Msg
index model =
    case
        Maybe.map2
            (\quote userData -> ( quote, userData ))
            (Tuple.first model.selectedQuote)
            model.userData
    of
        Just ( quote, userData ) ->
            Html.div
                []
                [ quoteView quote model

                -----------------------------------------
                -- History Counter
                -----------------------------------------
                , Html.div
                    [ A.title "Quotes seen from collection"
                    , E.onClick SelectNextQuote

                    --
                    , T.bottom_0
                    , T.cursor_pointer
                    , T.fixed
                    , T.left_0
                    , T.leading_relaxed
                    , T.mb_6
                    , T.ml_8
                    , T.text_base04
                    , T.text_sm

                    --
                    , T.md__mb_12
                    , T.md__ml_10

                    --
                    , T.dark__text_base03
                    ]
                    [ Html.text (String.fromInt <| List.length userData.selectionHistory)
                    , Html.text " of "
                    , Html.text (String.fromInt <| List.length userData.quotes)
                    ]
                ]

        Nothing ->
            Html.a
                [ A.href (Page.path { from = model.page, to = Page.add })
                , T.block
                , T.cursor_pointer
                ]
                [ note "Nothing here yet, want to add a quote?" ]


quoteView : Quote -> Model -> Html Msg
quoteView quote model =
    Html.div
        [ T.max_w_xl
        , T.mx_8
        , T.my_20
        ]
        [ -----------------------------------------
          -- Quote
          -----------------------------------------
          Html.div
            [ T.font_display
            , T.leading_snug
            , T.text_3xl
            , T.text_left

            --
            , T.md__text_4xl
            ]
            [ Html.text quote.quote ]

        -----------------------------------------
        -- Author
        -----------------------------------------
        , Html.div
            [ T.font_display
            , T.font_semibold
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
    , T.flex_col
    , T.items_center
    , T.justify_center
    , T.min_h_screen_alt
    , T.text_base00

    -- Dark mode
    ------------
    , T.dark__text_base06
    ]


note : String -> Html Msg
note theNote =
    Html.div
        [ T.font_display
        , T.italic
        , T.opacity_70
        , T.mx_4
        , T.text_center
        , T.text_lg

        -- Dark mode
        ------------
        , T.dark__opacity_100
        , T.dark__text_base03
        ]
        [ Html.text theNote ]
