module Iphod.MorningPrayer exposing (Model, init, Msg, update, view)
import Html exposing (..)
import Html.Attributes exposing (..)
import String
import Markdown
import Regex exposing (split, regex)

import Iphod.Models as Models
import Iphod.Helper exposing (hideable)


-- MODEL

type alias Model = Models.Daily

init: Model
init = Models.dailyInit


-- UPDATE

type Msg
  = NoOp
  | Show
  | JustToday

update: Msg -> Model -> Model
update msg model =
  case msg of
    NoOp -> model
    Show -> {model | show = not model.show}
    JustToday -> {model | justToday = not model.justToday}


-- HELPERS

blankline: List Html
blankline = [ p [style [("margin-top", "1em")] ] [] ]

formattedText: String -> List (String, String) -> Html
formattedText s attr =
  p [style attr] [text s]

htmlText: String -> List (String, String) -> Html
htmlText s attr =
  p [style attr] [Markdown.toHtml s]


title1: String -> List Html
title1 s =
  [ formattedText s
      [ ("font-size", "1.2em")
      , ("text-align", "center")
      , ("font-family", "Georgia, Times New Roman, Times, serif")
      ]
  ]

title2: String -> List Html
title2 s =
  [ formattedText s
      [ ("font-size", "1.1em")
      , ("text-align", "center")
      , ("font-family", "Georgia, Times New Roman, Times, serif")
      ]
  ]

title2Italic: String -> List Html
title2Italic s =
  [ formattedText s
      [ ("font-size", "1.1em")
      , ("text-align", "center")
      , ("font-style", "italic")
      , ("font-family", "Georgia, Times New Roman, Times, serif")
      ]
  ]

rubric: String -> List Html
rubric s =
  [ formattedText s
      [ ("font-size", "0.8em")
      , ("font-style", "italic")
      , ("font-family", "Georgia, Times New Roman, Times, serif")
      , ("color", "red")
      ]
  ]

rubricBlack: String -> List Html
rubricBlack s =
  [ formattedText s
      [ ("font-size", "0.8em")
      , ("font-style", "italic")
      , ("font-family", "Georgia, Times New Roman, Times, serif")
      ]
  ]

bibleRef: String -> List Html
bibleRef s =
  [ formattedText s
      [ ("font-size", "0.8em")
      , ("font-style", "italic")
      , ("font-family", "Georgia, Times New Roman, Times, serif")
      , ("margin", "-1em 0 1em 0")
      , ("padding", "0")
      ]
  ]

section: String -> List Html
section s =
  [ formattedText s
      [ ("font-size", "1.0em")
      , ("font-weight", "bold")
      , ("font-family", "Georgia, Times New Roman, Times, serif")
      ]
  ]

default: String -> List Html
default s =
  [ formattedText s
      [ ("font-size", "1.0em")
      , ("font-family", "Georgia, Times New Roman, Times, serif")
      ]
  ]

reading: Model -> String -> List Html
reading model s =
  [ htmlText s
      [ ("font-size", "1.0em")
      , ("font-family", "Georgia, Times New Roman, Times, serif")
      ]
  ]

italic: String -> List Html
italic s =
  [ formattedText s
      [ ("font-size", "1.0em")
      , ("font-family", "Georgia, Times New Roman, Times, serif")
      , ("font-style", "italic")
      ]
  ]

italicIndent: String -> List Html
italicIndent s =
  [ formattedText s
      [ ("font-size", "1.0em")
      , ("font-family", "Georgia, Times New Roman, Times, serif")
      , ("font-style", "italic")
      , ("margin", "0 0 0 2em")
      , ("padding", "0")
      ]
  ]

versical: String -> String -> List Html
versical speaker says =
  [ p [ style [ ("font-size", "1.0em")
              , ("font-family", "Georgia, Times New Roman, Times, serif")
              , ("margin", "0")
              ]
      ]
      [ span [ style [("font-style", "italic"), ("padding", "0 2em 0 0")] ] [text speaker]
      , span [style [("position", "absolute"),("left", "10em")] ] [text says]
      ]
  ]

vs: String -> List Html
vs s =
  [ formattedText s
      [ ("font-size", "1.0em")
      , ("font-family", "Georgia, Times New Roman, Times, serif")
      , ("margin", "0")
      , ("padding", "0")
      ]
  ]


vsIndent: String -> List Html
vsIndent s =
  [ formattedText s
      [ ("font-size", "1.0em")
      , ("font-family", "Georgia, Times New Roman, Times, serif")
      , ("margin", "0")
      , ("padding", "0 0 0 2em")
      ]
  ]

canticle: String -> String -> List Html
canticle title name =
  [ p [ style [ ("font-size", "1.0em")
              , ("font-family", "Georgia, Times New Roman, Times, serif")
              , ("margin", "0")
              ]
      ]
      [ span [ style [("font-weight", "bold"), ("padding", "0 2em 0 0")] ] [text title]
      , span [ style [("font-style", "italic")]] [text name]
      ]
  ]

mercy3: List Html
mercy3 =
  [ p 
    [style [("margin", "0"), ("padding", "0")]] 
    [text "Lord, have mercy [upon us]."]
  , p 
    [style [("margin", "0"), ("padding", "0"), ("font-style", "italic")]] 
    [text "Christ, have mercy [upon us]."]
  , p 
    [style [("margin", "0"), ("padding", "0")]] 
    [text "Lord, have mercy [upon us]."]
  ]

