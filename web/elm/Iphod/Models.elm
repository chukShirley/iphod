module Iphod.Models (Lesson, Sunday, Daily, sundayInit, dailyInit) where

type alias Lesson =
  { style:    String
  , show:     Bool
  , read:     String
  , body:     String
  , id:       String
  , section:  String
  }

type alias Sunday =
  { ofType:   String
  , date:     String
  , season:   String
  , week:     String
  , title:    String
  , ot:       List Lesson
  , ps:       List Lesson
  , nt:       List Lesson
  , gs:       List Lesson
  , show:     Bool
}

sundayInit: Sunday
sundayInit =
  { ofType  = ""
  , date    = ""
  , season  = ""
  , week    = ""
  , title   = ""
  , ot      = []
  , ps      = []
  , nt      = []
  , gs      = []
  , show    = False
  }

type alias Daily =
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

dailyInit: Daily
dailyInit =
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
