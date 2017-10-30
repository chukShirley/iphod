module Iphod.Email exposing (..) --where
  ( Model, init, Msg, update, view )

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import String exposing (join)
import Json.Decode as Json

import Iphod.Helper exposing (hideable)
import Iphod.Models exposing (Email, emailInit)

-- MODEL

type alias Model = Email

init: Model
init = emailInit

-- MAILBOX

-- sendContactMe: Signal.Mailbox Model
-- sendContactMe =
--   Signal.mailbox init


-- UPDATE

type Msg
  = NoOp
  | Send
  | Clear
  | Cancel
  | EmailAddress String
  | Topic String
  | Message String

update: Msg -> Model -> Model
update msg model =
  case msg of
    NoOp -> model
    Send -> model
    Clear -> {model | text = ""}
    Cancel -> init
    EmailAddress s -> {model | from = s}
    Topic s -> {model | topic = s}
    Message s -> {model | text = s}


-- VIEW

view: Model -> Html Msg
view model =
  (contactModal model)

contactModal: Model -> Html Msg
contactModal model =
  div [ id "email-create", class "modalDialog" ]
    [ a [href "#closeemail-text", title "Close", class "close"] [text "X"]
    , h2 [class "modal_header"] [ text "Contact" ]
    , (inputEmailAddress model)
    , (inputSubject model)
    , (inputMessage model)
    , button [ class "email-button", onClick sendContactMe model ] [text "Send"]
    , button [ class "email-button", onClick Clear] [text "Clear"]
    , button [ class "email-button", onClick Cancel] [text "Cancel"]
    ]


inputEmailAddress: Model -> Html Msg
inputEmailAddress model =
  p []
    [ input
        [ id "from"
        , type_ "text"
        , placeholder "Your Email Address - required"
        , autofocus True
        , name "from"
        , on "input"  (Json.succeed (EmailAddress str))
        -- , onClickLimited NoOp
        , onWithOptions "click"
          { stopPropagation = True, preventDefault = True }
          (Json.succeed NoOp)
        , value model.from
        , class "email-addr"
        ]
        []
    ]

inputSubject: Model -> Html Msg
inputSubject model =
  p []
    [ input
        [ id "topic"
        , type_ "text"
        , placeholder "Subject - required"
        , autofocus True
        , name "topic"
        , on "input" (Json.succeed (Topic str))
        -- , onClickLimited NoOp
        , onWithOptions "click"
          { stopPropagation = True, preventDefault = True }
          (Json.succeed NoOp)
        , value model.topic
        , class "email-subject"
        ]
        []
    ]

inputMessage: Model -> Html Msg
inputMessage model =
  p []
    [ textarea
        [ id "text"
        , type_ "text"
        , placeholder "Enter Message - required"
        , autofocus True
        , name "text"
        , on "input" (Json.succeed (Message str))
        -- , onClickLimited NoOp
        , onWithOptions "click"
          { stopPropagation = True, preventDefault = True }
          (Json.succeed NoOp)
        , value model.text
        , class "email-msg-addr"
        ]
        []
    ]
