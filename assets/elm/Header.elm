
port module Header exposing (..)

-- where

import Debug
import Html exposing (..)
import Html
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Http exposing (..)
import Json.Decode as Decode exposing (..)
import Json.Encode as Encode exposing (..)
import Platform.Sub as Sub exposing (batch, none)
import Platform.Cmd as Cmd exposing (Cmd)
import String exposing (join)
import Markdown
import Iphod.Models as Models
import Iphod.Config as Config
import Iphod.Login as Login


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
    { email : Models.Email
    , config : Models.Config
    , reading : Models.CurrentReadings
    , user : Models.User
    , csrf_token : String
    }


initModel : Model
initModel =
    { email = Models.emailInit
    , config = Models.configInit
    , reading = Models.currentReadingsInit
    , user = Models.userInit
    , csrf_token = ""
    }


init : ( Model, Cmd Msg )
init =
    ( initModel, currentUser Models.userInit )



-- REQUEST PORTS


port sendEmail : Models.Email -> Cmd msg


port saveConfig : Models.Config -> Cmd msg


port getConfig : Models.Config -> Cmd msg


port saveLogin : Models.User -> Cmd msg


port currentUser : Models.User -> Cmd msg

port saveFontSize : Models.Config -> Cmd msg



-- SUBSCRIPTIONS


port portConfig : (Models.Config -> msg) -> Sub msg


port portCSRFToken : (String -> msg) -> Sub msg


