port module Resources exposing (..) -- where

import Debug

import Html exposing (..)
import Html
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Regex exposing (regex, contains, caseInsensitive)
import Json.Decode as Json
import String exposing (slice, length)
import Markdown exposing (..)

import Iphod.Helper exposing (hideable)
import Iphod.Models as Models


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


type alias Model = List Models.Resource

init: (Model, Cmd Msg)
init = ([], Cmd.none)

port allResources: (Model -> msg) -> Sub msg

subscriptions: Model -> Sub Msg
subscriptions model =
  Sub.batch
  [ allResources AddModel ]

-- UPDATE

type Msg
  = NoOp
  | AddModel Model
  | Find String String
  | ResourceGet Models.Resource

update: Msg -> Model -> (Model, Cmd Msg)
update msg model =
  case msg of
    NoOp -> (model, Cmd.none)

    AddModel newModel ->
      let
        foo = Debug.log "Add Model" newModel
      in
        (newModel, Cmd.none)

    Find col name ->
      let
        foo = Debug.log "FIND" (col, name)
        findThis resc =
          case col of
            "name"  ->
              if contains( caseInsensitive(regex name) ) resc.name
                then {resc | show = True}
                else {resc | show = False}
            "description"    ->
              if contains( caseInsensitive(regex name) ) resc.description
                then {resc | show = True}
                else {resc | show = False}
            _         -> -- keys
              if contains( caseInsensitive(regex name) ) resc.keys
                then {resc | show = True}
                else {resc | show = False}

        -- newModel = List.map findThis model
      in
        (List.map findThis model, Cmd.none)

    ResourceGet resource ->
      (model, Cmd.none)

-- VIEW

view: Model -> Html Msg
view model =
  let
    this_resource resc =
      tr [ rowStyle resc ]
      [ td [class "tooltip"]
        [ span [ class "tooltiptext"] [ text resc.name ]
        , text (resc.name |> add_elipse 20)
        ]
      , td [class "tooltip"]
        [ span [ class "tooltiptext"] [ text resc.description ]
        , text (resc.description |> add_elipse 20)
        ]
      , td [class "tooltip"]
        [ span [ class "tooltiptext"] [ text resc.keys ]
        , text (resc.keys |> add_elipse 20)
        ]
      , td
        [ class "resource_get" ]
        [ getResource resc ]
      ]

  in
    div []
      [ h2 [] [text "Resources"]
      , table [class "resources"]
          [ thead []
              [ tr []
                  [ th [class "resource_name"] [text "Name"]
                  , th [class "resource_description"] [text "Description"]
                  , th [class "resource_keys"] [text "Keys"]
                  , th
                    [class "resource_get"] []
                  ]
              , tr []
                  [ findName
                  , findDescription
                  , findKeys
                  , td [] []
                  ]
              ]
          , tbody [] (List.map this_resource model)
          ]
      ]

-- HELPERS

getResource: Models.Resource -> Html Msg
getResource resource =
  case resource.of_type of
  "link"  ->
    a [ href resource.url, target "_blank"]
      [ button [] [ text (printOrLink resource) ]
      ]
  "print" ->
    a [ href ("/resources/send/" ++ resource.url), target "_blank"]
      [ button [] [ text (printOrLink resource) ]
      ]
  "insert" ->
    a [ href ("/resources/send/" ++ resource.url), target "_blank"]
      [ button [] [ text (printOrLink resource) ]
      ]
  _       ->
      span []
      [ a [ href "#humor-text" ] [ button [] [text "View"] ]
        , div
          [ id "humor-text", class "humorModalDialog" ]
          [ div []
              [ a [href "#closeconfig-text", title "Close", class "close"] [text "X"]
              , h2 [class "modal_header"] [ text "Get it?" ]
              , p [] [ text resource.name ]
              , p [] [ Markdown.toHtml [] resource.description ]
              ]
          ]
      ]

printOrLink: Models.Resource -> String
printOrLink resource =
  case resource.of_type of
    "link"   -> "New tab"
    "print"  -> "Download"
    "insert" -> "Download"
    _        -> "View"

add_elipse: Int -> String -> String
add_elipse n s =
  let
    new_s = if length s > n
      then
        (s |> slice 0 n) ++ " ..."
      else
        s
  in
    new_s

findName: Html Msg
findName =
  th [ class "th_finders" ]
    [ input
        [ id "find_name"
        , type_ "text"
        , placeholder "Resource Name"
        , autofocus True
        , name "find_name"
        , on "keyup" (Json.map (Find "name") targetValue)
        , onClick NoOp
        , style [("width", "90%")]
        ]
        []
    ]


findDescription: Html Msg
findDescription =
  th [ class "th_finders" ]
    [ input
        [ id "find_desc"
        , type_ "text"
        , placeholder "Description"
        , autofocus True
        , name "find_desc"
        , on "keyup" (Json.map (Find "description") targetValue)
        , onClick NoOp
        , style [("width", "90%")]
        ]
        []
    ]

findKeys: Html Msg
findKeys =
  th [ class "th_finders" ]
    [ input
        [ id "find_keys"
        , type_ "text"
        , placeholder "Key Words"
        , autofocus True
        , name "find_keys"
        , on "keyup" (Json.map (Find "keys") targetValue)
        , onClick NoOp
        , style [("width", "90%")]
        ]
        []
    ]



-- STYLE

rowStyle: Models.Resource -> Attribute msg
rowStyle model =
  hideable model.show []
