port module Header exposing (..) -- where

import Debug

import Html exposing (..)
import Html.App as Html
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Json.Decode as Json exposing (..)
import Platform.Sub as Sub exposing (batch, none)
import Platform.Cmd as Cmd exposing (Cmd)
import String exposing (join)
import Markdown
import Regex


import Iphod.Helper exposing (hideable)
import Iphod.Models as Models
import Iphod.Config as Config


-- MAIN

main =
  Html.program
    { init = init
    , update = update
    , view = view
    , subscriptions = subscriptions
    }


-- MODEL

type alias  Model =
  { email:  Models.Email
  , config: Models.Config
  , shout: Models.Shout
  }

initModel: Model
initModel = 
  { email   = Models.emailInit
  , config  = Models.configInit
  , shout   = Models.initShout
  }

init: (Model, Cmd Msg)
init = (initModel, Cmd.none)

-- REQUEST PORTS

port sendEmail: Models.Email -> Cmd msg

port saveConfig: Models.Config -> Cmd msg

port getConfig: Models.Config -> Cmd msg

port toggleChat: Models.Shout -> Cmd msg

port submitComment: Models.Shout -> Cmd msg

-- SUBSCRIPTIONS

port portConfig: (Models.Config -> msg) -> Sub msg
port portShout: (String -> msg) -> Sub msg
port portInitShout: (Models.Shout -> msg) -> Sub msg

subscriptions : Model -> Sub Msg
subscriptions model = 
  Sub.batch
  [ portConfig UpdateConfig
  , portShout UpdateComments
  , portInitShout InitShout
  ]


-- UPDATE

type Msg
  = NoOp
  | Send
  | Clear
  | Cancel
  | UpdateConfig Models.Config
  | EmailAddress String
  | Topic String
  | Message String
  | ModConfig Config.Msg
  | UpdateComments String
  | CommentText String
  | ShoutComment
  | ToggleChat
  | UpdateUserName String
  | EnterChat
  | InitShout Models.Shout

update: Msg -> Model -> (Model, Cmd Msg)
update msg model =
  case msg of
    NoOp -> (model, Cmd.none)

    Send -> 
      (model, sendEmail model.email)

    Clear -> 
      let
        e = model.email
        newEmail = {e | text = ""}
        newModel = {model | email = newEmail}
      in
        (newModel, Cmd.none)

    Cancel -> 
      let
        newModel = {model | email = Models.emailInit}
      in
        (newModel, Cmd.none)

    UpdateConfig this_config -> 
      ({model | config = this_config}, saveConfig this_config)

    EmailAddress s ->
      let 
        e = model.email
        newEmail = {e | from = s}
        newModel = {model | email = newEmail}
      in
        (newModel, Cmd.none)

    Topic s ->
      let
        e = model.email
        newEmail = {e | topic = s}
        newModel = {model | email = newEmail}
      in
        (newModel, Cmd.none)

    Message s ->
      let
        e = model.email
        newEmail = {e | text = s}
        newModel = {model | email = newEmail}
      in
        (newModel, Cmd.none)

    ModConfig msg ->
      let
        newConfig = Config.update msg model.config
        newModel = {model | config = newConfig}
      in
        (newModel, saveConfig newConfig)

    UpdateComments shout ->
      let 
        thisShout = model.shout
        newShout = {thisShout | chat = (shout :: thisShout.chat)}
        newModel = {model | shout = newShout}
      in
        (newModel, Cmd.none)

    CommentText str ->
      let
        thisShout = model.shout
        newShout = {thisShout | comment = str}
      in
        ({model | shout = newShout}, Cmd.none)

    ShoutComment ->
      (model, submitComment model.shout)

    ToggleChat -> 
      let
        thisShout = model.shout
        newShout = {thisShout | showChat = not model.shout.showChat}
        newModel = {model | shout = newShout}
      in
        (newModel, toggleChat newShout)

    UpdateUserName str ->
      let
        thisShout = model.shout
        newShout = {thisShout | user = str}
        newModel = {model | shout = newShout}
      in
        (newModel, Cmd.none)

    EnterChat ->
      let
        newCmd = shoutThis model.shout (model.shout.user ++ " has entered chat room...")
      in
        (model, newCmd)

    InitShout shout -> ({model | shout = shout}, Cmd.none)


-- HELPERS

shoutThis: Models.Shout -> String -> Cmd Msg
shoutThis shout str = 
  let
    newShout = {shout | comment = str}
  in
    submitComment newShout



