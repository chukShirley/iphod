module Iphod.Models
    exposing
        ( Resource, initResource
        , Config, configInit
        , Lesson, initLesson
        , LessonRequest, initLessonRequest, setLessonRequestSource, newLessonRequest
        , Psalm, initPsalm
        , DailyPsalms, initDailyPsalms
        , Sunday, sundayInit
        , Daily, initDaily
        , Day, initDay
        , Week, initWeek
        , Month, initMonth
        , Shout, initShout
        , Email, emailInit
        , User, userInit
        , Collect, initCollect
        , SundayCollect, initSundayCollect
        , Proper, initProper
        , Reflection, initReflection
        , Leaflet, initLeaflet
        , ESV, initESV
        , ESVresp, initESVresp
        , ESVparsed, initESVparsed
        , ESVmeta, initESVmeta
        )

-- type alias Reader = 
--     { name: String
--     , ref: String -- what they are to read
--     }
-- 
-- type alias Rota = 
--     { church: String
--     , time: String
--     , location: String
--     , service: String
--     , color: String
--     , vestments: String
--     , celebrant: List String
--     , preacher: String
--     , deacon:   List String
--     , readers: List Reader
--     , pop: String 
--     , lem: List String
--     , acolyte: List String
--     , crucifer: List String
--     , thurifer: List String
--     , altarGuild: List String
--     , coffee: List String
--     , music: List String
--     }

type alias Resource =
    { id : String
    , url : String
    , name : String
    , of_type : String
    , keys : String
    , description : String
    , show : Bool
    }


initResource : Resource
initResource =
    { id = ""
    , url = ""
    , name = ""
    , of_type = ""
    , keys = ""
    , description = ""
    , show = True
    }


type alias Note =
    { reading : String
    , text : String
    , time : String -- i'm thinking seconds in epoc
    }


initNote : Note
initNote =
    { reading = ""
    , text = ""
    , time = ""
    }


type alias Shout =
    { section : String
    , text : String
    , time : String
    , user : String
    , showChat : Bool
    , chat : List String
    , comment : String
    }


initShout : Shout
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
    { ot : String
    , ps : String
    , nt : String
    , gs : String
    , fnotes : String
    , vers : List String
    , current : String
    }


configInit : Config
configInit =
    { ot = "ESV"
    , ps = "Coverdale"
    , nt = "ESV"
    , gs = "ESV"
    , fnotes = "True"
    , vers = [ "ESV" ]
    , current = "ESV"
    }


type alias Email =
    { from : String
    , topic : String
    , text : String
    }


emailInit : Email
emailInit =
    { from = ""
    , topic = ""
    , text = ""
    }


type alias User =
    { username : String
    , realname : String
    , email : String
    , description : String
    , error_msg : String
    , token : String
    , password : String
    , password_confirmation : String
    }


userInit : User
userInit =
    { username = ""
    , realname = ""
    , email = ""
    , description = ""
    , error_msg = ""
    , token = ""
    , password = ""
    , password_confirmation = ""
    }


type alias Lesson =
    { style : String
    , read : String
    }


initLesson : Lesson
initLesson =
    { style = ""
    , read = ""
    }

type alias LessonRequest = 
    { lesson : Int
    , ref : String
    , style : String
    , src : String
    , text : String
    }

initLessonRequest : LessonRequest
initLessonRequest =
    { lesson = 0
    , ref = ""
    , style = ""
    , src = ""
    , text = ""
    }

newLessonRequest : Int -> String -> String -> String -> String -> LessonRequest
newLessonRequest lesson ref style src text =
    { lesson = lesson
    , ref = ref
    , style = style
    , src = src
    , text = text
    }


setLessonRequestSource : String -> LessonRequest -> LessonRequest
setLessonRequestSource src lesson = {lesson | src = src}

type alias PsVs =
    { first: String
    , second: String
    }
initPsVs: PsVs
initPsVs =
    { first = ""
    , second = ""
    }

type alias Psalm =
    { name: String
    , title: String
    , style: String
    , vss: List PsVs
    }
initPsalm: Psalm
initPsalm =
    { name = ""
    , title = ""
    , style = ""
    , vss = []
    }