port portUser : (Models.User -> msg) -> Sub msg


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch
        [ portConfig UpdateConfig
        , portCSRFToken GetCSRFToken
        , portUser GetUser
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
    | ModLogin Login.Msg
    | ModRegister Login.Msg
    | ModFontSize String
    | SetRegisterPassword String
    | SetRegisterPasswordConfirmation String
    | SetRegisterUserName String
    | SetRegisterRealName String
    | SetRegisterEmail String
    | SetRegisterDescription String
    | Login
    | Logout
    | GetTokenSuccess Models.User
    | AuthUserCompleted (Result Http.Error Models.User)
    | GetCSRFToken String
    | GetUser Models.User
    | AuthError Http.Error


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        NoOp ->
            ( model, Cmd.none )

        Login ->
            ( model, authUserCmd model loginUrl )

        Logout ->
            let
                newModel =
                    { model | user = Models.userInit }
            in
                ( newModel, saveLogin newModel.user )

        GetTokenSuccess user ->
            let
                newModel =
                    { model | user = user }

                cmdMsg =
                    if String.isEmpty user.token then
                        Cmd.none
                    else
                        saveLogin user
            in
                ( newModel, cmdMsg )

        AuthUserCompleted result ->
            getUserCompleted model result

        AuthError error ->
            let
                user =
                    model.user

                newUser =
                    { user | error_msg = (toString error) }

                newModel =
                    { model | user = newUser }
            in
                ( newModel, Cmd.none )

        Send ->
            ( model, sendEmail model.email )

        Clear ->
            let
                e =
                    model.email

                newEmail =
                    { e | text = "" }

                newModel =
                    { model | email = newEmail }
            in
                ( newModel, Cmd.none )

        Cancel ->
            let
                newModel =
                    { model | email = Models.emailInit }
            in
                ( newModel, Cmd.none )

        UpdateConfig this_config ->
            ( { model | config = this_config }, Cmd.none )

        EmailAddress s ->
            let
                e =
                    model.email

                newEmail =
                    { e | from = s }

                newModel =
                    { model | email = newEmail }
            in
                ( newModel, Cmd.none )

        Topic s ->
            let
                e =
                    model.email

                newEmail =
                    { e | topic = s }

                newModel =
                    { model | email = newEmail }
            in
                ( newModel, Cmd.none )

        Message s ->
            let
                e =
                    model.email

                newEmail =
                    { e | text = s }

                newModel =
                    { model | email = newEmail }
            in
                ( newModel, Cmd.none )

        ModConfig msg ->
            let
                newConfig =
                    Config.update msg model.config

                newModel =
                    { model | config = newConfig }
            in
                ( newModel, saveConfig newConfig )

        ModLogin msg ->
            let
                newUser =
                    Login.update msg model.user

                newModel =
                    { model | user = newUser }
            in
                ( newModel, Cmd.none )

        ModRegister msg ->
            let
                newUser =
                    Login.update msg model.user

                newModel =
                    { model | user = newUser }
            in
                ( newModel, Cmd.none )

        ModFontSize msg ->
          let
            fsz = String.toInt model.config.fontSize |> Result.withDefault 12
            config = model.config
            newFsz = case (msg) of
              "f" -> if fsz >= 8 then fsz - 4 else 8
              "F" -> if fsz <= 25 then fsz + 4 else 24
              _   -> fsz
            newConfig = {config | fontSize = toString newFsz }
            newModel = {model | config = newConfig}

              
          in
            (newModel, saveFontSize newModel.config)

        SetRegisterPassword s ->
            let
                user =
                    model.user

                newUser =
                    { user | password = s }

                newModel =
                    { model | user = newUser }
            in
                ( newModel, Cmd.none )

        SetRegisterPasswordConfirmation s ->
            let
                user =
                    model.user

                newUser =
                    { user | password_confirmation = s }

                newModel =
                    { model | user = newUser }
            in
                ( newModel, Cmd.none )

        SetRegisterUserName s ->
            let
                user =
                    model.user

                newUser =
                    { user | username = s }

                newModel =
                    { model | user = newUser }
            in
                ( newModel, Cmd.none )

        SetRegisterRealName s ->
            let
                user =
                    model.user

                newUser =
                    { user | realname = s }

                newModel =
                    { model | user = newUser }
            in
                ( newModel, Cmd.none )

        SetRegisterEmail s ->
            let
                user =
                    model.user

                newUser =
                    { user | email = s }

                newModel =
                    { model | user = newUser }
            in
                ( newModel, Cmd.none )

        SetRegisterDescription description ->
            let
              user = model.user
              newUser = { user | description = description }
              newModel = { model | user = newUser }

            in
              ( newModel, Cmd.none )


        GetCSRFToken token ->
          ( { model | csrf_token = token }, Cmd.none )

        GetUser user ->
            let
                newModel =
                    { model | user = user }

            in
                ( newModel, Cmd.none )



-- HELPERS


loginEncoder : Models.User -> Encode.Value
loginEncoder user =
  Encode.object
    [ ( "username", Encode.string user.username )
    , ( "password", Encode.string user.password )
    ]


userDecoder : Decoder Models.User
userDecoder =
    Decode.map8 Models.User
        (field "username" Decode.string)
        (field "realname" Decode.string)
        (field "register-password" Decode.string)
        (field "password_confirmation" Decode.string)
        (field "email" Decode.string)
        (field "description" Decode.string)
        (field "error_msg" Decode.string)
        (field "token" Decode.string)


authUser : Model -> String -> Http.Request Models.User
authUser model apiUrl =
    Http.request
      { method = "POST"
      , headers = [ Http.header "X-Csrf-Token" model.csrf_token ]
      , url = apiUrl
      , body = (model.user |> loginEncoder |> Http.jsonBody)
      , expect = Http.expectJson userDecoder
      , timeout = Nothing
      , withCredentials = True
      }

loginUrl : String
loginUrl =
    "login"


authUserCmd : Model -> String -> Cmd Msg
authUserCmd model apiUrl =
  Http.send AuthUserCompleted (authUser model apiUrl)


getUserCompleted : Model -> Result Http.Error Models.User -> ( Model, Cmd Msg )
getUserCompleted model result =
    case result of
        Ok newUser ->
            let
                newModel =
                    { model | user = newUser }
            in
                ( newModel, Cmd.none )

        Err error ->
            let
                user =
                    model.user

                newUser =
                    { user | error_msg = (toString error) }

                newModel =
                    { model | user = newUser }
            in
                ( newModel, Cmd.none )


tokenDecoder : Decoder String
tokenDecoder =
    Decode.field "access_token" Decode.string



-- VIEW


view : Model -> Html Msg
view model =
    div
        [ id "readings"
        , attribute "data-psalms" model.reading.ps
        , attribute "data-psalms_ver" model.reading.ps_ver
        , attribute "data-reading1" model.reading.reading1
        , attribute "data-reading1_ver" model.reading.reading1_ver
        , attribute "data-reading2" model.reading.reading2
        , attribute "data-reading2_ver" model.reading.reading2_ver
        , attribute "data-reading3" model.reading.reading3
        , attribute "data-reading3_ver" model.reading.reading3_ver
        , attribute "data-reading_date" model.reading.reading_date
        ]
        [ ul [ id "header-options" ]
            [ li [ class "option-item" ] [ calendar model ]
            , li [ class "option-item" ] [ offices model ]
            , li [ class "option-item" ] [ resources model ]
            , li [ class "option-item" ] [ stations model ]
            , li [ class "option-item" ] [ configModal model ]
            , li [ class "option-item" ] [ translations model ]
            , li [ class "option-item" ] [ aboutOptions model ]
            , li [ class "font-sizer"  ] [ fontSizer model ]
            ]
        ]



-- HELPERS


userLogin : Model -> Html Msg
userLogin model =
    let
        these_options =
            if model.user.token |> String.isEmpty then
                [ li [ class "pure-menu-item" ] [ login model.user ]
                , li [ class "pure-menu-item" ] [ register model.user ]
                ]
            else
                [ li [ class "pure-menu-item" ] [ text model.user.username ]
                , li [ class "pure-menu-item" ]
                    [ a [ href "/logout", onClick Logout ]
                        [ button [] [ text "Logout" ] ]
                    ]
                ]
    in
        div
            [ class "pure-menu pure-menu-horizontal login" ]
            [ ul [ class "pure-menu-list" ] these_options ]


calendar : Model -> Html Msg
calendar model =
    a [ href "/calendar" ]
        [ button [] [ text "Calendar" ] ]


stations : Model -> Html Msg
stations model =
    a [ href "/stations" ]
        [ button [] [ text "Stations" ] ]


offices : Model -> Html Msg
offices model =
    div
        [ class "offices" ]
        [ button [ class "button" ] [ text "Offices" ]
        , ul
            [ class "offices-options" ]
            [ li [ class "offices-item" ] [ currentOffice model ]
            , li [ class "offices-item" ] [ morning model ]
            , li [ class "offices-item" ] [ midday model ]
            , li [ class "offices-item" ] [ evening model ]
            , li [ class "offices-item" ] [ compline model ]
            , li [ class "offices-item" ] [ family model ]
            , li [ class "offices-item" ] [ reconciliation model ]
            , li [ class "offices-item" ] [ tothesick model ]
            , li [ class "offices-item" ] [ communiontosick model ]
            , li [ class "offices-item" ] [ timeofdeath model ]
            ]
        ]


resources : Model -> Html Msg
resources model =
    div
        [ class "offices" ]
        [ button [ class "button" ] [ text "Resources" ]
        , ul
            [ class "offices-options" ]
            [ li [ class "offices-item" ] [ printresources model ]
            , li [ class "offices-item" ] [ linkResource model ]
            , li [ class "offices-item" ] [ inserts model ]
            , li [ class "offices-item" ] [ humor model ]
            ]
        ]


aboutOptions : Model -> Html Msg
aboutOptions model =
    div
        [ class "offices" ]
        [ button [ class "button" ] [ text "About" ]
        , ul
            [ class "offices-options" ]
            [ li [ class "offices-item" ] [ aboutModal ]
            , li [ class "offices-item" ] [ emailMe model ]
            , li [ class "offices-item" ] [ howToModal ]
            ]
        ]


currentOffice : Model -> Html Msg
currentOffice model =
    a [ href "/office" ]
        [ button [] [ text "Current Office" ] ]


morning : Model -> Html Msg
morning model =
    a [ href "/morningPrayer" ]
        [ button [] [ text "Morning Prayer" ] ]


midday : Model -> Html Msg
midday model =
    a [ href "/midday" ]
        [ button [] [ text "Midday Prayer" ] ]


evening : Model -> Html Msg
evening model =
    a [ href "/ep" ]
        [ button [] [ text "Evening Prayer" ] ]


compline : Model -> Html Msg
compline model =
    a [ href "/compline" ]
        [ button [] [ text "Compline" ] ]


family : Model -> Html Msg
family model =
    a [ href "/family" ]
        [ button [] [ text "Family Prayer" ] ]


reconciliation : Model -> Html Msg
reconciliation model =
    a [ href "/reconciliation" ]
        [ button [] [ text "Reconciliation" ] ]


tothesick : Model -> Html Msg
tothesick model =
    a [ href "/tothesick" ]
        [ button [] [ text "To The Sick" ] ]


communiontosick : Model -> Html Msg
communiontosick model =
    a [ href "/communiontosick" ]
        [ button [] [ text "Communion to Sick" ] ]


timeofdeath : Model -> Html Msg
timeofdeath model =
    a [ href "/timeofdeath" ]
        [ button [] [ text "Time of Death" ] ]


printresources : Model -> Html Msg
printresources model =
    a [ href "/printresources" ]
        [ button [] [ text "Print Resources" ] ]


inserts : Model -> Html Msg
inserts model =
    a [ href "/inserts" ]
        [ button [] [ text "Bulletin Inserts" ] ]


linkResource : Model -> Html Msg
linkResource model =
    a [ href "/linkresources" ]
        [ button [] [ text "Link Resources" ] ]


humor : Model -> Html Msg
humor model =
    a [ href "/humor" ]
        [ button [] [ text "Humor" ] ]


translations : Model -> Html Msg
translations model =
    a [ href "/versions" ]
        [ button [] [ text "Translations" ] ]


emailMe : Model -> Html Msg
emailMe model =
    span []
        [ a [ href "#email-create" ] [ button [] [ text "Contact" ] ]
        , div
            [ id "email-create", class "emailModalDialog" ]
            [ div []
                [ a [ href "#closeemail-create", title "Close", class "close" ] [ text "X" ]
                , h2 [ class "modal_header" ] [ text "Contact" ]
                , (inputEmailAddress model.email)
                , (inputSubject model.email)
                , (inputMessage model.email)
                , a [ href "#closeemail-create", title "Send" ]
                    [ button [ class "email-button", onClick Send ] [ text "Send" ] ]
                , button [ class "email-button", onClick Clear ] [ text "Clear Message" ]
                , a [ href "#closeemail-create", title "Cancel" ]
                    [ button [ class "email-button", onClick Cancel ] [ text "Cancel" ] ]
                ]
            ]
        ]


configModal : Model -> Html Msg
configModal model =
    span []
        [ a [ href "#config-text" ] [ button [] [ text "Config" ] ]
        , div
            [ id "config-text", class "configModalDialog" ]
            [ div []
                [ a [ href "#closeconfig-text", title "Close", class "close" ] [ text "X" ]
                , h2 [ class "modal_header" ] [ text "Config" ]
                , Html.map ModConfig (Config.view model.config)

                --, (Config.view (Signal.forwardTo (ModConfig model.config)) model.config)
                ]
            ]
        ]


aboutModal : Html Msg
aboutModal =
    span []
        [ a [ href "#about-text" ] [ button [] [ text "About" ] ]
        , div
            [ id "about-text", class "modalDialog" ]
            [ div []
                [ a [ href "#closeabout-text", title "Close", class "close" ] [ text "X" ]
                , h2 [ class "modal_header" ] [ text "About" ]
                , p [ class "bulk-text" ] [ Markdown.toHtml [] about ]
                ]
            ]
        ]


howToModal : Html Msg
howToModal =
    span []
        [ a [ href "#howTo-text" ]
            [ button [] [ text "How to Use" ] ]
        , div
            [ id "howTo-text", class "modalDialog" ]
            [ div []
                [ a [ href "#closehowTo-text", title "Close", class "close" ] [ text "X" ]
                , h2 [ class "modal_header" ] [ text "How to Use" ]
                , p [ class "bulk-text" ] [ Markdown.toHtml [] howToUse ]
                ]
            ]
        ]


login : Models.User -> Html Msg
login user =
    span []
        [ a [ href "#login-text" ] [ button [] [ text "Login" ] ]
        , div
            [ id "login-text", class "loginModalDialog" ]
            [ div []
                [ a [ href "#closelogin-text", title "Close", class "close" ] [ text "X" ]
                , h2 [ class "modal_header" ] [ text "Login" ]
                , (registerUserName user)
                , (registerPassword user)
                , p [ class "login-error" ] [ text user.error_msg ]

                -- , Html.map ModLogin (Login.view user)
                , p [ class "login-error" ] [text ("User: " ++ user.username)]
                ]
            ]
        ]


register : Models.User -> Html Msg
register user =
    span []
        [ a [ href "#register-text" ] [ button [] [ text "Register" ] ]
        , div
            [ id "register-text", class "registerModalDialog" ]
            [ div []
                [ a [ href "#closeregister-text", title "Close", class "close" ] [ text "X" ]
                , h2 [ class "modal_header" ] [ text "Register" ]
                , Html.map ModRegister (Login.view user)
                , (registerUserName user)
                , (registerRealName user)
                , (registerEmailAddress user)
                , (registerDescription user)
                , (registerPassword user)
                , (registerPasswordConfirmation user)

                --, (Config.view (Signal.forwardTo (ModConfig model.config)) model.config)
                ]
            ]
        ]


inputEmailAddress : Models.Email -> Html Msg
inputEmailAddress model =
    p []
        [ input
            [ id "from"
            , class "email-addr"
            , name "from"
            , type_ "text"
            , placeholder "Your Email Address - required"
            , Html.Attributes.value model.from
            , onInput EmailAddress
            , autofocus True
            ]
            []
        ]


inputSubject : Models.Email -> Html Msg
inputSubject model =
    p []
        [ input
            [ id "topic"
            , class "email-subject"
            , name "topic"
            , type_ "text"
            , placeholder "Subject - required"
            , Html.Attributes.value model.topic
            , onInput Topic
            , autofocus True
            ]
            []
        ]


inputMessage : Models.Email -> Html Msg
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


fontSizer : Model -> Html Msg
fontSizer model =
  ul [ id "font-sizer-id"]
    [ li [] [ button [ onClick (ModFontSize "f") ] [ text "f" ] ]
    , li [] [ button [ onClick (ModFontSize "F") ] [ text "F" ] ]
    ]



registerUserName : Models.User -> Html Msg
registerUserName user =
    p []
        [ input
            [ id "username"
            , type_ "text"
            , placeholder "User ID"
            , autofocus True
            , name "username"
            , onInput SetRegisterUserName
            , onWithOptions "click"
                { stopPropagation = True, preventDefault = True }
                (Decode.succeed NoOp)
            , Html.Attributes.value user.username
            , class "user-username"
            ]
            []
        ]


registerRealName : Models.User -> Html Msg
registerRealName user =
    p []
        [ input
            [ id "realname"
            , type_ "text"
            , placeholder "Your Real Name"
            , autofocus True
            , name "realname"
            , onInput SetRegisterRealName
            , onWithOptions "click"
                { stopPropagation = True, preventDefault = True }
                (Decode.succeed NoOp)
            , Html.Attributes.value user.realname
            , class "user-realname"
            ]
            []
        ]


registerPassword : Models.User -> Html Msg
registerPassword user =
    p []
        [ input
            [ id "register-password"
            , type_ "password"
            , placeholder "Password"
            , autofocus True
            , name "register-password"
            , onInput SetRegisterPassword
            , onEnter Login
            , onWithOptions "click"
                { stopPropagation = True, preventDefault = True }
                (Decode.succeed NoOp)
            , Html.Attributes.value user.password
            , class "user-password"
            ]
            []
        ]


registerPasswordConfirmation : Models.User -> Html Msg
registerPasswordConfirmation user =
    p []
        [ input
            [ id "password_confirmation"
            , type_ "password"
            , placeholder "Confirm Password"
            , autofocus True
            , name "password_confirmation"
            , onInput SetRegisterPasswordConfirmation
            , onWithOptions "click"
                { stopPropagation = True, preventDefault = True }
                (Decode.succeed NoOp)
            , Html.Attributes.value user.password_confirmation
            , class "user-password"
            ]
            []
        ]


registerEmailAddress : Models.User -> Html Msg
registerEmailAddress user =
    p []
        [ input
            [ id "register_email"
            , type_ "text"
            , placeholder "Email Address"
            , autofocus True
            , name "register_email"
            , onInput SetRegisterEmail
            , onWithOptions "click"
                { stopPropagation = True, preventDefault = True }
                (Decode.succeed NoOp)
            , Html.Attributes.value user.email
            , class "user-email"
            ]
            []
        ]


registerDescription : Models.User -> Html Msg
registerDescription user =
    p []
        [ textarea
            [ id "register_description"
            , class "user-desciption"
            , name "register_description"
            , placeholder "Tell us about yourself - required"
            , Html.Attributes.value user.description
            , onInput SetRegisterDescription
            , autofocus True
            ]
            []
        ]


onEnter : Msg -> Attribute Msg
onEnter msg =
    let
        tagger code =
            if code == 13 then
                msg
            else
                NoOp
    in
        on "keydown" (Decode.map tagger keyCode)

howToUse : String
howToUse =
    """

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

about : String
about =
    """
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


buttonStyle : Attribute msg
buttonStyle =
    style
        [ ( "position", "relative" )
        , ( "float", "left" )
        , ( "padding", "2px 2px" )
        , ( "font-size", "0.8em" )
        , ( "display", "inline-block" )
        ]


aboutButtonStyle : Attribute msg
aboutButtonStyle =
    style
        [ ( "position", "relative" )
        , ( "float", "right" )
        , ( "padding", "2px 2px" )
        , ( "font-size", "0.8em" )
        , ( "display", "inline-block" )
        ]
