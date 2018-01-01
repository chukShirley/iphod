port module MPanel exposing (..) -- where
-- import Debug

import Html exposing (..)
import Html
import Html.Attributes exposing (..)
import Html.Events exposing (..)

import Iphod.Models as Models
import Iphod.Helper exposing (hideable)

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

type alias Model = Models.Daily
initModel : Models.Daily
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
    [ li [class "passage-section"] [ passageList model "OT" "eu" "ot" model.ot ]
    , li [class "passage-section"] [ passageList model "PS" "eu" "ps" model.ps ]
    , li [class "passage-section"] [ passageList model "NT" "eu" "nt" model.nt ]
    , li [class "passage-section"] [ passageList model "GS" "eu" "gs" model.gs ]
    ]
  ]

mpReadings: Model -> Html Msg
mpReadings model =
  div []
  [ p [ class "panel-paragraph service-name" ] [ button [onClick (GetAllLessons ["MP", model.date] )] [text "Morning Prayer"] ]
  , ul [ class "service-readings" ]
    [ li [class "passage-section"] [ passageList model "First"  "mp" "mp1" model.mp1 ]
    , li [class "passage-section"] [ passageList model "Second" "mp" "mp2" model.mp2 ]
    , li [class "passage-section"] [ passageList model "Psalms" "mp" "mpp" model.mpp ]
    ]
  ]

epReadings: Model -> Html Msg
epReadings model =
  div []
  [ p [ class "panel-paragraph service-name" ] [ button [onClick (GetAllLessons ["EP", model.date] )] [text "Evening Prayer"] ]
  , ul [ class "service-readings" ]
    [ li [class "passage-section"] [ passageList model "First"  "ep" "ep1" model.ep1 ]
    , li [class "passage-section"] [ passageList model "Second" "ep" "ep2" model.ep2 ]
    , li [class "passage-section"] [ passageList model "Psalms" "ep" "epp" model.epp ]
    ]
  ]


passageList: Model -> String -> String -> String -> List String -> Html Msg
passageList model title service section vss =
  let
    liVss vs = li [class "reading-li"] [ button [onClick (GetLesson [section, vs])] [text vs] ]
  in
    div []
    [ p [ class "section-title" ] [ text title ]
    , ul [class "reading-ul"] (List.map liVss vss)
    ]

panelStyle: Model -> Attribute msg
panelStyle model =
  hideable
    model.show
    []
