module Iphod.Models ( Config, Lesson, Sunday, Daily, 
                      Email, Collect, SundayCollect,
                      configInit, sundayInit, dailyInit,
                      emailInit, initCollect, initSundayCollect
                    ) where

type alias Config =
  { ot: String
  , ps: String
  , nt: String
  , gs: String
  , fnotes: String
  }

configInit: Config
configInit =
  { ot = "ESV"
  , ps = "Coverdale"
  , nt = "ESV"
  , gs = "ESV"
  , fnotes = "fnotes"
  }

type alias Email =
  { addr: String
  , subj: String
  , msg:  String
  , show: Bool
  }

emailInit: Email
emailInit = 
  { addr = ""
  , subj = ""
  , msg = ""
  , show = False
  }

type alias Lesson =
  { style:    String
  , show:     Bool
  , read:     String
  , body:     String
  , id:       String
  , section:  String
  , version:  String
  }

type alias Proper = String
type alias Collect =
  { collect: String
  , propers: List Proper
  }

initCollect: Collect
initCollect =
  { collect = ""
  , propers = []
  } 

type alias SundayCollect =
  { instruction: String
  , title: String
  , collects: List Collect
  , show: Bool
  }

initSundayCollect: SundayCollect
initSundayCollect =
  { instruction = ""
  , title = ""
  , collects = []
  , show = False
  }

type alias Sunday =
  { ofType:   String
  , date:     String
  , season:   String
  , week:     String
  , title:    String
  , collect:  SundayCollect
  , ot:       List Lesson
  , ps:       List Lesson
  , nt:       List Lesson
  , gs:       List Lesson
  , show:     Bool
  , config:   Config
}

sundayInit: Sunday
sundayInit =
  { ofType  = ""
  , date    = ""
  , season  = ""
  , week    = ""
  , title   = ""
  , collect = initSundayCollect
  , ot      = []
  , ps      = []
  , nt      = []
  , gs      = []
  , show    = False
  , config  = configInit
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
  , config:   Config
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
  , config    = configInit
  }
