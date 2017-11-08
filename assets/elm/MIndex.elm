port module MIndex exposing (..)

-- where

import Debug
import Html exposing (..)
import Html
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Regex
import Platform.Sub as Sub exposing (batch, none)
import Platform.Cmd as Cmd exposing (Cmd)
import String exposing (join)
import Markdown
import Iphod.Helper exposing (hideable)
import Iphod.Models as Models
import Iphod.Sunday as Sunday
import Iphod.MPReading as MPReading
import Iphod.EPReading as EPReading


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



-- SUBSCRIPTIONS


port portEU : (Models.Sunday -> msg) -> Sub msg


port portMP : (Models.DailyMP -> msg) -> Sub msg


port portEP : (Models.DailyEP -> msg) -> Sub msg


port portLesson : (List Models.Lesson -> msg) -> Sub msg


port portReflection : (Models.Reflection -> msg) -> Sub msg


port portReadings : (Models.Daily -> msg) -> Sub msg


subscriptions : Model -> Sub Msg
subscriptions model =
    --  Sub.none
    Sub.batch
        --  [ portCalendar InitCalendar
        [ portEU UpdateEU
        , portMP UpdateMP
        , portEP UpdateEP
        , portLesson UpdateLesson
        , portReflection UpdateReflection
        ]



-- UODATE


type Msg
    = NoOp
    | UpdateEU Models.Sunday
    | UpdateMP Models.DailyMP
    | UpdateEP Models.DailyEP
    | UpdateReflection Models.Reflection
    | UpdateLesson (List Models.Lesson)
    | ModEU Sunday.Msg
    | ModMP MPReading.Msg
    | ModEP EPReading.Msg


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        NoOp ->
            ( model, Cmd.none )

        UpdateEU eu ->
            let
                tModel =
                    initModel

                newEU =
                    { eu | show = True }

                newModel =
                    { tModel | eu = newEU }
            in
                ( newModel, Cmd.none )

        UpdateMP mp ->
            let
                tModel =
                    initModel

                newMP =
                    { mp | show = True }

                newModel =
                    { tModel | mp = newMP }
            in
                ( newModel, Cmd.none )

        UpdateEP ep ->
            let
                tModel =
                    initModel

                newEP =
                    { ep | show = True }

                newModel =
                    { tModel | ep = newEP }
            in
                ( newModel, Cmd.none )

        UpdateReflection reflection ->
            let
                newModel =
                    { model | reflection = reflection }
            in
                ( newModel, Cmd.none )

        UpdateLesson lesson ->
            let
                section =
                    (List.head lesson |> Maybe.withDefault Models.initLesson).section

                _ = Debug.log "UPDATE LESSON" lesson
                newModel =
                    setLesson initModel section lesson
            in
                ( newModel, Cmd.none )

        ModEU msg ->
            let
                newModel =
                    { model | eu = Sunday.update msg model.eu }

                newCmd =
                    if newModel.eu.sectionUpdate.ref |> String.isEmpty then
                        Cmd.none
                    else
                        requestReading newModel.eu.sectionUpdate
            in
                ( newModel, newCmd )

        ModMP msg ->
            let
                newModel =
                    { model | mp = MPReading.update msg model.mp }
                newCmd =
                    if newModel.mp.sectionUpdate.ref |> String.isEmpty then
                        Cmd.none
                    else
                        requestReading newModel.mp.sectionUpdate
            in
                ( newModel, newCmd )

        ModEP msg ->
            let
                newModel =
                    { model | ep = EPReading.update msg model.ep }

                newCmd =
                    if newModel.ep.sectionUpdate.ref |> String.isEmpty then
                        Cmd.none
                    else
                        requestReading newModel.ep.sectionUpdate
            in
                ( newModel, newCmd )



-- HELPERS


setLesson : Model -> String -> List Models.Lesson -> Model
setLesson model section lesson =
    let
        newModel =
            case section of
                "mp1" ->
                    let
                        thisMP =
                            model.mp

                        newMP =
                            { thisMP | mp1 = lesson }

                        newModel =
                            { model | mp = newMP }
                    in
                        newModel

                "mp2" ->
                    let
                        thisMP =
                            model.mp

                        newMP =
                            { thisMP | mp2 = lesson }

                        newModel =
                            { model | mp = newMP }
                    in
                        newModel

                "mpp" ->
                    let
                        thisMP =
                            model.mp

                        newMP =
                            { thisMP | mpp = lesson }

                        newModel =
                            { model | mp = newMP }
                    in
                        newModel

                "ep1" ->
                    let
                        thisEP =
                            model.ep

                        newEP =
                            { thisEP | ep1 = lesson }

                        newModel =
                            { model | ep = newEP }
                    in
                        newModel

                "ep2" ->
                    let
                        thisEP =
                            model.ep

                        newEP =
                            { thisEP | ep2 = lesson }

                        newModel =
                            { model | ep = newEP }
                    in
                        newModel

                "epp" ->
                    let
                        thisEP =
                            model.ep

                        newEP =
                            { thisEP | epp = lesson }

                        newModel =
                            { model | ep = newEP }
                    in
                        newModel

                "ot" ->
                    let
                        thisEU =
                            model.eu

                        newEU =
                            { thisEU | ot = lesson }

                        newModel =
                            { model | eu = newEU }
                    in
                        newModel

                "ps" ->
                    let
                        thisEU =
                            model.eu

                        newEU =
                            { thisEU | ps = lesson }

                        newModel =
                            { model | eu = newEU }
                    in
                        newModel

                "nt" ->
                    let
                        thisEU =
                            model.eu

                        newEU =
                            { thisEU | nt = lesson }

                        newModel =
                            { model | eu = newEU }
                    in
                        newModel

                "gs" ->
                    let
                        thisEU =
                            model.eu

                        newEU =
                            { thisEU | gs = lesson }

                        newModel =
                            { model | eu = newEU }
                    in
                        newModel

                _ ->
                    model
    in
        newModel



-- VIEW


view : Model -> Html Msg
view model =
    div []
        [ euDiv model
        , mpDiv model
        , epDiv model
        , reflectionDiv model
        , oneLessonDiv model
        ]



-- HELPERS


euDiv : Model -> Html Msg
euDiv model =
    div [] [ Html.map ModEU (Sunday.view model.eu) ]


mpDiv : Model -> Html Msg
mpDiv model =
    div []
        [ Html.map ModMP (MPReading.view model.mp)
        ]


epDiv : Model -> Html Msg
epDiv model =
    div []
        [ Html.map ModEP (EPReading.view model.ep)
        ]


reflectionDiv : Model -> Html Msg
reflectionDiv model =
    let
        author =
            if String.length model.reflection.author > 0 then
                "--- " ++ model.reflection.author
            else
                ""
    in
        div []
            [ div [ id "reflection" ] [ Markdown.toHtml [] model.reflection.markdown ]
            , p [ class "author" ] [ text author ]
            ]


oneLessonDiv : Model -> Html Msg
oneLessonDiv model =
    let
        putLesson l =
            p [] [ Markdown.toHtml [] l.body ]
    in
        div [] (List.map putLesson model.oneLesson)


euReadingStyle : Model -> Attribute msg
euReadingStyle model =
    hideable
        model.eu.show
        []


mpReadingStyle : Model -> Attribute msg
mpReadingStyle model =
    hideable
        model.mp.show
        []


epReadingStyle : Model -> Attribute msg
epReadingStyle model =
    hideable
        model.ep.show
        []
