port module MPanel exposing (..) -- where
import Debug

import Html exposing (..)
import Html.App as App
import Html.Attributes exposing (..)
import Html.Events exposing (..)

import Iphod.Models as Models
import Iphod.Helper exposing (hideable)

-- MAIN

main =
  App.program
    { init = init
    , update = update
    , view = view
    , subscriptions = subscriptions
    }


-- MODEL

type alias Model = Models.Daily
initModel = Models.initDaily

init: (Model, Cmd Msg)
init = (initModel, Cmd.none)


-- REQUEST PORTS

port requestReading: List String -> Cmd msg

port requestService: List String -> Cmd msg

port requestReflection: String -> Cmd msg

port portReadings: (Models.Daily -> msg) -> Sub msg

subscriptions: Model -> Sub Msg
subscriptions model =
  Sub.batch
    [ portReadings UpdateMenu
    ]

-- UPDATE

type Msg
  = NoOp
  | UpdateMenu Model
  | GetLesson (List String)
  | GetAllLessons (List String)
  | GetReflection String

update: Msg -> Model -> (Model, Cmd Msg)
update msg model =
  case msg of
    NoOp -> (model, Cmd.none)

    UpdateMenu newModel -> (newModel, Cmd.none)

    GetLesson list -> (model, requestReading list)

    GetAllLessons list -> (model, requestService list)

    GetReflection date -> (model, requestReflection date)


-- VIEW

view: Model -> Html Msg
view model =
  div [ id "reading-panel", class "ui-widget-content ui-corner-all", panelStyle model ]
  [ p [ class "panel-header" ] [ text model.date ]
  , p [ class "panel-header" ] [ text model.title ]
  , ul [ id "reading-menu"]
      [ li [] [ reflection model]
      , li [] [ euchReadings model ]
      , li [] [ mpReadings model ]
      , li [] [ epReadings model ]
      ]
  ]

reflection: Model -> Html Msg
reflection model =
  div [] [ button [onClick (GetReflection model.date)] [ text "Reflection"] ]

euchReadings: Model -> Html Msg
euchReadings model =
  div []
  [ p [ class "panel-paragraph service-name" ] [ button [onClick (GetAllLessons ["EU", model.date] )] [text "Eucharist"] ]
  , ul [ class "service-readings" ]
    [ li [class "passage-section"] [ passageList "OT" "eu" "ot" model.ot ]
    , li [class "passage-section"] [ passageList "PS" "eu" "ps" model.ps ]
    , li [class "passage-section"] [ passageList "NT" "eu" "nt" model.nt ]
    , li [class "passage-section"] [ passageList "GS" "eu" "gs" model.gs ]
    ]
  ]

mpReadings: Model -> Html Msg
mpReadings model =
  div []
  [ p [ class "panel-paragraph service-name" ] [ button [onClick (GetAllLessons ["MP", model.date] )] [text "Morning Prayer"] ]
  , ul [ class "service-readings" ]
    [ li [class "passage-section"] [ passageList "First"  "mp" "ot" model.mp1 ]
    , li [class "passage-section"] [ passageList "Second" "mp" "nt" model.mp2 ]
    , li [class "passage-section"] [ passageList "Psalms" "mp" "ps" model.mpp ]
    ]
  ]

epReadings: Model -> Html Msg
epReadings model =
  div []
  [ p [ class "panel-paragraph service-name" ] [ button [onClick (GetAllLessons ["EP", model.date] )] [text "Evening Prayer"] ]
  , ul [ class "service-readings" ]
    [ li [class "passage-section"] [ passageList "First"  "ep" "ot" model.ep1 ]
    , li [class "passage-section"] [ passageList "Second" "ep" "nt" model.ep2 ]
    , li [class "passage-section"] [ passageList "Psalms" "ep" "ps" model.epp ]
    ]
  ]


passageList: String -> String -> String -> List String -> Html Msg
passageList title service section vss =
  let 
    liVss vs = li [class "reading-li"] [ button [onClick (GetLesson [vs, section, service])] [text vs] ]
  in
    div []
    [ p [ class "section-title" ] [ text title ]
    , ul [] (List.map liVss vss)
    ]

panelStyle: Model -> Attribute msg
panelStyle model =
  hideable
    model.show
    []