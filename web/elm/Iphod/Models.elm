module Iphod.Models exposing
  ( Config, Lesson, Sunday, Daily, Day
  , Email, Collect, SundayCollect, Proper
  , DailyMP, DailyEP
  , configInit, sundayInit, dailyInit
  , emailInit, initCollect, initSundayCollect
  , initProper, initDay
  , initDailyMP, initDailyEP
  ) 

type alias Config =
  { ot: String
  , ps: String
  , nt: String
  , gs: String
  , fnotes: String
  , vers: List String
  , current: String
  }

configInit: Config
configInit =
  { ot = "ESV"
  , ps = "Coverdale"
  , nt = "ESV"
  , gs = "ESV"
  , fnotes = "True"
  , vers = []
  , current = "ESV"
  }

type alias Email =
  { from: String
  , topic: String
  , text:  String
  }

emailInit: Email
emailInit = 
  { from = ""
  , topic = ""
  , text = ""
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

type alias Proper = 
  { title:  String
  , text:   String
  }

initProper: Proper
initProper =
  { title = ""
  , text =  ""
  }

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
  , colors:   List String
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
  , colors  = []
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

-- type alias DailyEU = Sunday
-- 
-- initDailyEU: DailyEU
-- initDailyEU = sundayInit



type alias DailyMP =
  { colors: List String
  , date:   String
  , day:    String
  , season: String
  , title:  String
  , week:   String
  , mp1:    List Lesson
  , mp2:    List Lesson
  , mpp:    List Lesson
  , config: Config
  , show:   Bool
  }

initDailyMP: DailyMP
initDailyMP =
  { colors  = []
  , date    = ""
  , day     = ""
  , season  = ""
  , title   = ""
  , week    = ""
  , mp1     = []
  , mp2     = []
  , mpp     = []
  , config  = configInit
  , show    = False
  }

type alias DailyEP =
  { colors: List String
  , date:   String
  , day:    String
  , season: String
  , title:  String
  , week:   String
  , ep1:    List Lesson
  , ep2:    List Lesson
  , epp:    List Lesson
  , config: Config
  , show:   Bool
  }

initDailyEP: DailyEP
initDailyEP =
  { colors  = []
  , date    = ""
  , day     = ""
  , season  = ""
  , title   = ""
  , week    = ""
  , ep1     = []
  , ep2     = []
  , epp     = []
  , config  = configInit
  , show    = False
  }

type alias ESV =
  { url: String
  , key: String
  , foot_notes: Bool
  }

initESV: ESV
initESV =
  { url = "www.esvapi.org/v2/rest/passageQuery?"
  , key = "10b28dac7c57fd96"
  , foot_notes = True
  }


type alias BiblesOrg =
  { url: String
  , key: String
  , foot_notes: Bool
  }

initBiblesOrg: BiblesOrg
initBiblesOrg =
  { url = "https://bibles.org/v2/passages.js?q[]="
  , key = "P7jpdltnMhHJYUlx8TZEiwvJHDvSrZ96UCV522kT"
  , foot_notes = True
  }

type alias Day =
  { name:       String
  , colors:     List String
  , dayOfMonth: String
  , date:       String
  , daily:      Daily
  , sunday:     Sunday
  , today:      Bool
  }

initDay: Day
initDay =
  { name  =       ""
  , colors =      []
  , dayOfMonth =  ""
  , date  =       ""
  , daily =       dailyInit
  , sunday =      sundayInit
  , today =       False
  }
