port module Iphod exposing (..)

-- where

import Debug


-- import StartApp

import Html exposing (..)
import Html
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Regex
import Platform.Sub as Sub exposing (batch)
import Platform.Cmd as Cmd exposing (Cmd)
import String exposing (join)
import Markdown
import Iphod.Helper exposing (hideable)
import Iphod.Models as Models
-- import Iphod.Sunday as Sunday
-- import Iphod.MPReading as MPReading
-- import Iphod.EPReading as EPReading


-- MAIN


main =
    Html.program
        { init = init
        , update = update
        , view = view
        , subscriptions = subscriptions
        }



-- MODEL


type alias Model =
    { month : Models.Month
    , lesson1 : String
    , lesson2 : String
    , lesson3 : String
    , psalm : String
    , reflection : Models.Reflection
    }


initModel : Model
initModel =
    { month = Models.initMonth
    , reflection = Models.initReflection
    , lesson1 = ""
    , lesson2 = ""
    , lesson3 = ""
    , psalm = ""
    }

init : ( Model, Cmd Msg )
init =
    ( initModel, Cmd.none )



-- REQUEST PORTS


port requestReading : Models.SectionUpdate -> Cmd msg


port requestAltReading : List String -> Cmd msg


port requestScrollTop : String -> Cmd msg



-- SUBSCRIPTIONS


port portMonth : (Models.Month -> msg) -> Sub msg

port portLesson : (List Models.Lesson -> msg) -> Sub msg

port portReflection : (Models.Reflection -> msg) -> Sub msg


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch
        [ portMonth InitMonth
        , portLesson UpdateLesson
        , portReflection UpdateReflection
        ]



-- UPDATE


type ShowHide
    = Show
    | Hide


type Msg
    = NoOp
    | InitMonth  Models.Month
    | UpdateReflection Models.Reflection
    | UpdateLesson (List Models.Lesson)


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        NoOp ->
            ( model, Cmd.none )

        InitMonth month ->
          let
            _ = Debug.log "MONTH" month
            newModel = {model | month = month}
          in
            ( newModel, Cmd.none )

        UpdateReflection reflection ->
            let
                newModel = { model | reflection = reflection }
            in
                ( newModel, Cmd.none )

        UpdateLesson lesson -> (model, Cmd.none)
--            let
--                section =
--                    (List.head lesson |> Maybe.withDefault Models.initLesson).section
--
--                newModel =
--                    setLesson model section lesson
--            in
--                ( newModel, Cmd.none )


-- HELPERS


-- setLesson : Model -> String -> List Models.Lesson -> Model
-- setLesson model section lesson =
--     let
--         newModel =
--             case section of
--                 "mp1" ->
--                     let
--                         thisMP =
--                             model.mp
-- 
--                         newMP =
--                             { thisMP | mp1 = lesson }
-- 
--                         newModel =
--                             { model | mp = newMP }
--                     in
--                         newModel
-- 
--                 "mp2" ->
--                     let
--                         thisMP =
--                             model.mp
-- 
--                         newMP =
--                             { thisMP | mp2 = lesson }
-- 
--                         newModel =
--                             { model | mp = newMP }
--                     in
--                         newModel
-- 
--                 "mpp" ->
--                     let
--                         thisMP =
--                             model.mp
-- 
--                         newMP =
--                             { thisMP | mpp = lesson }
-- 
--                         newModel =
--                             { model | mp = newMP }
--                     in
--                         newModel
-- 
--                 "ep1" ->
--                     let
--                         thisEP =
--                             model.ep
-- 
--                         newEP =
--                             { thisEP | ep1 = lesson }
-- 
--                         newModel =
--                             { model | ep = newEP }
--                     in
--                         newModel
-- 
--                 "ep2" ->
--                     let
--                         thisEP =
--                             model.ep
-- 
--                         newEP =
--                             { thisEP | ep2 = lesson }
-- 
--                         newModel =
--                             { model | ep = newEP }
--                     in
--                         newModel
-- 
--                 "epp" ->
--                     let
--                         thisEP =
--                             model.ep
-- 
--                         newEP =
--                             { thisEP | epp = lesson }
-- 
--                         newModel =
--                             { model | ep = newEP }
--                     in
--                         newModel
-- 
--                 "ot" ->
--                     let
--                         thisEU =
--                             model.eu
-- 
--                         newEU =
--                             { thisEU | ot = lesson }
-- 
--                         newModel =
--                             { model | eu = newEU }
--                     in
--                         newModel
-- 
--                 "ps" ->
--                     let
--                         thisEU =
--                             model.eu
-- 
--                         newEU =
--                             { thisEU | ps = lesson }
-- 
--                         newModel =
--                             { model | eu = newEU }
--                     in
--                         newModel
-- 
--                 "nt" ->
--                     let
--                         thisEU =
--                             model.eu
-- 
--                         newEU =
--                             { thisEU | nt = lesson }
-- 
--                         newModel =
--                             { model | eu = newEU }
--                     in
--                         newModel
-- 
--                 "gs" ->
--                     let
--                         thisEU =
--                             model.eu
-- 
--                         newEU =
--                             { thisEU | gs = lesson }
-- 
--                         newModel =
--                             { model | eu = newEU }
--                     in
--                         newModel
-- 
--                 _ ->
--                     model
--     in
--         newModel



-- VIEW


view : Model -> Html Msg
view model =
  div [ id "calendar-div" ]
    [ lesson1Div model.lesson1
    , psalmDiv model.psalm
    , lesson2Div model.lesson2
    , lesson3Div model.lesson3
    , reflectionDiv model.reflection
  ] 
--    div [ id "reading-container" ]
--        [ euDiv model
--        , mpDiv model
--        , epDiv model
--        , reflectionDiv model
--        ]


lesson1Div : String -> Html Msg
lesson1Div vss =
    div [ id "lesson1" ] [ Markdown.toHtml [] vss ]


lesson2Div : String -> Html Msg
lesson2Div vss =
    div [ id "lesson2" ] [ Markdown.toHtml [] vss ]


lesson3Div : String -> Html Msg
lesson3Div vss =
    div [ id "lesson3" ] [ Markdown.toHtml [] vss ]

psalmDiv : String -> Html Msg
psalmDiv vss =
    div [ id "psalm" ] [ Markdown.toHtml [] vss ]

reflectionDiv : Models.Reflection -> Html Msg
reflectionDiv model =
    let
        author =
            if String.length model.author > 0 then
                "--- " ++ model.author
            else
                ""
    in
        div []
            [ div [ id "reflection" ] [ Markdown.toHtml [] model.markdown ]
            , p [ class "author" ] [ text author ]
            ]
