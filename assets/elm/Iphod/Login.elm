module Iphod.Login exposing (Model, init, Msg, update, view)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Json.Decode as Decode exposing (..)
import Iphod.Models exposing (User, userInit)


-- MODEL


type alias Model =
    User


init : Model
init =
    userInit



-- UPDATE


type Msg
    = NoOp
    | SetUserName String
    | SetPassword String



--  | AuthError Http.Error
--  | ClickRegisterUser
--  | GetTokenSuccess String


update : Msg -> Model -> Model
update msg model =
    case msg of
        NoOp ->
            model

        SetUserName s ->
            { model | username = s }

        SetPassword s ->
            { model | password = s }



--    AuthError error ->
--      ( { model | error_msg = (toString error) })
--
--    GetTokenSuccess newToken ->
--      ( { model | token = newToken, password = "", error_msg = ""} |> Debug.log "got new token")
--
-- VIEW


view : Model -> Html Msg
view model =
    (loginModal model)


loginModal : Model -> Html Msg
loginModal model =
    div [ id "user-login", class "modalDialog" ]
        [ a [ href "#closeemail-text", title "Close", class "close" ] [ text "X" ]
        , h2 [ class "modal_header" ] [ text "Login" ]
        , (inputUserName model)
        , (inputPassword model)
        ]


inputUserName : Model -> Html Msg
inputUserName model =
    p []
        [ input
            [ id "username"
            , type_ "text"
            , placeholder "User ID"
            , autofocus True
            , name "username"
            , onInput SetUserName

            -- , onClickLimited NoOp
            , onWithOptions "click"
                { stopPropagation = True, preventDefault = True }
                (Decode.succeed NoOp)
            , Html.Attributes.value model.username
            , class "user-username"
            ]
            []
        ]


inputPassword : Model -> Html Msg
inputPassword model =
    p []
        [ input
            [ id "password"
            , type_ "password"
            , placeholder "Password"
            , autofocus True
            , name "password"
            , onInput SetPassword

            -- , onClickLimited NoOp
            , onWithOptions "click"
                { stopPropagation = True, preventDefault = True }
                (Decode.succeed NoOp)
            , Html.Attributes.value model.password
            , class "user-password"
            ]
            []
        ]



-- HELPERS