openingSentences: Model -> List Html
openingSentences model =
  case model.season of
    "advent" ->
      (rubricBlack "Advent")
      ++ (default "In the wilderness prepare the way of the Lord; make straight in the desert a highway for our God.")
      ++ (bibleRef "Isaiah 40:3")

    "christmas" ->
      (rubricBlack "Christmas")
      ++ (default "Fear not, for behold, I bring you good news of a great joy that will be for all people. For unto you is born this day in the city of David a Savior, who is Christ the Lord.")
      ++ (bibleRef "Luke 2:10-11")
    
    "epiphany" ->
      (rubricBlack "Epiphany")
      ++ (default "For from the rising of the sun to its setting my name will be great among the nations, and in every place incense will be offered to my name, and a pure offering. For my name will be great among the nations, says the Lord of hosts.")
      ++ (bibleRef "Malachi 1:11")
    "lent" ->
      (rubricBlack "Lent")
      ++ (default "Repent, for the kingdom of heaven is at hand.")
      ++ (bibleRef "Matthew 3:2")
    "goodFriday" ->
      (rubricBlack "Good Friday")
      ++ (default "Is it nothing to you, all you who pass by? Look and see if there is any sorrow like my sorrow, which was brought upon me, which the Lord inflicted on the day of his fierce anger.")
      ++ (bibleRef "Lamentations 1:12")
    "easter" ->
      (rubricBlack "Easter")
      ++ (default "Christ is risen! The Lord is risen indeed!")
      ++ (bibleRef "Mark 16:6 and Luke 24:34")
    "ascension" ->
      (rubricBlack "Ascension")
      ++ (default "Since then we have a great high priest who has passed through the heavens, Jesus, the Son of God, let us hold fast our confession. Let us then with confidence draw near to the throne of grace, that we may receive mercy and find grace to help in time of need.")
      ++ (bibleRef "Hebrews 4:14, 16")
    "pentecost" ->
      (rubricBlack "Pentecost")
      ++ (default "You will receive power when the Holy Spirit has come upon you, and you will be my witnesses in Jerusalem and in all Judea and Samaria, and to the end of the earth.")
      ++ (bibleRef "Acts 1:8")
    "trinity" ->
      (rubricBlack "Trinity Sunday")
      ++ (default "Holy, holy, holy, is the Lord God Almighty, who was and is and is to come!")
      ++ (bibleRef "Revelation 4:8")
    "thanksgiving" ->
      (rubricBlack "Days of Thanksgiving")
      ++ (default "Honor the Lord with your wealth and with the firstfruits of all your produce; then your barns will be filled with plenty, and your vats will be bursting with wine.")
      ++ (bibleRef "Proverbs 3:9-10")
    _ ->
        let
          os = case (cycleDay model 7) of
            0 ->
              (default "The Lord is in his holy temple; let all the earth keep silence before him.")
              ++ (bibleRef "Habakkuk 2:20")
            1 ->
              (default "I was glad when they said to me, “Let us go to the house of the Lord!”")
              ++ (bibleRef "Psalm 122:1")
            2 ->
              (default "Let the words of my mouth and the meditation of my heart be acceptable in your sight, O Lord, my rock and my redeemer.")
              ++ (bibleRef "Psalm 19:14")
            3 ->
              (default "Send out your light and your truth; let them lead me; let them bring me to your holy hill and to your dwelling!")
              ++ (bibleRef "Psalm 43:3")
            4 ->
              (default "For thus says the One who is high and lifted up, who inhabits eternity, whose name is Holy: “I dwell in the high and holy place, and also with him who is of a contrite and lowly spirit, to revive the spirit of the lowly, and to revive the heart of the contrite.”")
              ++ (bibleRef "Isaiah 57:15")
            5 ->
              (default "The hour is coming, and is now here, when the true worshipers will worship the Father in spirit and truth, for the Father is seeking such people to worship him.")
              ++ (bibleRef "John 4:23")
            _ ->
              (default "Grace to you and peace from God our Father and the Lord Jesus Christ.")
              ++ (bibleRef "Philippians 1:2")
        in
          os


invitatory: List Html
invitatory =
  [ table []
    [ tr [] 
        [ td [style [("font-style", "italic"),("padding-right", "3em")] ] [text "Officiant"]
        , td [] [text "O Lord, open our lips;"]
        ]
    , tr []
        [ td [style [("font-style", "italic")] ] [text "People"]
        , td [] [text "And our mouth shall proclaim your praise."]
        ]
    , tr []
        [ td [style [("font-style", "italic")] ] [text "Officiant"]
        , td [] [text "O God, make speed to save us;"]
        ]
    , tr []
        [ td [style [("font-style", "italic")] ] [text "People"]
        , td [] [text "O Lord, make haste to help us."]
        ]
    , tr [] 
        [ td [style [("font-style", "italic")] ] [text "Officiant"]
        , td [] [text "Glory to the Father, and to the Son, and to the Holy Spirit;"]
        ]
    , tr []
        [ td [style [("font-style", "italic")] ] [text "People"]
        , td [] [text "As it was in the beginning, is now, and ever shall be, world without end. Amen."]
        ]
    , tr []
        [ td [style [("font-style", "italic")] ] [text "Officiant"]
        , td [] [text "Praise the Lord."]
        ]
    ,tr []
        [ td [style [("font-style", "italic")] ] [text "Peopel"]
        , td [] [text "The Lord’s name be praised."]
        ]
    ]
  ]

