module Iphod.Daily (Model, Lesson, init) where

-- MODEL

-- type alias OfType = String -- req, opt, alt

type alias Lesson =
  { style: String
  , show: Bool
  , read: String
  , text: String
  }


type alias Model =
  { date:     String
  , season:   String
  , week:     String
  , day:      String
  , title:    String
  , morning1: List Lesson
  , morning2: List Lesson
  , evening1: List Lesson
  , evening2: List Lesson
  , show: Bool
  , justToday: Bool
  }

init: Model
init =
  { date      = ""
  , season    = ""
  , week      = ""
  , day       = ""
  , title     = ""
  , morning1  = []
  , morning2  = []
  , evening1  = []
  , evening2  = []
  , show      = False
  , justToday = False
  }