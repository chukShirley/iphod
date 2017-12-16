port module Iphod exposing (..)

-- where

import Debug


-- import StartApp

import Html exposing (..)
import Html
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Http exposing (..)
import Json.Decode exposing (..)
import Regex
import Platform.Sub as Sub exposing (batch)
import Platform.Cmd as Cmd exposing (Cmd)
import String exposing (join)
import Markdown
import Iphod.Helper exposing (hideable)
import Iphod.Models as Models
-- import Pouchdb exposing (..)


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
    , lesson1 : List Models.LessonRequest
    , lesson2 : List Models.LessonRequest
    , lesson3 : List Models.LessonRequest
    , lessonRequests : List Models.LessonRequest -- in case of query failure, allows trying alternate source
    , psalm : List Models.LessonRequest -- BTW, no code to load these yet
    , reflection : Models.Reflection
    , online : Bool
    }


initModel : Model
initModel =
    { month = Models.initMonth
    , reflection = Models.initReflection
    , lesson1 = []
    , lesson2 = []
    , lesson3 = []
    , lessonRequests = []
    , psalm = []
    , online = True
    }

init : ( Model, Cmd Msg )
init =
    ( initModel, Cmd.none )

esvHeader = Models.initESV

-- REQUEST PORTS


port requestReading : List String -> Cmd msg -- probably not needed

port requestWEB : Models.LessonRequest -> Cmd msg

port requestAltReading : List String -> Cmd msg

port requestScrollTop : String -> Cmd msg



-- SUBSCRIPTIONS


port portMonth : (Models.Month -> msg) -> Sub msg

port portLesson : (List Models.LessonRequest -> msg) -> Sub msg

port portWEB : (Models.LessonRequest -> msg) -> Sub msg

port portReflection : (Models.Reflection -> msg) -> Sub msg

port portAddLesson : (Models.Lesson -> msg) -> Sub msg

port portOnline : (Bool -> msg) -> Sub msg


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch
        [ portMonth InitMonth
        , portLesson UpdateLesson
        , portWEB UpdateFromWEB
        , portReflection UpdateReflection
        , portOnline UpdateOnline
        ]



-- UPDATE


type ShowHide
    = Show
    | Hide


type Msg
    = NoOp
    | UpdateOnline Bool
    | InitMonth  Models.Month
    | UpdateReflection Models.Reflection
    | UpdateLesson (List Models.LessonRequest)
    | UpdateFromWEB Models.LessonRequest
    | GetReadings String Models.Day
    | DecodeESVLesson Models.LessonRequest (Result Http.Error String)



update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        NoOp ->
            ( model, Cmd.none )

        UpdateOnline is -> ( {model | online = is }, Cmd.none )

        InitMonth month ->
          let
            newModel = {model | month = month}
          in
            ( newModel, Cmd.none )

        UpdateReflection reflection ->
            let
                newModel = { model | reflection = reflection }
            in
                ( newModel, Cmd.none )

        UpdateLesson lessonRequests -> (model, Cmd.none)

        UpdateFromWEB resp ->
          let
            newModel = case resp.lesson of
              1 -> {model | lesson1 = List.append model.lesson1 [resp]} --, lessonRequests = t}
              2 -> {model | lesson2 = List.append model.lesson2 [resp]} --, lessonRequests = t}
              3 -> {model | lesson3 = List.append model.lesson3 [resp]} --, lessonRequests = t}
              _ -> model
          in
            (newModel, Cmd.none)  

        GetReadings service day ->
          let
            requests = case service of
              "MP" -> List.concat [toIndexList 1 day.daily.mp1, toIndexList 2 day.daily.mp2]
              "EP" -> List.concat [toIndexList 1 day.daily.ep1, toIndexList 2 day.daily.ep2]
              "EU" -> List.concat [toIndexList 1 day.eu.ot, toIndexList 2 day.eu.nt, toIndexList 3 day.eu.gs]
              _    -> []
            newModel = { model | lesson1 = [], lesson2 = [], lesson3 = [], psalm = [], lessonRequests = requests }

          in  
            ( newModel, getLessons newModel)

        DecodeESVLesson request (Ok lesson) ->
          let
            esv = decodeString decodeESV lesson |> Result.withDefault Models.initESVresp
            nextLesson = if String.isEmpty esv.canonical then (model, requestWEB request)
              else
                let
                  thisRequest = [{request | text = (String.join "" esv.passages)}]
                  newModel = case request.lesson of
                    1 -> {model | lesson1 = model.lesson1 ++ thisRequest}
                    2 -> {model | lesson2 = model.lesson2 ++ thisRequest}
                    3 -> {model | lesson3 = model.lesson3 ++ thisRequest}
                    _ -> model
                in
                  (newModel, Cmd.none)
          in
            nextLesson
        
        DecodeESVLesson request (Err wtf) -> (model, requestWEB request)       