invitatoryCantical: Model -> List Html
invitatoryCantical model =
  let 
    ic = if model.season == "easterDay"
      then
        (rubric "During the first week of Easter, the Pascha Nostrum will be used in place of the Invitatory Psalm. It is appropriate to use this canticle throughout Eastertide.")

        ++ (canticle "Pascha Nostrum" "Christ our Passover")
        ++ (rubricBlack "1 Corinthians 5:7-8; Romans 6:9-11; 1 Corinthians 15:20-22")
      
        ++ (vs "Alleluia. Christ our Passover has been sacrificed for us;")
        ++ (vsIndent "therefore let us keep the feast,")
        ++ (vs "Not with the old leaven, the leaven of malice and evil,")
        ++ (vsIndent "but with the unleavened bread of sincerity and truth. Alleluia.")
        ++ (vs "Christ being raised from the dead will never die again;")
        ++ (vsIndent "death no longer has dominion over him.")
        ++ (vs "The death that he died, he died to sin, once for all;")
        ++ (vsIndent "but the life he lives, he lives to God.")
        ++ (vs "So also consider yourselves dead to sin,")
        ++ (vsIndent "and alive to God in Jesus Christ our Lord. Alleluia.")
        ++ (vs "Christ has been raised from the dead,")
        ++ (vsIndent "the first fruits of those who have fallen asleep.")
        ++ (vs "For since by a man came death,")
        ++ (vsIndent "by a man has come also the resurrection of the dead.")
        ++ (vs "For as in Adam all die,")
        ++ (vsIndent "so also in Christ shall all be made alive. Alleluia.")
      else
        case (cycleDay model 2) of
          0 -> venite model

          _ ->
            (canticle "Jubilate" "Be Joyful")
            ++ (rubricBlack "Psalm 100")
            ++ (vs "Be joyful in the Lord, all you lands;")
            ++ (vsIndent "serve the Lord with gladness")
            ++ (vsIndent "and come before his presence with a song.")
            ++ (vs "Know this: the Lord himself is God;")
            ++ (vsIndent  "he himself has made us, and we are his;")
            ++ (vsIndent  "we are his people and the sheep of his pasture.")
            ++ (vs "Enter his gates with thanksgiving;")
            ++ (vsIndent "go into his courts with praise;")
            ++ (vsIndent "give thanks to him and call upon his Name.")
            ++ (vs "For the Lord is good;")
            ++ (vsIndent "his mercy is everlasting;")
            ++ (vsIndent "and his faithfulness endures from age to age.")
  in
    ic


canticalAfterLesson1: Model -> List Html
canticalAfterLesson1 model =
  case model.season of
    "lent" ->
      (rubric "During Lent the Benedictus es, Domine usually replaces the Te Deum. The Benedictus es, Domine may be used at other times as well.")
    
      ++ (canticle "Benedictus es, Domine" "A Song of Praise")
      ++ (rubricBlack "Song of the Three Young Men, 29-34")
      ++ (vs "Glory to you, Lord God of our fathers;")
      ++ (vsIndent "you are worthy of praise; glory to you.")
      ++ (vs "Glory to you for the radiance of your holy Name;")
      ++ (vsIndent "we will praise you and highly exalt you for ever.")
      ++ (vs "Glory to you in the splendor of your temple;")
      ++ (vsIndent "on the throne of your majesty, glory to you.")
      ++ (vs "Glory to you, seated between the Cherubim;")
      ++ (vsIndent "we will praise you and highly exalt you for ever.")
      ++ (vs "Glory to you, beholding the depths;")
      ++ (vsIndent "in the high vault of heaven, glory to you.")
      ++ (vs "Glory to the Father, and to the Son, and to the Holy Spirit;")
      ++ (vsIndent "we will praise you and highly exalt you for ever.")

    _ ->
      (canticle "Te Deum Laudamus" "We Praise You, O God")
    
      ++ (vs "We praise you, O God,")
      ++ (vsIndent "we acclaim you as Lord;")
      ++ (vsIndent "all creation worships you,")
      ++ (vsIndent "the Father everlasting.")
      ++ (vs "To you all angels, all the powers of heaven,")
      ++ (vs "The cherubim and seraphim, sing in endless praise:")
      ++ (vsIndent "Holy, Holy, Holy, Lord God of power and might,")
      ++ (vsIndent "heaven and earth are full of your glory.")
      ++ (vs "The glorious company of apostles praise you.")
      ++ (vs "The noble fellowship of prophets praise you.")
      ++ (vs "The white-robed army of martyrs praise you.")
      ++ (vs "Throughout the world the holy Church acclaims you:")
      ++ (vsIndent "Father, of majesty unbounded,")
      ++ (vsIndent "your true and only Son, worthy of all praise,")
      ++ (vsIndent "the Holy Spirit, advocate and guide.")
      ++ (vs "You, Christ, are the king of glory,")
      ++ (vsIndent "the eternal Son of the Father.")
      ++ (vs "When you took our flesh to set us free")
      ++ (vsIndent "you humbly chose the Virgin’s womb.")
      ++ (vs "You overcame the sting of death")
      ++ (vsIndent "and opened the kingdom of heaven to all believers.")
      ++ (vs "You are seated at God’s right hand in glory.")
      ++ (vsIndent "We believe that you will come to be our judge.")
      ++ (vs "Come then, Lord, and help your people,")
      ++ (vsIndent "bought with the price of your own blood,")
      ++ (vsIndent "and bring us with your saints")
      ++ (vsIndent "to glory everlasting.")
      ++ (vs "Save your people, Lord, and bless your inheritance;")
      ++ (vsIndent "govern and uphold them now and always.")
      ++ (vs "Day by day we bless you;")
      ++ (vsIndent "we praise your name forever.")
      ++ (vs "Keep us today, Lord, from all sin;")
      ++ (vsIndent "have mercy on us, Lord, have mercy.")
      ++ (vs "Lord, show us your love and mercy,")
      ++ (vsIndent "for we have put our trust in you.")
      ++ (vs "In you, Lord, is our hope,")
      ++ (vsIndent "let us never be put to shame.")