-- VIEW

view: Model -> Html Msg
view model =
  div []
    [ ul [id "header-options"]
      [ li [class "option-item"] [ calendar model]
      , li [class "option-item"] [ aboutModal ]
      , li [class "option-item"] [ emailMe model ]
      , li [class "option-item"] [ howToModal ]
      , li [class "option-item"] [ configModal model ]
      , li [class "option-item"] [ translations model ]
      , li [class "option-item"] [ chat model]
      ]
    , chatWindow model
    ]


-- HELPERS

chat: Model -> Html Msg
chat model =
  button [class "toggle-chat", onClick ToggleChat] [text "Show Chat"]

calendar: Model -> Html Msg
calendar model = 
  a [href "/calendar"]
    [ button [] [text "Calendar"] ]

chatWindow: Model -> Html Msg
chatWindow model =
  let
    view_chat chat = li [] [Markdown.toHtml [] chat]
  in
    div [ id "chat-container"]
      [ p []
        [ enterUserName model 
        , button [id "chat-window-toggle", onClick ToggleChat] [text "Hide"]
        ]
      , inputComment model
      , ul [class "chat_list", onClick ToggleChat]
        (List.map view_chat model.shout.chat)
      ]

enterUserName: Model -> Html Msg
enterUserName model =
  input [ placeholder "User Name"
        , autofocus True
        , Html.Attributes.value model.shout.user
        , name "userName"
        , onInput UpdateUserName
        , onEnter EnterChat [9, 13] -- tab or enter
        ] 
        []

onEnter : Msg -> List Int -> Attribute Msg
onEnter msg codes =
  let
    tagger code =
      if List.member code codes then -- Enter or Tab
        msg
      else
        NoOp
  in
    on "keydown" (Json.map tagger keyCode)



inputComment: Model -> Html Msg
inputComment model =
  p [ id "say-this"
    , placeholder "Use Markdown"
    , contenteditable True
    , on "input" (Json.map CommentText innerHtmlDecoder)
    , onEnter ShoutComment [13] -- enter key
    ]
    []

innerHtmlDecoder =
  Json.at ["target", "innerHTML"] Json.string



translations: Model -> Html Msg
translations model =
  a [href "versions"] 
    [ button [] [text "Translations"] ]

emailMe: Model -> Html Msg
emailMe model =
  span []
  [ a [href "#email-create"] [ button [] [text "Contact"] ]
  , div 
    [ id "email-create", class "emailModalDialog"]
    [ div []
      [ a [href "#closeemail-create", title "Close", class "close"] [text "X"] 
      , h2 [class "modal_header"] [ text "Contact" ]
      , (inputEmailAddress model.email)
      , (inputSubject model.email)
      , (inputMessage model.email)
      , a [href "#closeemail-create", title "Send"]
          [ button [ class "email-button", onClick Send ] [text "Send"] ]
      , button [ class "email-button", onClick Clear] [text "Clear Message"]
      , a [href "#closeemail-create", title "Cancel"] 
          [ button [ class "email-button", onClick Cancel] [text "Cancel"] ]
      ]
    ]
  ]

configModal: Model -> Html Msg
configModal model =
  span []
  [ a [ href "#config-text" ] [ button [] [text "Config"] ]
    , div 
        [ id "config-text", class "configModalDialog" ]
        [ div []
            [ a [href "#closeconfig-text", title "Close", class "close"] [text "X"] 
            , h2 [class "modal_header"] [ text "Config" ]
            , Html.map ModConfig (Config.view model.config)
            --, (Config.view (Signal.forwardTo (ModConfig model.config)) model.config)
            ]
        ]
    ]

aboutModal: Html Msg
aboutModal =
  span []
  [ a [ href "#about-text" ] [ button [] [text "About"] ]
    , div 
        [ id "about-text", class "modalDialog" ]
        [ div []
            [ a [href "#closeabout-text", title "Close", class "close"] [text "X"] 
            , h2 [class "modal_header"] [ text "About" ]
            , p [] [Markdown.toHtml [] about]
            ]
        ]
    ]

howToModal: Html Msg
howToModal =
  span []
  [ a [ href "#howTo-text" ] 
        [ button [] [text "How to Use"] ]
    , div 
        [ id "howTo-text", class "modalDialog" ]
        [ div []
            [ a [href "#closehowTo-text", title "Close", class "close"] [text "X"] 
            , h2 [class "modal_header"] [ text "How to Use" ]
            , p [] [Markdown.toHtml [] howToUse]
            ]
        ]
    ]

