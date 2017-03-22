module Iphod.Login exposing 
  ( Model, init, Msg, update, view )

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import String exposing (join)
import Json.Decode as Decode exposing (..)
import Json.Encode as Encode exposing (..)

import Iphod.Helper exposing (hideable)
import Iphod.Models exposing (User, userInit)

-- MODEL

type alias Model = User

init: Model
init = userInit


-- UPDATE

type Msg
  = NoOp
  | SetUserName String
  | SetPassword String
--  | AuthError Http.Error
--  | ClickRegisterUser
--  | GetTokenSuccess String

update: Msg -> Model -> Model
update msg model =
  case msg of
    NoOp -> model
    SetUserName s -> {model | username = s}
    SetPassword s -> {model | password = s}

--    AuthError error ->
--      ( { model | error_msg = (toString error) })
--
--    GetTokenSuccess newToken ->
--      ( { model | token = newToken, password = "", error_msg = ""} |> Debug.log "got new token")
--

-- VIEW

view: Model -> Html Msg
view model =
  (loginModal model)

loginModal: Model -> Html Msg
loginModal model =
  div [ id "user-login", class "modalDialog" ]
    [ a [href "#closeemail-text", title "Close", class "close"] [text "X"] 
    , h2 [class "modal_header"] [ text "Login" ]
    , (inputUserName model)
    , (inputPassword model)
    ]


inputUserName: Model -> Html Msg
inputUserName model =
  p []
    [ input 
        [ id "username"
        , type' "text"
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

inputPassword: Model -> Html Msg
inputPassword model =
  p []
    [ input 
        [ id "password"
        , type' "password"
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

-- registerURL: String
-- registerURL = 
--   api ++ "users/new"
-- 
-- -- Encode user to construct POST  request body (for Register and Log in)
-- 
-- userEncoder: Model -> Encode.Value
-- userEncoder model = 
--   Encode.object
--     [ ("username", Encode.string model.username)
--     , ("realname", Encode.string model.realname)
--     , ("password", Encode.string model.password)
--     , ("password_confirmation", Encode.string model.password)
--     , ("description", Encode.string model.description)
--     ]
-- 
-- 
-- -- POST register / login request
-- 
-- authUser: Model -> String -> Task Http.Error String
-- authUser model apiUrl =
--   { verb = "POST"
--   , headers = [ ("Content-Type", "application/json") ]
--   , url = apiUrl
--   , body = Http.string <| Encode.encode 0 <| userEncoder model
--   }
--   |> Http.send Http.defaultSettings
--   |> Http.fromJson tokenDecoder
-- 
-- authUserCmd: Model -> String -> Cmd Msg
-- authUserCmd model apiUrl =
--   Task.perform AuthError GetTokenSuccess <| authUser mdoel apiUrl
-- 
-- tokenDecoder: Decoder String
-- tokenDecoder =
--   "id_token" := Decode.string
-- 





