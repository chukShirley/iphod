module Iphod.Models exposing
  ( Config, Lesson, Sunday, Daily, Day
  , Shout, initShout
  , Email, Collect, SundayCollect, Proper
  , DailyMP, DailyEP, Reflection
  , configInit, initLesson, sundayInit, initDaily
  , emailInit, initCollect, initSundayCollect
  , initProper, initDay
  , initDailyMP, initDailyEP, initReflection
  ) 

type alias Note =
  { reading: String
  , text: String
  , time: String  -- i'm thinking seconds in epoc
  }
initNote: Note
initNote =
  { reading = ""
  , text = ""
  , time = ""
  }

type alias Shout =
  { section: String
  , text: String
  , time: String
  , user: String
  , showChat: Bool
  , chat:     List String
  , comment:  String
  }

initShout: Shout
initShout =
  { section = ""
  , text = ""
  , time = ""
  , user = ""
  , showChat = False
  , chat = []
  , comment = ""
  }

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
  , vers = ["ESV"]
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
  , altRead:  String
  , notes: List Note
  , cmd:      String
  }

initLesson: Lesson
initLesson =
  { style =   ""
  , show =    False
  , read =    ""
  , body =    ""
  , id =      ""
  , section = ""
  , version = ""
  , altRead = ""
  , notes = []
  , cmd = ""
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
  , show = True
  }

type alias Sunday =
  { ofType:   String
  , date:     String
  , season:   String
  , week:     String
  , title:    String
  , show:     Bool
  , config:   Config
  , colors:   List String
  , collect:  SundayCollect
  , ot:       List Lesson
  , ps:       List Lesson
  , nt:       List Lesson
  , gs:       List Lesson
}

sundayInit: Sunday
sundayInit =
  { ofType  = ""
  , date    = ""
  , season  = ""
  , week    = ""
  , title   = ""
  , show    = False
  , config  = configInit
  , colors  = []
  , collect = initSundayCollect
  , ot      = []
  , ps      = []
  , nt      = []
  , gs      = []
  }

type alias Daily =
  { date:     String  -- "Thursday March 31, 2016"
  , title:    String
  , collect:  SundayCollect
  , mp1: List String
  , mp2: List String
  , mpp: List String
  , ep1: List String
  , ep2: List String
  , epp: List String
  , ot: List String
  , ps: List String
  , nt: List String
  , gs: List String
  , show:     Bool
  }

initDaily: Daily
initDaily =
  { date      = ""
  , title     = ""
  , collect = initSundayCollect
  , mp1  = []
  , mp2  = []
  , mpp  = []
  , ep1  = []
  , ep2  = []
  , epp  = []
  , ot   = []
  , ps   = []
  , nt   = []
  , gs   = []
  , show = False
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
  , config: Config
  , show:   Bool
  , collect:  SundayCollect
  , mp1:    List Lesson
  , mp2:    List Lesson
  , mpp:    List Lesson
  }

initDailyMP: DailyMP
initDailyMP =
  { colors  = []
  , date    = ""
  , day     = ""
  , season  = ""
  , title   = ""
  , week    = ""
  , config  = configInit
  , show    = False
  , collect = initSundayCollect
  , mp1     = []
  , mp2     = []
  , mpp     = []
  }

type alias DailyEP =
  { colors: List String
  , date:   String
  , day:    String
  , season: String
  , title:  String
  , week:   String
  , config: Config
  , show:   Bool
  , collect:  SundayCollect
  , ep1:    List Lesson
  , ep2:    List Lesson
  , epp:    List Lesson
  }

initDailyEP: DailyEP
initDailyEP =
  { colors  = []
  , date    = ""
  , day     = ""
  , season  = ""
  , title   = ""
  , week    = ""
  , config  = configInit
  , show    = False
  , collect = initSundayCollect
  , ep1     = []
  , ep2     = []
  , epp     = []
  }

type alias Reflection =
  { author:   String
  , markdown: String
  }

initReflection =
  { author    = ""
  , markdown  = ""
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
  , daily =       initDaily
  , sunday =      sundayInit
  , today =       False
  }
