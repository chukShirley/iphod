module Iphod.Daily (Model, Lesson, init) where

-- MODEL

-- type alias OfType = String -- req, opt, alt

type alias Lesson =
  { style:    String
  , show:     Bool
  , read:     String
  , body:     String
  , id:       String
  , section:  String
  }


type alias Model =
  { date:     String
  , season:   String
  , week:     String
  , day:      String
  , title:    String
  , mp1: List Lesson
  , mp2: List Lesson
  , ep1: List Lesson
  , ep2: List Lesson
  , show:     Bool
  , justToday: Bool
  }

init: Model
init =
  { date      = ""
  , season    = ""
  , week      = ""
  , day       = ""
  , title     = ""
  , mp1  = []
  , mp2  = []
  , ep1  = []
  , ep2  = []
  , show      = False
  , justToday = False
  }