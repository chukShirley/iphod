port module Stations exposing (..)

-- where

import Html exposing (..)
import Html
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import String exposing (toInt)


-- import Regex exposing (..)

import Platform.Sub as Sub exposing (batch)
import Platform.Cmd as Cmd exposing (Cmd)
import Markdown
-- import Debug


-- MAIN

main : Program Never Model Msg
main =
    Html.program
        { init = init
        , update = update
        , view = view
        , subscriptions = subscriptions
        }



-- MODEL


type alias Model =
    { id : String
    , beforeMinister : String
    , beforeAll : String
    , afterAll : String
    , title : String
    , reading : String
    , images : String -- image urls, I think. eventually multiple images
    , aboutImage : String
    , reflections : String
    , prayer : String
    }


initModel : Model
initModel =
    { id = ""
    , beforeMinister = ""
    , beforeAll = ""
    , afterAll = ""
    , title = ""
    , reading = ""
    , images = ""
    , aboutImage = ""
    , reflections = ""
    , prayer = ""
    }


init : ( Model, Cmd Msg )
init =
    ( initModel, requestStation "1" )



-- REQUEST PORTS


port requestStation : String -> Cmd msg



-- SUBSCRIPTIONS


port portStation : (Model -> msg) -> Sub msg


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch
        [ portStation UpdateStation
        ]



-- UPDATE


type Msg
    = NoOp
    | UpdateStation Model
    | Next
    | Prev
    | Station String


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        NoOp ->
            ( model, Cmd.none )

        UpdateStation newModel ->
            ( newModel, Cmd.none )

        Next ->
            let
                x =
                    Result.withDefault 0 (String.toInt model.id) + 1

                next =
                    if x > 14 then
                        1
                    else
                        x

                newCmd =
                    requestStation (toString next)
            in
                ( model, newCmd )

        Prev ->
            let
                x =
                    Result.withDefault 0 (String.toInt model.id) - 1

                next =
                    if x < 1 then
                        14
                    else
                        x

                newCmd =
                    requestStation (toString next)
            in
                ( model, newCmd )

        Station n ->
            ( model, requestStation n )


view : Model -> Html Msg
view model =
    div [ id "stations-container" ]
        [ aboutStations
        , navigationButtons model
        , p [ id "art" ]
            [ div [ class "art-figure" ]
                [ img [ class "art-image", src ("images/" ++ model.images), alt model.aboutImage ] []
                , br [] []
                , text model.aboutImage
                ]
            , Markdown.toHtml [] model.reading
            ]
        , reflections model
        , prayer model
        ]


navigationButtons : Model -> Html Msg
navigationButtons model =
    let
        thisStation n =
            if n == model.id then
                style [ ( "background-color", "lightgrey" ), ( "color", "darkblue" ) ]
            else
                style []
    in
        p []
            [ button [ class "stn-button", onClick Next ] [ text "Next" ]
            , button [ id "stn-button1", class "stn-button", onClick (Station "1"), thisStation "1" ] [ text "1" ]
            , button [ id "stn-button2", class "stn-button", onClick (Station "2"), thisStation "2" ] [ text "2" ]
            , button [ id "stn-button3", class "stn-button", onClick (Station "3"), thisStation "3" ] [ text "3" ]
            , button [ id "stn-button4", class "stn-button", onClick (Station "4"), thisStation "4" ] [ text "4" ]
            , button [ id "stn-button5", class "stn-button", onClick (Station "5"), thisStation "5" ] [ text "5" ]
            , button [ id "stn-button6", class "stn-button", onClick (Station "6"), thisStation "6" ] [ text "6" ]
            , button [ id "stn-button7", class "stn-button", onClick (Station "7"), thisStation "7" ] [ text "7" ]
            , button [ id "stn-button8", class "stn-button", onClick (Station "8"), thisStation "8" ] [ text "8" ]
            , button [ id "stn-button9", class "stn-button", onClick (Station "9"), thisStation "9" ] [ text "9" ]
            , button [ id "stn-button10", class "stn-button", onClick (Station "10"), thisStation "10" ] [ text "10" ]
            , button [ id "stn-button11", class "stn-button", onClick (Station "11"), thisStation "11" ] [ text "11" ]
            , button [ id "stn-button12", class "stn-button", onClick (Station "12"), thisStation "12" ] [ text "12" ]
            , button [ id "stn-button13", class "stn-button", onClick (Station "13"), thisStation "13" ] [ text "13" ]
            , button [ id "stn-button14", class "stn-button", onClick (Station "14"), thisStation "14" ] [ text "14" ]
            , button [ class "stn-button", onClick Prev ] [ text "Previous" ]
            ]


reflections : Model -> Html Msg
reflections model =
    p [ class "reflection" ]
        [ h3 [] [ text "Reflection" ]
        , Markdown.toHtml [] model.reflections
        ]


prayer : Model -> Html Msg
prayer model =
    p [ class "prayer" ]
        [ h3 [] [ text "Prayer" ]
        , Markdown.toHtml [] model.prayer
        ]


aboutStations : Html Msg
aboutStations =
    p []
        [ h3 [] [ text "About" ]
        , Markdown.toHtml [] "The Scriptural Way of the Cross or Scriptural Stations of the Cross is a version of the\n    traditional Stations of the Cross inaugurated as a Roman Catholic devotion by Pope\n    John Paul II on Good Friday 1991. Thereafter John Paul II performed the scriptural\n    version many times at the Colosseum in Rome on Good Fridays during his reign. The\n    scriptural version was not intended to invalidate the traditional version, rather it was\n    meant to add nuance to an understanding of the Passion. _Wikipedia_"
        , Markdown.toHtml [] "**Also:** If you have suggestions for art and/or content, \n    please do send me an email (Use 'Contact' in the 'About' option ) \n    or join the Iphod Facebook group (to make suggests, report bugs, read about updates to the site)"
        , br [] []
        ]