type alias DailyPsalms =
    { mp: List Lesson 
    , ep: List Lesson
    }
initDailyPsalms : DailyPsalms
initDailyPsalms = 
    { mp = [] 
    , ep = []
    }


type alias Proper =
    { title : String
    , text : String
    }


initProper : Proper
initProper =
    { title = ""
    , text = ""
    }


type alias Collect =
    { collect : String
    , propers : List Proper
    }


initCollect : Collect
initCollect =
    { collect = ""
    , propers = []
    }


type alias SundayCollect =
    { instruction : String
    , title : String
    , collects : List Collect
    , show : Bool
    }


initSundayCollect : SundayCollect
initSundayCollect =
    { instruction = ""
    , title = ""
    , collects = []
    , show = True
    }

type alias Sunday =
    { title : String
    , show : Bool
    , colors : List String
    , ot : List Lesson
    , ps : List Lesson
    , nt : List Lesson
    , gs : List Lesson
    }

sundayInit : Sunday
sundayInit =
    { title = ""
    , show = False
    , colors = []
    , ot = []
    , ps = []
    , nt = []
    , gs = []
    }


type alias Daily =
    { title : String
    , mp1 : List Lesson
    , mp2 : List Lesson
    , ep1 : List Lesson
    , ep2 : List Lesson
    , show : Bool
    }

initDaily : Daily
initDaily =
    { title = ""
    , mp1 = []
    , mp2 = []
    , ep1 = []
    , ep2 = []
    , show = False
    }

type alias Day =
    {   eu: Sunday
    ,   daily: Daily
    ,   dailyPsalms: DailyPsalms
    ,   date: String
    ,   monthDay: String
    ,   season: String
    ,   week: String
    ,   colors: List String
    ,   rld: Bool
    ,   title: String
    -- ,   order: Int
    }

initDay =
    {   eu = sundayInit
    ,   daily = initDaily
    ,   dailyPsalms = []
    ,   date = ""
    ,   monthDay = 0
    ,   season = ""
    ,   week = ""
    ,   colors = []
    ,   rld = False
    ,   title = ""
    -- ,   order = 0
    }

type alias Week = {   days: List Day  }

initWeek = { days = []  }

type alias Month = {   weeks: List Week    }

initMonth = { weeks = [] }

type alias Reflection =
    { author : String
    , markdown : String
    }


initReflection =
    { author = ""
    , markdown = ""
    }


type alias ESV =
    { url : String
    , key : String
    , foot_notes : Bool
    }


initESV : ESV
initESV =
    { url = "https://api.esv.org/v3/passage/html/?q="
    , key = "Token 7d3151fe3a26566aac67ffce393604ac19ef1962"
    , foot_notes = True
    }

type alias ESVresp = 
    { query: String
    , canonical: String
    , parsed: List ESVparsed
    , passage_meta: List ESVmeta
    , passages: List String
    }
initESVresp : ESVresp
initESVresp = 
    { query = ""
    , canonical = ""
    , parsed = []
    , passage_meta = []
    , passages = []
    }

type alias ESVparsed = List Int
initESVparsed : ESVparsed
initESVparsed = [0,0]
    
type alias ESVmeta = 
    { canonical: String
    , chapter_start: ESVparsed
    , chapter_end: ESVparsed
    , prev_verse: Int
    , next_verse: Int
    , prev_chapter: ESVparsed
    , next_chapter: ESVparsed
    }
initESVmeta : ESVmeta
initESVmeta = 
    { canonical = ""
    , chapter_start = initESVparsed
    , chapter_end = initESVparsed
    , prev_verse = 0
    , next_verse = 0
    , prev_chapter = initESVparsed
    , next_chapter = initESVparsed
    }


type alias BiblesOrg =
    { url : String
    , key : String
    , foot_notes : Bool
    }


initBiblesOrg : BiblesOrg
initBiblesOrg =
    { url = "https://bibles.org/v2/passages.js?q[]="
    , key = "P7jpdltnMhHJYUlx8TZEiwvJHDvSrZ96UCV522kT"
    , foot_notes = True
    }

type alias Leaflet =
    { reg : String
    , largePrint : String
    }


initLeaflet =
    { reg = ""
    , largePrint = ""
    }
