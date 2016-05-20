module Header where

import Debug

import StartApp
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Http
import Regex
import Json.Decode as Json exposing ((:=))
import Effects exposing (Effects, Never)
import Task exposing (Task, andThen)
import String exposing (join)
import Markdown
import Graphics.Element as Graphics

import Iphod.Helper exposing (onClickLimited, hideable, getText)
import Iphod.Models as Models
-- import Iphod.Email as Email
-- import Iphod.Email exposing(sendContactMe)
import Iphod.Config as Config

app =
  StartApp.start
    { init = init
    , update = update
    , view = view
    , inputs =  [ incomingActions
                , incomingEmail
                ]
    }


-- MAIN

main: Signal Html
main = app.html


port tasks: Signal (Task Never ())
port tasks = app.tasks


-- MODEL

type alias  Model =
  { email:  Models.Email 
  , config: Models.Config
  }

initModel: Model
initModel = 
  { email   = Models.emailInit
  , config  = Models.configInit
  }

init: (Model, Effects Action)
init = (initModel, Effects.none)


-- SIGNALS

incomingActions: Signal Action
incomingActions =
  Signal.map SetHeader newHeader


incomingEmail: Signal Action
incomingEmail =
  Signal.map UpdateEmail newEmail

saveThisConfig: Signal.Mailbox Models.Config
saveThisConfig =
  Signal.mailbox Models.configInit

sendContactMe: Signal.Mailbox Models.Email
sendContactMe =
  Signal.mailbox Models.emailInit


  -- PORTS
  
port savingConfig: Signal Models.Config
port savingConfig = 
  saveThisConfig.signal

port sendEmail: Signal Models.Email
port sendEmail =
  sendContactMe.signal

port newEmail: Signal Models.Email
port newHeader: Signal Model

-- UPDATE

type Action
  = NoOp
  | Send
  | Clear
  | Cancel
  | SetHeader Model
  | UpdateEmail Models.Email
  | EmailAddress String
  | Topic String
  | Message String
--  | ModEmail Email.Model Email.Action
  | ModConfig Config.Model Config.Action

update: Action -> Model -> (Model, Effects Action)
update action model =
  case action of
    NoOp -> (model, Effects.none)

    Send -> (model, Effects.none)

    Clear -> 
      let
        e = model.email
        newEmail = {e | text = ""}
        newModel = {model | email = newEmail}
      in
        (newModel, Effects.none)

    Cancel -> 
      let
        newModel = {model | email = Models.emailInit}
      in
        (newModel, Effects.none)

    SetHeader newModel -> (newModel, Effects.none)
  
    UpdateEmail this_email -> ({model | email = this_email}, Effects.none)

    EmailAddress s ->
      let 
        e = model.email
        newEmail = {e | from = s}
        newModel = {model | email = newEmail}
      in
        (newModel, Effects.none)

    Topic s ->
      let
        e = model.email
        newEmail = {e | topic = s}
        newModel = {model | email = newEmail}
      in
        (newModel, Effects.none)

    Message s ->
      let
        e = model.email
        newEmail = {e | text = s}
        newModel = {model | email = newEmail}
      in
        (newModel, Effects.none)

    ModConfig cmodel caction ->
      let
        foo = Debug.log "CONFIG" model.config
        newModel = {model | config = Config.update caction cmodel}
      in
        (newModel, saveConfig newModel.config)


-- HELPERS

saveConfig: Models.Config -> Effects Action
saveConfig config =
  Signal.send saveThisConfig.address (config)
  |> Task.toMaybe
  |> Task.map (always NoOp)
  |> Effects.task


-- VIEW

view: Signal.Address Action -> Model ->Html
view address model =
  ul [id "header-options"]
  [ li [class "option-item"] [ howToModal ]
  , li [class "option-item"] [ configModal address model ]
  , li [class "option-item"] [ emailMe address model ]
  , li [class "option-item"] [ aboutModal ]
  ]
--  [ emailMe address model
--  , aboutDiv address model
--  , config address model
--  ]


emailMe: Signal.Address Action -> Model -> Html
emailMe address model =
  span []
  [ a [href "#email-create"] [ button [] [text "Contact"] ]
  , div [ id "email-create", class "emailModalDialog"]
    [ div []
      [ a [href "#closeemail-create", title "Close", class "close"] [text "X"] 
      , h2 [class "modal_header"] [ text "Contact" ]
      , (inputEmailAddress address model.email)
      , (inputSubject address model.email)
      , (inputMessage address model.email)
      , button [ class "email-button", onClick sendContactMe.address model.email ] [text "Send"]
      , button [ class "email-button", onClick address Clear] [text "Clear"]
      , a [href "#closeemail-create", title "Cancel"] 
          [ button [ class "email-button", onClick address Cancel] [text "Cancel"] ]
      ]
    ]
  ]
--  , (Email.view (Signal.forwardTo address (ModEmail model.email)) model.email)
-- Sunday.view (Signal.forwardTo address (ModSunday model.sunday)) model.sunday

configModal: Signal.Address Action -> Model -> Html
configModal address model =
  span []
  [ a [ href "#config-text" ] [ button [] [text "Config"] ]
    , div 
        [ id "config-text", class "configModalDialog" ]
        [ div []
            [ a [href "#closeconfig-text", title "Close", class "close"] [text "X"] 
            , h2 [class "modal_header"] [ text "Config" ]
            , (Config.view (Signal.forwardTo address (ModConfig model.config)) model.config)
            ]
        ]
    ]

-- config: Signal.Address Action -> Model -> Html
-- config address model = 
--   div [class "cssmenu", style [("z-index", "99")]]
--     [(Config.view (Signal.forwardTo address (ModConfig model.config)) model.config)]

aboutModal: Html
aboutModal =
  span []
  [ a [ href "#about-text" ] [ button [] [text "About"] ]
    , div 
        [ id "about-text", class "modalDialog" ]
        [ div []
            [ a [href "#closeabout-text", title "Close", class "close"] [text "X"] 
            , h2 [class "modal_header"] [ text "About" ]
            , p [] [Markdown.toHtml about]
            ]
        ]
    ]

howToModal: Html
howToModal =
  span []
  [ a [ href "#howTo-text" ] 
        [ button [] [text "How to Use"] ]
    , div 
        [ id "howTo-text", class "modalDialog" ]
        [ div []
            [ a [href "#closehowTo-text", title "Close", class "close"] [text "X"] 
            , h2 [class "modal_header"] [ text "How to Use" ]
            , p [] [Markdown.toHtml howToUse]
            ]
        ]
    ]

inputEmailAddress: Signal.Address Action -> Models.Email -> Html
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

inputSubject: Signal.Address Action -> Models.Email -> Html
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

inputMessage: Signal.Address Action -> Models.Email -> Html
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

buttonStyle: Attribute
buttonStyle =
  style
    [ ("position", "relative")
    , ("float", "left")
    , ("padding", "2px 2px")
    , ("font-size", "0.8em")
    , ("display", "inline-block")
    ]

aboutButtonStyle: Attribute
aboutButtonStyle =
  style
    [ ("position", "relative")
    , ("float", "right")
--    , ("float", "left")
    , ("padding", "2px 2px")
    , ("font-size", "0.8em")
    , ("display", "inline-block")
    ]