apostlesCreed: List Html
apostlesCreed =
     (rubric "If desired, a sermon on the Morning Lessons may be preached.")
  ++ (section "The Apostles’ Creed")
  ++ (rubric "Officiant and People together, all standing")
  ++ (vs "I believe in God, the Father almighty,")
  ++ (vsIndent "creator of heaven and earth.")
  ++ (vs "I believe in Jesus Christ, his only Son, our Lord.")
  ++ (vsIndent "He was conceived by the Holy Spirit")
  ++ (vsIndent "and born of the Virgin Mary.")
  ++ (vsIndent "He suffered under Pontius Pilate,")
  ++ (vsIndent "was crucified, died, and was buried.")
  ++ (vsIndent "He descended to the dead.")
  ++ (vsIndent "On the third day he rose again.")
  ++ (vsIndent "He ascended into heaven,")
  ++ (vsIndent "and is seated at the right hand of the Father.")
  ++ (vsIndent "He will come again to judge the living and the dead.")
  ++ (vs "I believe in the Holy Spirit,")
  ++ (vsIndent "the holy catholic Church,")
  ++ (vsIndent "the communion of saints,")
  ++ (vsIndent "the forgiveness of sins,")
  ++ (vsIndent "the resurrection of the body,")
  ++ (vsIndent "and the life everlasting. Amen.")


thePrayers1: List Html
thePrayers1 =
  [ table []
    [ tr [] 
        [ td [style [("font-style", "italic"),("padding-right", "3em")] ] [text "Officiant"]
        , td [] [text "The Lord be with you."]
        ]
    , tr []
        [ td [style [("font-style", "italic")] ] [text "People"]
        , td [] [text "And with your spirit."]
        ]
    , tr []
        [ td [style [("font-style", "italic")] ] [text "Officiant"]
        , td [] [text "Let us pray."]
        ]
    ]
  ]

thePrayers2: List Html
thePrayers2 =
  [ table []
    [ tr [] 
        [ td [style [("font-style", "italic"),("padding-right", "3em")] ] [text "Officiant"]
        , td [] [text "O Lord, show us your mercy;"]
        ]
    , tr []
        [ td [style [("font-style", "italic")] ] [text "People"]
        , td [] [text "And grant us your salvation."]
        ]
    , tr []
        [ td [style [("font-style", "italic")] ] [text "Officiant"]
        , td [] [text "O Lord, save our nations;"]
        ]
    , tr []
        [ td [style [("font-style", "italic")] ] [text "People"]
        , td [] [text "And guide us in the way of justice and truth."]
        ]
    , tr []
        [ td [style [("font-style", "italic")] ] [text "Officiant"]
        , td [] [text "Clothe your ministers with righteousness;"]
        ]
    , tr []
        [ td [style [("font-style", "italic")] ] [text "People"]
        , td [] [text "And make your chosen people joyful."]
        ]
    , tr []
        [ td [style [("font-style", "italic")] ] [text "Officiant"]
        , td [] [text "O Lord, save your people;"]
        ]
    , tr []
        [ td [style [("font-style", "italic")] ] [text "People"]
        , td [] [text "And bless your inheritance."]
        ]
    , tr []
        [ td [style [("font-style", "italic")] ] [text "Officiant"]
        , td [] [text "Give peace in our time, O Lord;"]
        ]
    , tr []
        [ td [style [("font-style", "italic")] ] [text "People"]
        , td [] [text "For only in you can we live in safety."]
        ]
    , tr []
        [ td [style [("font-style", "italic")] ] [text "Officiant"]
        , td [] [text "Let not the needy, O Lord, be forgotten;"]
        ]
    , tr []
        [ td [style [("font-style", "italic")] ] [text "People"]
        , td [] [text "Nor the hope of the poor be taken away."]
        ]
    , tr []
        [ td [style [("font-style", "italic")] ] [text "Officiant"]
        , td [] [text "Create in us clean hearts, O God;"]
        ]
    , tr []
        [ td [style [("font-style", "italic")] ] [text "People"]
        , td [] [text "And take not your Holy Spirit from us."]
        ]
    ]
  ]

theWordOfTheLord: List Html
theWordOfTheLord =
  [ table []
    [ tr [] 
        [ td [style [("font-style", "italic")] ] []
        , td [] [text "The Word of the Lord"]
        ]
    , tr []
        [ td [style [("font-style", "italic"),("padding-right", "3em")] ] [text "People"]
        , td [] [text "Thanks be to God"]
        ]
    ]
  ]

eoPrayer: List Html
eoPrayer =
  [ table []
    [ tr [] 
        [ td [style [("font-style", "italic"),("padding-right", "3em")] ] [text "Officiant"]
        , td [] [text "Let us bless the Lord"]
        ]
    , tr []
        [ td [style [("font-style", "italic")] ] [text "People"]
        , td [] [text "Thanks be to God"]
        ]
    ]
  ]