-- HELPERS

getLessons : Model -> Cmd Msg
getLessons model =
  let
    h = List.head model.lessonRequests |> Maybe.withDefault Models.initLessonRequest
    t = List.tail model.lessonRequests |> Maybe.withDefault []
    newModel = {model | lessonRequests = t}
    cmdMsg = case h.src of
      "ESV" -> Cmd.batch [requestESV h, getLessons newModel]
      "WEB" -> Cmd.batch [requestWEB h, getLessons newModel]
      _     -> Cmd.none -- unknown source
  in
    cmdMsg

      
decodeESV: Decoder Models.ESVresp
decodeESV =
  map5 Models.ESVresp
    (field "query" string)
    (field "canonical" string)
    (field "parsed" decodeESVparsed )
    (field "passage_meta" decodeESVmeta)
    (field "passages" (Json.Decode.list string))


decodeESVparsed: Decoder (List Models.ESVparsed)
decodeESVparsed = 
  (Json.Decode.list (Json.Decode.list int))

decodeESVmeta: Decoder (List Models.ESVmeta)
decodeESVmeta =
  Json.Decode.list (
    map7 Models.ESVmeta
      (field "canonical" string)
      (field "chapter_start" (Json.Decode.list int))
      (field "chapter_end" (Json.Decode.list int))
      (field "prev_verse" int)
      (field "next_verse" int)
      (field "prev_chapter" (Json.Decode.list int))
      (field "next_chapter" (Json.Decode.list int))
  )


requestESV: Models.LessonRequest -> Cmd Msg
requestESV request =
  let
    corsGet =
      { method = "GET"
      , headers =
        [ Http.header "Authorization" esvHeader.key
        ]
      , url = esvHeader.url ++ request.ref ++ "&include-headings=false"
      , body = Http.emptyBody
      , expect = Http.expectString
      , timeout = Nothing
      , withCredentials = False
    }
  in
    Http.send (DecodeESVLesson request) (Http.request corsGet)
        
toIndexList: Int -> List Models.Lesson -> List Models.LessonRequest
toIndexList i lessons =
  let
    -- will need to change "ESV" to user default pref
    -- lesson number, text ref, style, text source, text source
    newList lesson =  Models.newLessonRequest i lesson.read lesson.style "ESV" ""
  in
    List.map newList lessons      

calendarHref: Models.Day -> String
calendarHref day =
    ("#" ++ day.date) 
            |> Regex.replace Regex.All (Regex.regex " ") (\_ -> "")
            |> Regex.replace Regex.All (Regex.regex ",") (\_ -> "_")    

colorClass: Models.Day -> String
colorClass day =
    "day_" ++ (day.colors |> List.head |> Maybe.withDefault("green"))

lessonListToReadingString: List Models.LessonRequest -> String
lessonListToReadingString lessons =
  let
    allReadings lesson = lesson.text
  in
    List.map allReadings lessons |> String.join " "      


-- VIEW


