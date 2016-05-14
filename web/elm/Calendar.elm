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
import Iphod.Email as Email
import Iphod.Email exposing(sendContactMe)
import Iphod.Config as Config
import Iphod.Models as Models

app =
  StartApp.start
    { init = init
    , update = update
    , view = view
    , inputs =  [ initialState ]
    }

-- MAIN

main: Signal Html
main = 
  app.html

port tasks: Signal (Task Never ())
port tasks =
  app.tasks


-- MODEL

type alias Model =
  { eu: Models.DailyEU
  , mp: Models.DailyMP
  , ep: Models.DailyEP
  }

init: Model
  { eu = Models.initDailyEU
  , mp = Models.initDailyMP
  , ep = Models.initDailyEP
  }


-- SIGNALS

incomingEU: Signal Action
incomingEU =
  Signal.map UpdateEU newEU

incomingMP: Signal Action
incomingMP =
  Signal.map UpdateMP newMP

incomingEP: Signal Action
incomingEP =
  Signal.map UpdateEP newEP

-- PORTS

port newEU: Signal Models.DailyEU
port newMP: Signal Models.DailyMP
port newEP: Signal Models.DailyEP

-- UPDATE

type Action
  = NoOp
  | UpdateEU Models.DailyEU
  | UpdateMP Models.DailyMP
  | UpdateEP Models.DailyEP

update: Action -> Model -> (Model, Effects Action)
update action model =
  case action of
    NoOp -> (model, Effects.none)

    UpdateEU eu -> 
      let
        foo = Debug.log "EU" eu
      in
        (model, Effects.none)

    UpdateMP eu -> 
      let
        foo = Debug.log "MP" eu
      in
        (model, Effects.none)

    UpdateEP eu -> 
      let
        foo = Debug.log "EP" eu
      in
        (model, Effects.none)

-- HELPERS


-- VIEW

view: Signal.Address Action -> Model -> Html
view address model =
  div [] [text "Where the readings go"]

-- readingsMP: Models.Daily -> List Html
-- readingsMP daily =
--   let
--     (thisId, thisRef, thisClose) = httpReferences "mp" daily.date
--   in
--     [ a [ href thisRef ] 
--         [ button [] [text "MP"] ]
--     , div 
--         [ id thisId, class "modalDialog" ]
--         [ div []
--             [ a [href thisClose, title "Close", class "close"] [text "X"] 
--             , h2 [class "modal_header"] 
--                 [ text "Morning Prayer"
--                 , br [] []
--                 , text daily.date
--                 ]
--             , reading daily.mp1
--             , reading daily.mp2
--             , reading daily.mpp
--             ]
--         ]
--     ]
-- 
-- readingsEP: Models.Daily -> List Html
-- readingsEP daily =
--   let
--     (thisId, thisRef, thisClose) = httpReferences "ep" daily.date
--   in
--     [ a [ href thisRef ] 
--         [ button [] [text "EP"] ]
--     , div 
--         [ id thisId, class "modalDialog" ]
--         [ div []
--             [ a [href thisClose, title "Close", class "close"] [text "X"] 
--             , h2 [class "modal_header"] 
--                 [ text "Evening Prayer"
--                 , br [] []
--                 , text daily.date
--                 ]
--             , reading daily.ep1
--             , reading daily.ep2
--             , reading daily.epp
--             ]
--         ]
--     ]
-- 
-- readingsEU: Models.Sunday -> List Html
-- readingsEU sunday =
--   let
--     (thisId, thisRef, thisClose) = httpReferences "he" sunday.date
--   in
--     [ a [ href thisRef ] 
--         [ button [] [text "HE"] ]
--     , div 
--         [ id thisId, class "modalDialog" ]
--         [ div []
--             [ a [href thisClose, title "Close", class "close"] [text "X"] 
--             , h2 [class "modal_header"] 
--                 [ text "Eucharistic Readings"
--                 , br [] []
--                 , text sunday.date
--                 ]
--             , reading sunday.ot
--             , reading sunday.ps
--             , reading sunday.nt
--             , reading sunday.gs
--             ]
--         ]
--     ]
-- 
-- httpReferences: String -> String -> (String, String, String)
-- httpReferences ante date =
--   let
--     id = ante ++ Regex.replace Regex.All (Regex.regex "[^A-Za-z0-9]") (\_ -> "") date
--     ref = "#" ++ id
--     close = "#close" ++ id
--   in
--     (id, ref, close)
-- 
-- reading: List Models.Lesson -> Html
-- reading lessons =
--   let
--     this_reading l =
--       li [class "reading_item"] [ text l.read ]
--   in
--     ul [class "reading_list"] (List.map this_reading lessons)
-- 
-- 
-- -- STYLE
-- 
-- day_classes: Models.Day -> Attribute
-- day_classes day =
--   let
--     firstColor = day.colors |> List.head |> Maybe.withDefault "green"
--     color_class = "day_" ++ firstColor
--   in
--     class ("day_of_month " ++ color_class)
-- 
-- styleBorder: Bool -> Attribute
-- styleBorder today =
--   if today 
--     then style [("border", "3px solid #555")]
--     else style []



