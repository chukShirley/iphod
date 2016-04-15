module Iphod.Email (  Model, init, Action, update, view, 
                      sendContactMe) where

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Effects exposing (Effects, Never)
import String exposing (join)
import Json.Decode as Json
import Helper exposing (onClickLimited, hideable, getText)
import Iphod.Models exposing (Email, emailInit)

-- MODEL

type alias Model = Email

init: Model
init = emailInit

-- MAILBOX

sendContactMe: Signal.Mailbox Model
sendContactMe =
  Signal.mailbox init


-- UPDATE

type Action
  = NoOp
  | Send
  | Clear
  | Cancel
  | EmailAddress String
  | Topic String
  | Message String

update: Action -> Model -> Model
update action model =
  case action of
    NoOp -> model
    Send -> 
      let
        foo = Debug.log "EMAIL" model
      in
        model
    Clear -> {model | text = ""}
    Cancel -> init
    EmailAddress s -> {model | from = s}
    Topic s -> {model | topic = s}
    Message s -> {model | text = s}


-- VIEW

view: Signal.Address Action -> Model -> Html
view address model =
  div
  [ contactStyle model]
  [ (inputEmailAddress address model)
  , (inputSubject address model)
  , (inputMessage address model)
  , button [ buttonStyle, onClick sendContactMe.address model ] [text "Send"]
  , button [ buttonStyle, onClick address Clear] [text "Clear"]
  , button [ buttonStyle, onClick address Cancel] [text "Cancel"]
  ]

inputEmailAddress: Signal.Address Action -> Model -> Html
inputEmailAddress address model =
  p []
    [ input 
        [ id "from"
        , type' "text"
        , placeholder "Your Email Address - required"
        , autofocus True
        , name "from"
        , on "input" targetValue (\str -> Signal.message address (EmailAddress str))
        , onClickLimited address NoOp
        , value model.from
        , emailAddrStyle model
        ]
        []
    ]

inputSubject: Signal.Address Action -> Model -> Html
inputSubject address model =
  p []
    [ input 
        [ id "topic"
        , type' "text"
        , placeholder "Subject - required"
        , autofocus True
        , name "topic"
        , on "input" targetValue (\str -> Signal.message address (Topic str))
        , onClickLimited address NoOp
        , value model.topic
        , subjectStyle model
        ]
        []
    ]

inputMessage: Signal.Address Action -> Model -> Html
inputMessage address model =
  p []
    [ textarea 
        [ id "text"
        , type' "text"
        , placeholder "Enter Message - required"
        , autofocus True
        , name "text"
        , on "input" targetValue (\str -> Signal.message address (Message str))
        , onClickLimited address NoOp
        , value model.text
        , msgAddrStyle model 
        ]
        []
    ]

-- STYLE

contactStyle: Model -> Attribute
contactStyle model =
  hideable
    model.show
    [ ("position", "absolute")
    , ("z-index", "999")
    , ("height", "15em")
    , ("width", "50em")
    , ("margin-top", "0.5em")
    , ("border", "2px solid darkblue")
    , ("border-radius", "0.5em")
    , ("background-color", "linen") 
    ]

emailAddrStyle: Model -> Attribute
emailAddrStyle model =
  style
    [ ("width", "20em")
    , ("margin-left", "1em")
    , ("margin-top", "1em")
    , ("padding-left", "1em")
    ]

subjectStyle: Model -> Attribute
subjectStyle model =
  style
    [ ("width", "45em")
    , ("margin-left", "1em")
    , ("padding-left", "1em")
    ]

msgAddrStyle: Model -> Attribute
msgAddrStyle model =
  style
    [ ("width", "45em")
    , ("height", "5em")
    , ("margin-left", "1em")
    , ("padding-left", "1em")
    ]

buttonStyle: Attribute
buttonStyle =
  style
    [ ("float", "left")
    , ("margin-left", "1em")
    , ("padding", "2px 2px")
    , ("font-size", "0.8em")
    , ("display", "inline-block")
    ]


