module Iphod.Models
    exposing
        ( Resource
        , initResource
        , Config
        , configInit
        , Lesson
        , initLesson
        , Sunday
        , sundayInit
        , Daily
        , initDaily
        , Day
        , initDay
        , SectionUpdate
        , initSectionUpdate
        , setSectionUpdate
        , Shout
        , initShout
        , Email
        , emailInit
        , User
        , userInit
        , Collect
        , initCollect
        , SundayCollect
        , initSundayCollect
        , Proper
        , initProper
        , DailyMP
        , initDailyMP
        , DailyEP
        , initDailyEP
        , Reflection
        , initReflection
        , CurrentReadings
        , currentReadingsInit
        , Leaflet
        , initLeaflet
        )


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
    , fontSize : String
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
    , fontSize = "0.8"
    }


type alias CurrentReadings =
    { ps : String
    , ps_ver : String
    , reading1 : String
    , reading1_ver : String
    , reading2 : String
    , reading2_ver : String
    , reading3 : String
    , reading3_ver : String
    , reading_date : String
    }


currentReadingsInit : CurrentReadings
currentReadingsInit =
    { ps = ""
    , ps_ver = ""
    , reading1 = ""
    , reading1_ver = ""
    , reading2 = ""
    , reading2_ver = ""
    , reading3 = ""
    , reading3_ver = ""
    , reading_date = ""
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
    , show : Bool
    , show_fn : Bool -- show footnotes
    , show_vn : Bool -- show verse numbers
    , read : String
    , body : String
    , id : String
    , section : String
    , version : String
    , altRead : String
    , notes : List Note
    , cmd : String
    }


initLesson : Lesson
initLesson =
    { style = ""
    , show = False
    , show_fn = True
    , show_vn = True
    , read = ""
    , body = ""
    , id = ""
    , section = ""
    , version = ""
    , altRead = ""
    , notes = []
    , cmd = ""
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


type alias SectionUpdate =
    { section : String
    , version : String
    , ref : String
    }


initSectionUpdate : SectionUpdate
initSectionUpdate =
    { section = ""
    , version = ""
    , ref = ""
    }


setSectionUpdate : String -> String -> String -> SectionUpdate
setSectionUpdate this_section this_version thisRef =
    { section = this_section
    , version = this_version
    , ref = thisRef
    }


type alias Sunday =
    { ofType : String
    , date : String
    , season : String
    , week : String
    , title : String
    , show : Bool
    , config : Config
    , colors : List String
    , collect : SundayCollect
    , ot : List Lesson
    , ps : List Lesson
    , nt : List Lesson
    , gs : List Lesson
    , sectionUpdate : SectionUpdate
    }


sundayInit : Sunday
sundayInit =
    { ofType = ""
    , date = ""
    , season = ""
    , week = ""
    , title = ""
    , show = False
    , config = configInit
    , colors = []
    , collect = initSundayCollect
    , ot = []
    , ps = []
    , nt = []
    , gs = []
    , sectionUpdate = initSectionUpdate
    }


type alias Daily =
    { date : String -- "Thursday March 31, 2016"
    , title : String
    , collect : SundayCollect
    , mp1 : List String
    , mp2 : List String
    , mpp : List String
    , ep1 : List String
    , ep2 : List String
    , epp : List String
    , ot : List String
    , ps : List String
    , nt : List String
    , gs : List String
    , show : Bool
    , sectionUpdate : SectionUpdate
    }


initDaily : Daily
initDaily =
    { date = ""
    , title = ""
    , collect = initSundayCollect
    , mp1 = []
    , mp2 = []
    , mpp = []
    , ep1 = []
    , ep2 = []
    , epp = []
    , ot = []
    , ps = []
    , nt = []
    , gs = []
    , show = False
    , sectionUpdate = initSectionUpdate
    }



-- type alias DailyEU = Sunday
--
-- initDailyEU: DailyEU
-- initDailyEU = sundayInit


type alias DailyMP =
    { colors : List String
    , date : String
    , day : String
    , season : String
    , title : String
    , week : String
    , config : Config
    , show : Bool
    , collect : SundayCollect
    , mp1 : List Lesson
    , mp2 : List Lesson
    , mpp : List Lesson
    , sectionUpdate : SectionUpdate
    }


initDailyMP : DailyMP
initDailyMP =
    { colors = []
    , date = ""
    , day = ""
    , season = ""
    , title = ""
    , week = ""
    , config = configInit
    , show = False
    , collect = initSundayCollect
    , mp1 = []
    , mp2 = []
    , mpp = []
    , sectionUpdate = initSectionUpdate
    }


type alias DailyEP =
    { colors : List String
    , date : String
    , day : String
    , season : String
    , title : String
    , week : String
    , config : Config
    , show : Bool
    , collect : SundayCollect
    , ep1 : List Lesson
    , ep2 : List Lesson
    , epp : List Lesson
    , sectionUpdate : SectionUpdate
    }


initDailyEP : DailyEP
initDailyEP =
    { colors = []
    , date = ""
    , day = ""
    , season = ""
    , title = ""
    , week = ""
    , config = configInit
    , show = False
    , collect = initSundayCollect
    , ep1 = []
    , ep2 = []
    , epp = []
    , sectionUpdate = initSectionUpdate
    }


type alias Reflection =
    { author : String
    , markdown : String
    }


initReflection : Reflection
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
    { url = "www.esvapi.org/v2/rest/passageQuery?"
    , key = "10b28dac7c57fd96"
    , foot_notes = True
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


type alias Day =
    { name : String
    , colors : List String
    , dayOfMonth : String
    , date : String
    , daily : Daily
    , sunday : Sunday
    , today : Bool
    }


initDay : Day
initDay =
    { name = ""
    , colors = []
    , dayOfMonth = ""
    , date = ""
    , daily = initDaily
    , sunday = sundayInit
    , today = False
    }


type alias Leaflet =
    { reg : String
    , largePrint : String
    }

initLeaflet : Leaflet
initLeaflet =
    { reg = ""
    , largePrint = ""
    }
