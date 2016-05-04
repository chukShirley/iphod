module Calendar where

import Debug

import StartApp
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Regex
import Json.Decode as Json exposing ((:=))
import Effects exposing (Effects, Never)
import Task exposing (Task, andThen)
import String exposing (join)
import Markdown
import Graphics.Element as Graphics

import Iphod.Helper exposing (onClickLimited, hideable, getText)
import Iphod.Sunday as Sunday
import Iphod.MorningPrayer as MorningPrayer
import Iphod.EveningPrayer as EveningPrayer
import Iphod.Daily as Daily
import Iphod.Email as Email
import Iphod.Email exposing(sendContactMe)
import Iphod.Config as Config
import Iphod.Models as Models

app =
  StartApp.start
    { init = init
    , update = update
    , view = view
    , inputs =  [ incomingMonth ]
    }

-- MAIN

main: Signal Html
main = 
  app.html

port tasks: Signal (Task Never ())
port tasks =
  app.tasks


-- MODEL

type alias Week = { days: List Models.Day }
initWeek: Week
initWeek = { days = [] }

type alias Model = { calendar: List Week } -- Month

initModel: Model
initModel = {calendar = []}

init: (Model, Effects Action)
init = ( initModel, Effects.none )


-- SIGNALS

incomingMonth: Signal Action
incomingMonth =
  Signal.map AddMonth thisMonth


-- PORTS

port thisMonth: Signal Model


-- UPDATE

type Action
  = NoOp
  | AddMonth Model

update: Action -> Model -> (Model, Effects Action)
update action model =
  case action of
    NoOp -> (model, Effects.none)

    AddMonth newMonth -> (newMonth, Effects.none)


-- VIEW

view: Signal.Address Action -> Model -> Html
view address model =
  div []
    [ table [id "calendar"]
        ( (calendarNavHeader address model)
        ++ (calendarDayHeader)
        ++ (calendarWeeks address model)
        )
    ]

calendarNavHeader: Signal.Address Action -> Model -> List Html
calendarNavHeader address model =
  [ tr [id "calendar"]
      [ th [] [ text "<" ]
      , dateNav address model
      , th [] [ text ">"]
      ]
  ]

dateNav: Signal.Address Action -> Model -> Html
dateNav address model =
  th [ colspan 5]
    [ text "MONTH PICKER GOES HERE" ]

calendarDayHeader: List Html
calendarDayHeader =
  [ tr []
      [ th [] [ text "Sun" ]
      , th [] [ text "Mon" ]
      , th [] [ text "Tue" ]
      , th [] [ text "Wed" ]
      , th [] [ text "Thu" ]
      , th [] [ text "Fri" ]
      , th [] [ text "Sat" ]
      ]
  ]

calendarWeeks: Signal.Address Action -> Model -> List Html
calendarWeeks address model =
  List.map (oneWeek address) model.calendar

oneWeek: Signal.Address Action -> Week -> Html
oneWeek address week =
  let
    this_day address d =
      td [] 
        [ p [class "day_of_month"] [text d.dayOfMonth] 
        , ul [] 
            [ li [class "reading_group"] 
                (readingsMP d.daily)
            , li [class "reading_group"] 
                (readingsEP d.daily)
            , li [class "reading_group"] 
                (readingsEU d.sunday)
            ]
--          [ li [class "reading_group"] (reading d.daily.mp1)
--          , li [class "reading_group"] (reading d.daily.mp2)
--          , li [class "reading_group"] (reading d.daily.mpp)
--          , li [class "reading_group"] (reading d.daily.ep1)
--          , li [class "reading_group"] (reading d.daily.ep2)
--          , li [class "reading_group"] (reading d.daily.epp)
--          ]
        ]
  in
    tr []
      (List.map (this_day address) week.days)

readingsMP: Models.Daily -> List Html
readingsMP daily =
  let
    (thisId, thisRef, thisClose) = httpReferences "mp" daily.date
  in
    [ a [ href thisRef ] [ text "MP" ]
    , div 
        [ id thisId, class "modalDialog" ]
        [ div []
            [ a [href thisClose, title "Close", class "close"] [text "X"] 
            , h2 [class "modal_header"] 
                [ text "Morning Prayer"
                , br [] []
                , text daily.date
                ]
            , reading daily.mp1
            , reading daily.mp2
            , reading daily.mpp
            ]
        ]
    ]

readingsEP: Models.Daily -> List Html
readingsEP daily =
  let
    (thisId, thisRef, thisClose) = httpReferences "ep" daily.date
  in
    [ a [ href thisRef ] [ text "EP" ]
    , div 
        [ id thisId, class "modalDialog" ]
        [ div []
            [ a [href thisClose, title "Close", class "close"] [text "X"] 
            , h2 [class "modal_header"] 
                [ text "Evening Prayer"
                , br [] []
                , text daily.date
                ]
            , reading daily.ep1
            , reading daily.ep2
            , reading daily.epp
            ]
        ]
    ]

readingsEU: Models.Sunday -> List Html
readingsEU sunday =
  let
    (thisId, thisRef, thisClose) = httpReferences "eu" sunday.date
  in
    [ a [ href thisRef ] [ text "Eucharistic" ]
    , div 
        [ id thisId, class "modalDialog" ]
        [ div []
            [ a [href thisClose, title "Close", class "close"] [text "X"] 
            , h2 [class "modal_header"] 
                [ text "Eucharistic Readings"
                , br [] []
                , text sunday.date
                ]
            , reading sunday.ot
            , reading sunday.ps
            , reading sunday.nt
            , reading sunday.gs
            ]
        ]
    ]

httpReferences: String -> String -> (String, String, String)
httpReferences ante date =
  let
    id = ante ++ Regex.replace Regex.All (Regex.regex "[^A-Za-z0-9]") (\_ -> "") date
    ref = "#" ++ id
    close = "#close" ++ id
  in
    (id, ref, close)

reading: List Models.Lesson -> Html
reading lessons =
  let
    this_reading l =
      li [class "reading_item"] [ text l.read ]
  in
    ul [class "reading_list"] (List.map this_reading lessons)


