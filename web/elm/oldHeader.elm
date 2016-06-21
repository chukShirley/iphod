port module Header exposing (..) -- where

import Debug

import Html exposing (..)
import Html.App as Html
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Platform.Cmd as Cmd exposing (Cmd)
import String exposing (join)
import Markdown
import Json.Decode as Json

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


-- SUBSCRIPTIONS

subscriptions: Model -> Sub Msg
subscriptions model =
  Sub.batch
  [ configuration GetConfig
  , email GetEmail
  ]

port configuration: (Models.Config -> msg) -> Sub msg
port email: (Models.Email -> msg) -> Sub msg

port sendEmail: Models.Email -> Cmd msg
port saveConfig: Models.Config -> Cmd msg

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

init: (Model, Cmd Msg)
init = (initModel, Cmd.none)

-- UPDATE

type Msg
  = NoOp
  | Send
  | Clear
  | Cancel
  | SaveConfig
  | GetConfig Models.Config
  | GetEmail Models.Email
  | SetHeader Model
  | EmailAddress String
  | Topic String
  | Message String
  | ConfigMsg Config.Msg

update: Msg -> Model -> (Model, Cmd Msg)
update msg model =
  case msg of
    NoOp -> (model, Cmd.none)

    Send -> (model, sendEmail model.email)

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

    SaveConfig -> (model, saveConfig model.config)

    SetHeader newModel -> 
      let
        foo = Debug.log "SET HEADER" newModel
      in
        (newModel, Cmd.none)
  
    GetConfig this_config -> 
      let
        foo = Debug.log "UPDATE CONFIG" this_config
      in
        ({model | config = this_config}, Cmd.none)

    GetEmail this_email -> ({model | email = this_email}, Cmd.none)

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

    ConfigMsg msg ->
      let
        foo = Debug.log "CONFIG MSG" msg
      in
        (model, Cmd.none)


-- HELPERS

-- VIEW

view: Model -> Html Msg
view model =
  ul [id "header-options"]
  [ li [class "option-item"] [ howToModal ]
  , li [class "option-item"] [ configModal model ]
  , li [class "option-item"] [ emailMe model ]
  , li [class "option-item"] [ aboutModal ]
  ]
--  [ emailMe model
--  , aboutDiv model
--  , config model
--  ]


emailMe: Model -> Html Msg
emailMe model =
  span []
  [ a [href "#email-create"] [ button [] [text "Contact"] ]
  , div [ id "email-create", class "emailModalDialog"]
    [ div []
      [ a [href "#closeemail-create", title "Close", class "close"] [text "X"] 
      , h2 [class "modal_header"] [ text "Contact" ]
      , (inputEmailAddress model.email)
      , (inputSubject model.email)
      , (inputMessage model.email)
      , button [ class "email-button", onClick Send] [text "Send"]
      , button [ class "email-button", onClick Clear] [text "Clear"]
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
            , (Config.view model.config |> Html.map ConfigMsg)
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
        , type' "text"
        , placeholder "Your Email Address - required"
        , autofocus True
        , name "from"
        , on "input" (Json.succeed (EmailAddress model.from))
        -- , onClickLimited NoOp
        , onWithOptions "click" 
          { stopPropagation = True, preventDefault = True }
          (Json.succeed NoOp)
        , value model.from
        , class "email-addr"
        ]
        []
    ]

inputSubject: Models.Email -> Html Msg
inputSubject model =
  p []
    [ input 
        [ id "topic"
        , type' "text"
        , placeholder "Subject - required"
        , autofocus True
        , name "topic"
        , on "input" (Json.succeed (Topic model.from))
        -- , onClickLimited NoOp
        , onWithOptions "click" 
          { stopPropagation = True, preventDefault = True }
          (Json.succeed NoOp)
        , value model.topic
        , class "email-subject"
        ]
        []
    ]

inputMessage: Models.Email -> Html Msg
inputMessage model =
  p []
    [ textarea 
        [ id "text"
        , type' "text"
        , placeholder "Enter Message - required"
        , autofocus True
        , name "text"
        , on "input" (Json.succeed (Message model.from))
        -- , onClickLimited NoOp
        , onWithOptions "click" 
          { stopPropagation = True, preventDefault = True }
          (Json.succeed NoOp)
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

