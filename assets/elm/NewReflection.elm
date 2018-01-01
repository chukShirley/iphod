port module NewReflection exposing (..) -- where

-- import Debug

import Html exposing (..)
import Html
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Markdown exposing (..)

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
  { id:         Int
  , date:       String
  , author:     String
  , text:       String
  , published:  Bool
  }

initModel: Model
initModel =
  { id        = 0
  , date      = ""
  , author    = ""
  , text      = ""
  , published = False
  }

init: (Model, Cmd Msg)
init = (initModel, Cmd.none)

-- PORTS

port portSubmit: Model -> Cmd msg
port portReset: Model -> Cmd msg
port portBack: Model -> Cmd msg

port portReflection: (Model -> msg) -> Sub msg

subscriptions: Model -> Sub Msg
subscriptions model =
  Sub.batch
  [ portReflection InitRefl]

-- UPDATE

type Msg
  = NoOp
  | InitRefl Model
  | ReflectionDate String
  | ReflectionAuthor String
  | ReflectionText String
  | Submit
  | Reset
  | Back
  | Published Bool

update: Msg -> Model -> (Model, Cmd Msg)
update msg model =
  case msg of
    NoOp -> (model, Cmd.none)

    InitRefl newModel ->
      let
        foo = Debug.log "INIT REFL" newModel
      in
        (newModel, Cmd.none)

    ReflectionDate s ->
      ( { model | date = s }, Cmd.none)

    ReflectionAuthor s ->
      ( { model | author = s }, Cmd.none)

    ReflectionText s ->
      ( { model | text = s }, Cmd.none)

    Submit -> ( model, portSubmit model )

    Reset -> ( model, portReset model )

    Back -> (model, portBack model)

    Published bool ->
      let
        -- foo = Debug.log "PUBLISHED" bool
        newModel = { model | published = bool }
      in
        ( newModel, portSubmit newModel)


-- VIEW

view: Model -> Html Msg
view model =
  div [ id "refl-edit"]
  [ inputDate model
  , inputAuthor model
  , inputText model
  , ul [id "refl-buttons"]
      [ li [] [ button [ onClick Submit ] [ text "Save" ] ]
      , li [] [ button [ onClick Reset ]  [ text "Reset" ] ]
      , li [] [ button [ onClick Back ] [ text "List" ] ]
      ]
  , showText model
  ]

inputDate: Model -> Html Msg
inputDate model =
  p []
    [ input
        [ id "reflection-date"
        , name "reflection-date"
        , type_ "text"
        , placeholder "Reflection Date"
        , Html.Attributes.value model.date
        , onInput ReflectionDate
        , autofocus True
        ]
        []
    ]

inputAuthor: Model -> Html Msg
inputAuthor model =
  p []
    [ input
        [ id "reflection-author"
        , name "reflection-author"
        , type_ "text"
        , placeholder "Your name"
        , Html.Attributes.value model.author
        , onInput ReflectionAuthor
        , autofocus True
        ]
        []
    ]

inputText: Model -> Html Msg
inputText model =
  p [ id "refl-textarea"]
    [ textarea
        [ id "reflection-text"
        , name "reflection-text"
        , placeholder "Use Markdown formatting"
        , Html.Attributes.value model.text
        , onInput ReflectionText
        , autofocus True
        ]
        []
    ]

showText: Model -> Html Msg
showText model =
  div [id "preview"]
  [ h3 [class "reflection-preview"]
    [ text "Preview  "
    , span [ style [("font-weight", "normal"), ("font-size", "0.7em")] ] [ text "( published" ]
    , input [ type_ "checkbox"
            , checked model.published
            , onCheck Published
            ]
            []
    , span [ style [("font-weight", "normal"), ("font-size", "0.7em")] ] [ text ")" ]
    ]
  , div [id "md-text"] [Markdown.toHtml [] model.text]
  ]
