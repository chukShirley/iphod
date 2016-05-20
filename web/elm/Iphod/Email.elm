module Iphod.Email (  Model, init, Action, update, view, 
                      sendContactMe) where

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Effects exposing (Effects, Never)
import String exposing (join)
import Json.Decode as Json

import Iphod.Helper exposing (onClickLimited, hideable, getText)
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
  (contactModal address model)
--  div
--  [ class "email"]
--  [ (inputEmailAddress address model)
--  , (inputSubject address model)
--  , (inputMessage address model)
--  , button [ class "email-button", onClick sendContactMe.address model ] [text "Send"]
--  , button [ class "email-button", onClick address Clear] [text "Clear"]
--  , button [ class "email-button", onClick address Cancel] [text "Cancel"]
--  ]

contactModal: Signal.Address Action -> Model -> Html
contactModal address model =
  div [ id "email-create", class "modalDialog" ]
    [ a [href "#closeemail-text", title "Close", class "close"] [text "X"] 
    , h2 [class "modal_header"] [ text "Contact" ]
    , (inputEmailAddress address model)
    , (inputSubject address model)
    , (inputMessage address model)
    , button [ class "email-button", onClick sendContactMe.address model ] [text "Send"]
    , button [ class "email-button", onClick address Clear] [text "Clear"]
    , button [ class "email-button", onClick address Cancel] [text "Cancel"]
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
        , class "email-addr"
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
        , class "email-subject"
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
        , class "email-msg-addr"
        ]
        []
    ]