antiphon: Model -> List Html
antiphon model =
  case model.season of
    "advent"      ->
      (rubricBlack "Advent")
      ++ (default "Our King and Savior now draws near: O come, let us adore him.")

    "christmas"   ->
      (rubricBlack "Christmas")
      ++ (default "Alleluia, to us a child is born: O come, let us adore him. Alleluia.")
    
    "epiphany"    ->
      (rubricBlack "Epiphany through the Baptism of Christ and the Transfiguration")
      ++ (default "The Lord has shown forth his glory: O come, let us adore him.")
    

    "lent"        ->
      (rubricBlack "Lent")
      ++ (default "The Lord is full of compassion and mercy: O come, let us adore him.")

    "palmSunday"  ->
      (rubricBlack "Lent")
      ++ (default "The Lord is full of compassion and mercy: O come, let us adore him.")

    "easterDay"   ->
      (rubricBlack "Easter until Ascension")
      ++ (default "Alleluia. The Lord is risen indeed: O come, let us adore him. Alleluia.")

    "easter"      ->
      (rubricBlack "Easter until Ascension")
      ++ (default "Alleluia. The Lord is risen indeed: O come, let us adore him. Alleluia.")

    "proper"      ->
      let
        a = case (cycleDay model 3) of
        0 ->
          (rubricBlack "For use at any time")
          ++ (default "The earth is the Lord's for he made it: O Come let us adore him.")
        1 ->
          (rubricBlack "Or this")
          ++ (default "Worship the Lord in the beauty of holiness: O Come let us adore him.")
        _ ->
          (rubricBlack "Or this")
          ++ (default "The mercy of the Lord is everlasting: O Come let us adore him.")
      in
       a

    _           ->
      -- not sure what to do here so will do...
          (rubricBlack "Or this")
          ++ (default "Worship the Lord in the beauty of holiness: O Come let us adore him.")
      -- until something better comes along 
      -- and I figure out how to deal with the following
      --  ++ (rubricBlack "Ascension until Pentecost")
      --  ++ (default "Alleluia. Christ the Lord has ascended into heaven: O come, let us adore him. Alleluia.")
      --
      --  ++ (rubricBlack "Pentecost and the week following")
      --  ++ (default "Alleluia. The Spirit of the Lord renews the face of the earth: O come, let us adore him. Alleluia.")
      --
      --  ++ (rubricBlack "Trinity Sunday")
      --  ++ (default "Father, Son and Holy Spirit, one God: O come, let us adore him.")
      --
      --  ++ (rubricBlack "On feasts of the Incarnation")
      --  ++ (default "The Word was made flesh and dwelt among us: O come, let us adore him.")
      --
      --  ++ (rubricBlack "On All Saints and other major saints’ days")
      --  ++ (default "The Lord is glorious in his saints: O come, let us adore him.")

venite: Model -> List Html
venite model =
  let
    s = (canticle "Venite" "O Come")
        ++ (rubricBlack "Psalm 95:1-7; 8-11")
        ++ (vs "O come, let us sing to the Lord;")
        ++ (vs "Let us make a joyful noise to the rock of our salvation!")
        ++ (vs "Let us come into his presence with thanksgiving;")
        ++ (vs "Let us make a joyful noise to him with songs of praise!")
        ++ (vs "For the Lord is a great God, and a great King above all gods.")
        ++ (vs "In his hand are the depths of the earth;")
        ++ (vsIndent "the heights of the mountains are his also.")
        ++ (vs "The sea is his, for he made it,")
        ++ (vsIndent "and his hands formed the dry land.")
        ++ (vs "O come, let us worship and bow down;")
        ++ (vsIndent "Let us kneel before the Lord, our Maker!")
        ++ (vs "For he is our God, and we are the people of his pasture,")
        ++ (vsIndent "and the sheep of his hand.")
        ++ (vs "O, that today you would hearken to his voice!")
        ++ (blankline)
    v = s ++ if model.season == "lent"
      then (rubric "In Lent, and on other penitential occasions, the following verses are added.")
        ++ (vs "Do not harden your hearts, as at Meribah,")
        ++ (vsIndent "as on the day at Massah in the wilderness,")
        ++ (vsIndent "when your fathers put me to the test")
        ++ (vsIndent "and put me to the proof, though they had seen my work.")
        ++ (vs "For forty years I loathed that generation")
        ++ (vsIndent "and said, “They are a people who go astray in their heart,")
        ++ (vsIndent "and they have not known my ways.”")
        ++ (vs "Therefore I swore in my wrath,")
        ++ (vsIndent "“They shall not enter my rest.”")
        ++ (blankline)
      else
        []
  in
    v