inputEmailAddress: Models.Email -> Html Msg
inputEmailAddress model =
  p []
    [ input 
        [ id "from"
        , class "email-addr"
        , name "from"
        , type' "text"
        , placeholder "Your Email Address - required"
        , Html.Attributes.value model.from
        , onInput EmailAddress
        , autofocus True
        ]
        []
    ]

inputSubject: Models.Email -> Html Msg
inputSubject model =
  p []
    [ input 
        [ id "topic"
        , class "email-subject"
        , name "topic"
        , type' "text"
        , placeholder "Subject - required"
        , Html.Attributes.value model.topic
        , onInput Topic
        , autofocus True
        ]
        []
    ]

inputMessage: Models.Email -> Html Msg
inputMessage model =
  p []
    [ textarea 
        [ id "text"
        , class "email-msg-addr"
        , name "text"
        , placeholder "Enter Message - required"
        , Html.Attributes.value model.text
        , onInput Message
        , autofocus True
        ]
        []
    ]
howToUse = """

* In General...
  * click on stuff to make it appear and disappear
* click on <button>Contact</button> to send the site admin an email
* click on <button>About</button> to learn about this site
  * who is responsible
  * how it was done
* click on <button>Config</button>
  * to select translations you want to use
  * to display footnotes (if available) or not
* click on <button>MP</button>, <button>EP</button>, or <button>EU</button>
  * to see MP, MP, or Eucharistic readings for the day
* Calendar buttons
  * click on day of month number to see alternate colors
  * <Morning Prayer> to see Morning Prayer for today
  * <Evening Prayer> to see Evening Prayer for today
  * <MP> to see Morning Prayer readings for today
  * <EP> to see Evening Prayer readings for today
  * <EU> to see Eucharistic readings for today
  * "<" to see last month
  * ">" to see next month
  * <Roll Up> to make calendar (mostly) disappear
  * <Roll Down> to make calendar reappear
* colors
  * Yellow - means "White and alternatives"
  * Black - text is a required reading
  * Grey - text is optional reading
  * Dark Blue - text is alternative reading

"""

about = """
#### About Iphod
* It is a work in progress
* Inerrancy is not gauranteed, so don't expect it
* Facebook group at https://www.facebook.com/groups/471879323003692/
  * report errors
  * make suggestions
  * ask questions
* So far this is a work of my (aka: Paul Sutcliffe+) own doing
* shows assigned readings and ESV text for the ACNA Red Letter, Sunday Lectionary, and Daily Prayer. Current fails include...
  * partial verses mean nothing to the ESV API, so in this app only complete verses are shown

#### Want to help?
* this is an open source project
* you can fork the project at https://github.com/frpaulas/iphod

#### Tech stuff
* The back end is Elixir (http://elixir-lang.org)
* The front end is a mix of...
  * Phoenix (http://http://www.phoenixframework.org/)
  * javascript
  * Elm (http://http://elm-lang.org/)
* What was I thinking!?!
  * I've been using Elixir for closing in on 2 years and it's esthetically pleasing and FAST
  * Phoenix does a respectable job of taking care of front end stuff - like Ruby on Rails
  * Elm - Well, that was a struggle, but having learned I can say it makes doing crazy front end stuff easier
* It's open source
  * https://github.com/frpaulas/iphod
* Other project
  * open source donation/donor tracking at https://github.com/frpaulas/saints
  * fun run at elmsaints.heroku.com
  * log in with user name: guest, password: password

* About Me
  * for lack of a better word, I'm a retired-from-day-job-for-lack-of-employment-bi-vocational-priest
  * (hyphenation was the only way I could do it in one word)
  * Rector at a completely unsuccessful (from a worldly POV), tiny ACNA church near Pittsburgh.
  * Let it be said however, to the best of my knowledge, the first ever planted inside a retirement community
  * no roof to worry about, etc.
  * we give all our money away



"""


-- STYLE

buttonStyle:  Attribute msg
buttonStyle =
  style
    [ ("position", "relative")
    , ("float", "left")
    , ("padding", "2px 2px")
    , ("font-size", "0.8em")
    , ("display", "inline-block")
    ]

aboutButtonStyle: Attribute msg
aboutButtonStyle =
  style
    [ ("position", "relative")
    , ("float", "right")
--    , ("float", "left")
    , ("padding", "2px 2px")
    , ("font-size", "0.8em")
    , ("display", "inline-block")
    ]