view : Model -> Html Msg
view model =
  div [ id "calendar-div" ]
    [ calendarTable model
    , lessonDiv "lesson1" model.lesson1
    , lessonDiv "psalm" model.psalm
    , lessonDiv "lesson2" model.lesson2
    , lessonDiv "lesson3" model.lesson3
    , reflectionDiv model.reflection
  ] 

calendarTable : Model -> Html Msg
calendarTable model =
    let
        calendarWeeks week = calendarDays week.days
        calendarHeader = 
          [ tr [] [ th [ class "mpep_link", colspan 7 ] [ text "Today" ] ]
          , tr [] 
              [ th [ class "mpep_link", colspan 2 ] 
                   [ button [ class "prayer-button quick-options", attribute "data-prayer" "morningPrayer"]
                            [ text "Morning Prayer" ]
                   ]
              , th [ class "mpep_link", colspan 3 ] 
                   [ button [ id "next-sunday-button", class "quick-options"] 
                            [ text "Next Sunday" ]
                   , button [ id "reflection-today-button", class "quick-options"] 
                            [ text "Reflection" ]
                   ]
              , th [ class "mpep_link", colspan 2 ]
                   [ button [ class "prayer-button quick-options", attribute "data-prayer" "eveningPrayer"] 
                            [ text "Evening Prayer"]
                   ]
              ]
          , tr []
               [ th [ class "season_link", colspan 2]
                    [ button [ class "quick-options", attribute "data-season" "Advent"] [ text "Advent"] ]
               , th [ class "season_link" ]
                    [ button [ class "quick-options", attribute "data-season" "Epiphany"] [ text "Epiphany"] ]
               , th [ class "season_link" ]
                    [ button [ class "quick-options", attribute "data-season" "Lent"] [ text "Lent"] ]
               , th [ class "season_link" ]
                    [ button [ class "quick-options", attribute "data-season" "Easter"] [ text "Easter"] ]
               , th [ class "season_link", colspan 2]
                    [ button [ class "quick-options", attribute "data-season" "Pentecost"] [ text "Pentecost"] ]
               ]
          , tr [ class "calendar-week" ]
                 [ th [] [ text "Sun" ]
                 , th [] [ text "Mon" ]
                 , th [] [ text "Tue" ]
                 , th [] [ text "Wed" ]
                 , th [] [ text "Thu" ]
                 , th [] [ text "Fri" ]
                 , th [] [ text "Sat" ]
                 ]
          ]
    in
        table [id "calendar"] 
              [ tbody [] ( calendarHeader ++ List.map calendarWeeks model.month.weeks ) ] 

calendarDays : List Models.Day -> Html Msg
calendarDays days =
    let
        thisDay day =
            td [] 
            [ div [ class "td-top" ]
              [ a [ href (calendarHref day), class "color_options" ]
                [ p [ class ("day_of_month " ++ colorClass day) ]
                    [ text day.monthDay ]
                ]
              ] -- end of td-top
            , p [] [ text day.title ]
            , div [ class "td-bottom flyoutmenu"]
              [ ul [ class "day_options"]
                [ li [ class "active has-sub" ]
                  [ a [ href "#"] [ span [] [ text "Readings"] ]
                  , ul []
                    [ li [class "reading_menu", onClick (GetReadings "MP" day)] [ text "Morning Prayer"]
                    , li [class "reading_menu", onClick (GetReadings "EP" day)] [ text "Evening Prayer"]
                    , li [class "reading_menu", onClick (GetReadings "EU" day)] [ text "Eucharist"]
                    ] -- end of inner UL
                  ] -- end of outer LI
                ] -- end of outer UL
              ] -- end of div.td-bottom
            ] -- end of td
    in
        tr [class "calendar-week"] (List.map thisDay days)
            

lessonDiv : String -> List Models.LessonRequest -> Html Msg
lessonDiv divName lessons =
    div [ id divName ] [ Markdown.toHtml [] (lessonListToReadingString lessons) ]


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
