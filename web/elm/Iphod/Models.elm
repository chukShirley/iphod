module Iphod.Models (Lesson, Sunday, Daily, sundayInit, dailyInit) where

type alias Lesson =
  { style:    String
  , show:     Bool
  , read:     String
  , body:     String
  , id:       String
  , section:  String
  , version:  String
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
  { date:     String  -- "Thursday March 31, 2016"
  , season:   String  -- e.g. "easter"
  , week:     String  -- e.g. "2"
  , day:      String  -- e.g. "Thursday"
  , title:    String
  , mp1: List Lesson
  , mp2: List Lesson
  , mpp: List Lesson
  , ep1: List Lesson
  , ep2: List Lesson
  , epp: List Lesson
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
  , mpp  = []
  , ep1  = []
  , ep2  = []
  , epp  = []
  , show      = False
  , justToday = False
  }