collectOfDay: Model -> List Html
collectOfDay model =
  case model.day of
    "Monday" ->
      (default "A Collect for the Renewal of Life (Monday)")
      ++ (default "O God, the King eternal, whose light divides the day from the night and turns the shadow of death into the morning: Drive far from us all wrong desires, incline our hearts to keep your law, and guide our feet into the way of peace; that, having done your will with cheerfulness during the day, we may, when night comes, rejoice to give you thanks; through Jesus Christ our Lord. Amen.")

    "Tuesday" ->
       (default "A Collect for Peace (Tuesday)")
      ++ (default "O God, the author of peace and lover of concord, to know you is eternal life and to serve you is perfect freedom: Defend us, your humble servants, in all assaults of our enemies; that we, surely trusting in your defense, may not fear the power of any adversaries, through the might of Jesus Christ our Lord. Amen.")

    "Wednesday" ->
      (default "A Collect for Grace (Wednesday)")
      ++ (default "O Lord, our heavenly Father, almighty and everlasting God, you have
      brought us safely to the beginning of this day: Defend us by your
      mighty power, that we may not fall into sin nor run into any danger;
      and that guided by your Spirit, we may do what is righteous in your
      sight; through Jesus Christ our Lord. Amen.")

    "Thursday" ->
      (default "A Collect for Guidance (Thursday)")
      ++ (default "Heavenly Father, in you we live and move and have our being: We
      humbly pray you so to guide and govern us by your Holy Spirit, that
      in all the cares and occupations of our life we may not forget you, but
      may remember that we are ever walking in your sight; through Jesus
      Christ our Lord. Amen.")

    "Friday" ->
      (default "A Collect for Endurance (Friday)")
      ++ (default "Almighty God, whose most dear Son went not up to joy but first he
      suffered pain, and entered not into glory before he was crucified:
      Mercifully grant that we, walking in the way of the cross, may find it
      none other than the way of life and peace; through Jesus Christ your
      Son our Lord. Amen.")

    "Saturday" ->
      (default "A Collect for Sabbath Rest (Saturday)")
      ++ (default "Almighty God, who after the creation of the world rested from all
      your works and sanctified a day of rest for all your creatures: Grant
      that we, putting away all earthly anxieties, may be duly prepared for
      the service of your sanctuary, and that our rest here upon earth may
      be a preparation for the eternal rest promised to your people in
      heaven; through Jesus Christ our Lord. Amen.")

    "Sunday" ->
      (default "A Collect for Strength to Await Christ’s Return (Sunday)")
      ++ (default "O God our King, by the resurrection of your Son Jesus Christ on the first day of the week, you conquered sin, put death to flight, and gave us the hope of everlasting life: Redeem all our days by this victory; forgive our sins, banish our fears, make us bold to praise you and to do your will; and steel us to wait for the consummation of your kingdom on the last great Day; through the same Jesus Christ our Lord. Amen.")

    _ -> []

forMission: Model -> List Html
forMission model =
  case (cycleDay model 3) of
    0 ->
      (default "Almighty and everlasting God, who alone works great marvels: Send
      down upon our clergy and the congregations committed to their
      charge the life-giving Spirit of your grace, shower them with the
      continual dew of your blessing, and ignite in them a zealous love of
      your Gospel, through Jesus Christ our Lord. Amen.")

    1 -> 
      (default "O God, you have made of one blood all the peoples of the earth, and
      sent your blessed Son to preach peace to those who are far off and to
      those who are near: Grant that people everywhere may seek after you
      and find you; bring the nations into your fold; pour out your Spirit
      upon all flesh; and hasten the coming of your kingdom; through
      Jesus Christ our Lord. Amen.")

    _ ->
      (default "Lord Jesus Christ, you stretched out your arms of love on the hard
      wood of the cross that everyone might come within the reach of your
      saving embrace: So clothe us in your Spirit that we, reaching forth 
      our hands in love, may bring those who do not know you to the
      knowledge and love of you; for the honor of your Name. Amen.")


theGraces: Model -> List Html
theGraces model =
  case (cycleDay model 3) of
    0 ->
      (default "The grace of our Lord Jesus Christ, and the love of God, and the
      fellowship of the Holy Spirit, be with us all evermore. Amen.")
      ++ (bibleRef "2 Corinthians 13:14")
    1 ->
      (default "May the God of hope fill us with all joy and peace in believing
      through the power of the Holy Spirit. Amen.")
      ++ (bibleRef "Romans 15:13")
    _ ->
      (default "Glory to God whose power, working in us, can do infinitely more
      than we can ask or imagine: Glory to him from generation to
      generation in the Church, and in Christ Jesus forever and ever. Amen.")
      ++ (bibleRef "Ephesians 3:20-21")





cycleDay: Model -> Int -> Int
cycleDay model n =
  model.date 
    |> Regex.split Regex.All (regex "[ ,]")
    |> List.drop 2
    |> List.head
    |> Maybe.withDefault "0"
    |> String.toInt 
    |> Result.withDefault 0
    |> rem n

-- STYLE

mpStyle: Model -> Attribute
mpStyle model =
  hideable
    model.show
      [ ("font-family", "Georgia, Times New Roman, Times, serif")
      , ("font-size", "1.0em")
      ]
  

-- VIEW MORNING PRAYER 

view: Model -> Html Msg
view model =
  div 
  [ mpStyle model ]
  ( (title1 "Daily Morning Prayer")
  ++ (title1 model.date)
  ++ (title2Italic "Approved for Provincial Use")
  ++ (title2 "The Anglican Church in North America")
  ++ (title2Italic "Petertide, A.D. 2013")

  ++ (rubric "The Officiant may begin Morning Prayer by reading an opening sentence of Scripture found on pages 17-19 or another appropriate Scripture. The Confession of Sin may be said, or the Office may continue with “O Lord, open our lips.”")
  ++ (section "Opening Sentences of Scripture")
  ++ (openingSentences model)
  ++ (blankline)
  ++ (section "Confession of Sin")

  ++ (rubric "The Officiant says to the People")

  ++ (default "Dearly beloved, the Scriptures teach us to acknowledge our many sins and offenses, not concealing them from our heavenly Father, but confessing them with humble and obedient hearts that we may obtain forgiveness by his infinite goodness and mercy. We ought at all times humbly to acknowledge our sins before Almighty God, but especially when we come together in his presence to give thanks for the great benefits we have received at his hands, to declare his most worthy praise, to hear his holy Word, and to ask, for ourselves and others, those things necessary for our life and our salvation. Therefore, come with me to the throne of heavenly grace.")

  ++ (rubric "or this")

  ++ (default "Let us humbly confess our sins to Almighty God.")

  ++ (rubric "Silence is kept. All kneeling the Officiant and People say")

  ++ (vs "Almighty and most merciful Father," )
  ++ (vs "we have erred and strayed from your ways like lost sheep.")
  ++ (vs "we have followed too much the deceits and desires of our" )
  ++ (vsIndent "own hearts." )
  ++ (vs "we have offended against your holy laws.")
  ++ (vs "we have left undone those things which we ought to have done")
  ++ (vs "and we have done those things which we ought not to have done;")
  ++ (vs "and apart from your grace, there is no health in us.")
  ++ (vs "O Lord, have mercy upon us." )
  ++ (vs "Spare those who confess their faults.")
  ++ (vs "Restore those who are penitent, according to your promises declared")
  ++ (vsIndent "to all people in Christ Jesus our Lord;")
  ++ (vs "And grant, O most merciful Father, for his sake,")
  ++ (vsIndent "that we may now live a godly, righteous, and sober life,")
  ++ (vsIndent "to the glory of your holy Name. Amen.")
  ++ (blankline)
  ++ (rubric "The Priest alone stands and says")

  ++ (default "Almighty God, the Father of our Lord Jesus Christ, desires not the death of sinners, but that they may turn from their wickedness and live. He has empowered and commanded his ministers to pronounce to his people, being penitent, the absolution and remission of their sins. He pardons all who truly repent and genuinely believe his holy Gospel. For this reason, we beseech him to grant us true repentance and his Holy Spirit, that our present deeds may please him, the rest of our lives may be pure and holy, and that at the last we may come to his eternal joy; through Jesus Christ our Lord. Amen.")

  ++ (rubric "or this")

  ++ (default "The Almighty and merciful Lord grant you absolution and remission of all your sins, true repentance, amendment of life, and the grace and consolation of his Holy Spirit. Amen.")

  ++ (rubric "A deacon or layperson remains kneeling and prays")

  ++ (default "Grant your faithful people, merciful Lord, pardon and peace; that we may be cleansed from all our sins, and serve you with a quiet mind; through Jesus Christ our Lord. Amen.")

  ++ (section "The Invitatory")

  ++ (rubric "All stand.")
  ++ (invitatory)
  ++ (blankline)
  ++ (rubric "Then follows the Venite. Alternatively, the Jubilate may be used.")
  ++ (rubric "These seasonal antiphons may be sung or said before and after the Invitatory Psalm.")

  ++ (antiphon model)
  ++ (invitatoryCantical model)

  ++ (blankline)

  ++ (rubric "Then follows")

  ++ (section "The Psalm or Psalms Appointed")
  ++ (reading model (String.join " " (List.concat[["Appointed Psalms"], (List.map (\m -> m.body) model.mpp)] )))
  ++ (rubric "At the end of the Psalms is sung or said")

  ++ (vs "Glory to the Father, and to the Son, and to the Holy Spirit;")
  ++ (vsIndent "as it was in the beginning, is now, and ever shall be,")
  ++ (vsIndent "world without end. Amen.")

  ++ (section "The Lessons")
  ++ (rubric "One or more Lessons, as appointed, are read, the Reader first saying")
  ++ (reading model (String.join " " (List.concat[["The First Lesson from"], (List.map (\m -> m.body) model.mp1)] )))
  ++ (rubric "A citation giving chapter and verse may be added.")
  ++ (rubric "After each Lesson the Reader may say")
  ++ (theWordOfTheLord)
  ++ (blankline)

  ++ (rubric "Or the Reader may say")
  ++ (versical "" "Here ends the Reading.")
  ++ (blankline)

  ++ (rubric "The following Canticles are normally sung or said after each of the lessons. The Officiant may also use a Canticle drawn from those on pages 35-43 or an appropriate song of praise.")
  ++ (canticalAfterLesson1 model)
  ++ (blankline)

  ++ (reading model (String.join " " (List.concat[["The Second Lesson from"], (List.map (\m -> m.body) model.mp2)] )))
  ++ (theWordOfTheLord)
  ++ (blankline)

  ++ (canticle "Benedictus" "The Song of Zechariah")
  ++ (rubricBlack "Luke 1:68-79")
  ++ (vs "Blessed be the Lord, the God of Israel;")
  ++ (vsIndent "he has come to his people and set them free.")
  ++ (vs "He has raised up for us a mighty savior,")
  ++ (vsIndent "born of the house of his servant David.")
  ++ (vs "Through his holy prophets he promised of old,")
  ++ (vs "that he would save us from our enemies,")
  ++ (vsIndent "from the hands of all who hate us.")
  ++ (vs "He promised to show mercy to our fathers")
  ++ (vsIndent "and to remember his holy covenant.")
  ++ (vs "This was the oath he swore to our father Abraham,")
  ++ (vsIndent "to set us free from the hands of our enemies,")
  ++ (vs "Free to worship him without fear,")
  ++ (vsIndent "holy and righteous in his sight")
  ++ (vsIndent "all the days of our life.")
  ++ (vs "You, my child, shall be called the prophet of the Most High,")
  ++ (vsIndent "for you will go before the Lord to prepare his way,")
  ++ (vs "To give his people knowledge of salvation")
  ++ (vsIndent "by the forgiveness of their sins.")
  ++ (vs "In the tender compassion of our God")
  ++ (vsIndent "the dawn from on high shall break upon us,")
  ++ (vs "To shine on those who dwell in darkness and the shadow of death,")
  ++ (vsIndent "and to guide our feet into the way of peace.")
  ++ (vs "Glory to the Father, and to the Son, and to the Holy Spirit;")
  ++ (vsIndent "as it was in the beginning, is now, and ever shall be,")
  ++ (vsIndent "world without end. Amen.")
  ++ (blankline)

  ++ (apostlesCreed)

  ++ (section "The Prayers")
  ++ (rubric "The People kneel or stand.")
  ++ thePrayers1
  ++ (blankline)

  ++ (mercy3)
  ++ (blankline)

  ++ (rubric "Officiant and People")

  ++ (vs "Our Father, who art in heaven, hallowed be thy Name.")
  ++ (vs "Thy kingdom come, thy will be done, on earth as it is in heaven.")
  ++ (vs "Give us this day our daily bread.")
  ++ (vs "And forgive us our trespasses, as we forgive those who trespass")
  ++ (vsIndent "against us.")
  ++ (vs "And lead us not into temptation, but deliver us from evil.")
  ++ (vs "For thine is the kingdom, and the power, and the glory,")
  ++ (vsIndent "forever and ever. Amen.")
  ++ (blankline)

  ++ (rubric "or this")

  ++ (vs "Our Father in heaven, hallowed be your Name.")
  ++ (vs "Your kingdom come, your will be done, on earth as it is in heaven.")
  ++ (vs "Give us today our daily bread.")
  ++ (vs "And forgive us our sins as we forgive those who sin against us.")
  ++ (vs "Save us from the time of trial, and deliver us from evil.")
  ++ (vs "For the kingdom, the power, and the glory are yours,")
  ++ (vsIndent "now and forever. Amen.")
  ++ (blankline)
  ++ (thePrayers2)
  ++ (blankline)

  ++ (rubric "The Officiant then prays one or more of the following collects. It is traditional to pray the Collects for Peace and Grace daily. Alternatively, one may pray the collects on a weekly rotation, using the suggestions in parentheses.")
  ++ (section "The Collect of the Day")

  ++ (collectOfDay model)

  ++ (rubric "Unless The Great Litany or the Eucharist is to follow, one of the following prayers for mission is added.")

  ++ (rubric "Here may be sung a hymn or anthem.")
  ++ (rubric "The Officiant may invite the People to offer intercessions and thanksgivings.")
  ++ (rubric "Before the close of the Office one or both of the following may be used.")

  ++ (forMission model)

  ++ (section "The General Thanksgiving")
  ++ (rubric "Officiant and People")
  ++ (vs "Almighty God, Father of all mercies,")
  ++ (vs "we your unworthy servants give you humble thanks")
  ++ (vs "for all your goodness and loving-kindness")
  ++ (vsIndent "to us and to all whom you have made.")
  ++ (vs "We bless you for our creation, preservation,")
  ++ (vsIndent "and all the blessings of this life;")
  ++ (vs "but above all for your immeasurable love")
  ++ (vs "in the redemption of the world by our Lord Jesus Christ;")
  ++ (vs "for the means of grace, and for the hope of glory.")
  ++ (vs "And, we pray, give us such an awareness of your mercies,")
  ++ (vs "that with truly thankful hearts we may show forth your praise,")
  ++ (vs "not only with our lips, but in our lives,")
  ++ (vs "by giving up our selves to your service,")
  ++ (vs "and by walking before you")
  ++ (vsIndent "in holiness and righteousness all our days;")
  ++ (vs "through Jesus Christ our Lord,")
  ++ (vs "to whom, with you and the Holy Spirit,")
  ++ (vs "be honor and glory throughout all ages. Amen.")
  ++ (blankline)

  ++ (section "A Prayer of St. John Chrysostom")
  ++ (default "Almighty God, you have given us grace at this time with one accord
  to make our common supplications to you; and you have promised 
  through your well beloved Son that when two or three are gathered
  together in his name you will be in the midst of them: Fulfill now, O
  Lord, our desires and petitions as may be best for us; granting us in
  this world knowledge of your truth, and in the age to come life
  everlasting. Amen.")
  ++ (eoPrayer)
  ++ (blankline)

  ++ (rubric "From Easter Day through the Day of Pentecost “Alleluia, alleluia” may be added to the
  preceding versicle and response.")
  ++ (rubric "The Officiant may invite the People to join in one of the Graces.")
  ++ (rubric "Officiant")
  ++ (theGraces model)

  ++ (section "General Instructions: Morning and Evening Prayer")
  ++ (italic "The Confession and Apostles’ Creed may be omitted, provided they have been said
  once during the course of the day.")
  ++ (italic "In the opening versicles, the Officiant and People may join in saying “Alleluia”
  (outside of Lent) as an alternative to the versicles “Praise the Lord/The Lord’s
  name be praised.”")
  ++ (italic "The following form of the Gloria Patri may be used:")
  ++ (italicIndent "Glory to the Father, and to the Son, and to the Holy Spirit:")
  ++ (italicIndent "As it was in the beginning, is now, and will be forever. Amen.")
  ++ (blankline)
  ++ (italic "A sermon may also be preached after the Office or after the hymn or anthem (if
  sung) following the collects.")
  )
