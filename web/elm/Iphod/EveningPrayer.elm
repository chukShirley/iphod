module Iphod.EveningPrayer (Model, init, Action, update, view) where

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Effects exposing (Effects, Never)
import Task exposing (Task)
import String
import Markdown
import Regex exposing (split, regex)

import Iphod.Models as Models
import Iphod.Helper exposing (onClickLimited, hideable, getText)

-- MODEL

type alias Model = Models.Daily

init: Model
init = Models.dailyInit

-- UPDATE

type Action
  = NoOp
  | Show
  | JustToday

update: Action -> Model -> Model
update action model =
  case action of
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
      ++ (default "Therefore stay awake – for you do not know when the master of the
                  house will come, in the evening, or at midnight, or when the cock
                  crows, or in the morning – lest he come suddenly and find you asleep.")
      ++ (bibleRef "Mark 13:35-36")

    "christmas" ->
      (rubricBlack "Christmas")
      ++ (default "Behold, the dwelling place of God is with man. He will dwell with
                  them, and they will be his people, and God himself will be with them
                  as their God.")
      ++ (bibleRef "Revelation 21:3")
    
    "epiphany" ->
      (rubricBlack "Epiphany")
      ++ (default "Nations shall come to your light, and kings to the brightness of your rising.")
      ++ (bibleRef "Isaiah 60:3")
    "lent" ->
        let
          os = case (cycleDay model 3) of
            0 ->  (default "If we say we have no sin, we deceive ourselves, and the truth is not in
                              us. If we confess our sins, he is faithful and just to forgive us our sins
                              and to cleanse us from all unrighteousness.")
                  ++ (bibleRef "1 John 1:8-9")
            1 ->   (default "For I know my transgressions, and my sin is ever before me.")
                  ++ (bibleRef "Psalm 51:3")
            _ ->  (default "To the Lord our God belong mercy and forgiveness, for we have against him.")
                  ++ (bibleRef "Daniel 9:9")
        in
          (rubricBlack "Lent") ++ os

    "goodFriday" ->
      (rubricBlack "Good Friday")
      ++ (default "All we like sheep have gone astray; we have turned every one to his
                  own way; and the Lord has laid on him the iniquity of us all.")
      ++ (bibleRef "Isaiah 53:6")
    "easter" ->
        let
          os = case (cycleDay model 2) of
            0 -> (default "Thanks be to God, who gives us the victory through our Lord Jesus Christ.")
                  ++ (bibleRef "1 Corinthians 15:57")
            _ -> (default "If then you have been raised with Christ, seek the things that are
                          above, where Christ is, seated at the right hand of God.")
                  ++ (bibleRef "Colossians 3:1")
        in
          (rubricBlack "Easter") ++ os
    "ascension" ->
      (rubricBlack "Ascension")
      ++ (default "For Christ has entered, not into holy places made with hands, which
                  are copies of the true things, but into heaven itself, now to appear in
                  the presence of God on our behalf.")
      ++ (bibleRef "Hebrews 9:24")
    "pentecost" ->
      let
        os = case (cycleDay model 2) of
          0 -> (default "The Spirit and the Bride say, “Come.” And let the one who hears say,
                        “Come.” And let the one who is thirsty come; let the one who desires
                        take the water of life without price.")
                ++ (bibleRef "Revelation 22:17")
          _ -> (default "There is a river whose streams make glad the city of God, the holy
                        habitation of the Most High.")
                ++ (bibleRef "Psalm 46:4")
      in
        (rubricBlack "Pentecost") ++ os
    "trinity" ->
      (rubricBlack "Trinity Sunday")
      ++ (default "Holy, holy, holy, is the Lord God of Hosts; the whole earth is full of his glory!")
      ++ (bibleRef "Isaiah 6:3")
    "thanksgiving" ->
      (rubricBlack "Days of Thanksgiving")
      ++ (default "The Lord by wisdom founded the earth; by understanding he
                    established the heavens; by his knowledge the deeps broke open, and
                    the clouds drop down the dew.")
      ++ (bibleRef "Proverbs 3:19-20")
    _ ->
        let
          os = case (cycleDay model 5) of
            0 ->
              (default "The Lord is in his holy temple; let all the earth keep silence before him.")
              ++ (bibleRef "Habakkuk 2:20")
            1 ->
              (default "O Lord, I love the habitation of your house and the place where your glory dwells.")
              ++ (bibleRef "Psalm 46:8")
            2 ->
              (default "Let my prayer be counted as incense before you, and the lifting up of
                        my hands as the evening sacrifice!")
              ++ (bibleRef "Psalm 141:2")
            3 ->
              (default "Worship the Lord in the splendor of holiness; tremble before him, all the earth!")
              ++ (bibleRef "Psalm 96:9")
            _ ->
              (default "Let the words of my mouth and the meditation of my heart be
                        acceptable in your sight, O Lord, my rock and my redeemer.")
              ++ (bibleRef "Psalm 19:14")
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

phosHilaron: List Html
phosHilaron =
     (canticle "Phos hilaron" "O Gladsome Light")
  ++ (vs "O gladsome light,")
  ++ (vs "pure brightness of the ever-living Father in heaven,")
  ++ (vs "O Jesus Christ, holy and blessed!")
  ++ (vs "Now as we come to the setting of the sun,")
  ++ (vs "and our eyes behold the vesper light,")
  ++ (vs "we sing praises to God: the Father, the Son, and the Holy Spirit.")
  ++ (vs "You are worthy at all times to be praised by happy voices,")
  ++ (vs "O Son of God, O Giver of Life,")
  ++ (vs "and to be glorified through all the worlds.")

magnificat: List Html
magnificat =
       (canticle "Magnificat" "The Song of Mary")
    ++ (rubricBlack "Luke 1:46-55")
    ++ (vs "My soul magnifies the Lord,")
    ++ (vsIndent "and my spirit rejoices in God my Savior.")
    ++ (vs "For he has regarded")
    ++ (vsIndent "the lowliness of his handmaiden.")
    ++ (vs "For behold, from now on,")
    ++ (vsIndent "all generations will call me blessed.")
    ++ (vs "For he that is mighty has magnified me,")
    ++ (vsIndent "and holy is his Name.")
    ++ (vs "And his mercy is on those who fear him,")
    ++ (vsIndent "throughout all generations.")
    ++ (vs "He has shown the strength of his arm;")
    ++ (vsIndent "he has scattered the proud in the imagination of their hearts.")
    ++ (vs "He has brought down the mighty from their thrones,")
    ++ (vsIndent "and has exalted the humble and meek.")
    ++ (vs "He has filled the hungry with good things,")
    ++ (vsIndent "and the rich he has sent empty away.")
    ++ (vs "He, remembering his mercy, has helped his servant Israel,")
    ++ (vsIndent "as he promised to our fathers, Abraham and his seed forever.")
    ++ (vs "Glory to the Father, and to the Son, and to the Holy Spirit;")
    ++ (vsIndent "as it was in the beginning, is now, and ever shall be,")
    ++ (vsIndent "world without end. Amen.")

nuncDimittis: List Html
nuncDimittis =
       (canticle "Nunc dimittis" "The Song of Simeon")
    ++ (rubricBlack "Luke 2:29-32")
    ++ (vs "Lord, now let your servant depart in peace,")
    ++ (vsIndent "according to your word.")
    ++ (vs "For my eyes have seen your salvation,")
    ++ (vsIndent "which you have prepared before the face of all people;")
    ++ (vs "to be a light to lighten the Gentiles,")
    ++ (vsIndent "and to be the glory of your people Israel.")
    ++ (vs "Glory to the Father, and to the Son, and to the Holy Spirit;")
    ++ (vsIndent "as it was in the beginning, is now, and ever shall be, world")
    ++ (vsIndent "without end. Amen.")

apostlesCreed: List Html
apostlesCreed =
     (section "The Apostles’ Creed")
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

collectOfDay: Model -> List Html
collectOfDay model =
  case model.day of
    "Monday" ->
      (default "A Collect for Peace (Monday)")
      ++ (default "O God, the source of all holy desires, all good counsels, and all just
            works: Give to your servants that peace which the world cannot give,
            that our hearts may be set to obey your commandments, and that we,
            being defended from the fear of our enemies, may pass our time in 
            rest and quietness, through the merits of Jesus Christ our Savior.
            Amen.")

    "Tuesday" ->
       (default "A Collect for Aid against Perils (Tuesday)")
      ++ (default "Lighten our darkness, we beseech you, O Lord; and by your great
            mercy defend us from all perils and dangers of this night; for the love
            of your only Son, our Savior Jesus Christ. Amen.")

    "Wednesday" ->
      (default "A Collect for Protection (Wednesday) ")
      ++ (default "O God, the life of all who live, the light of the faithful, the strength
            of those who labor, and the repose of the dead: We thank you for the
            blessings of the day that is past, and humbly ask for your protection
            through the coming night. Bring us in safety to the morning hours;
            through him who died and rose again for us, your Son our Savior
            Jesus Christ. Amen")

    "Thursday" ->
      (default "A Collect for the Presence of Christ (Thursday)")
      ++ (default "Lord Jesus, stay with us, for evening is at hand and the day is past; be
            our companion in the way, kindle our hearts, and awaken hope, that
            we may know you as you are revealed in Scripture and the breaking
            of bread. Grant this for the sake of your love. Amen.")

    "Friday" ->
      (default "A Collect for Faith (Friday)")
      ++ (default "Lord Jesus Christ, by your death you took away the sting of death:
            Grant to us your servants so to follow in faith where you have led the
            way, that we may at length fall asleep peacefully in you and wake up
            in your likeness; for your tender mercies’ sake. Amen.")

    "Saturday" ->
      (default "A Collect for the Eve of Worship (Saturday)")
      ++ (default "O God, the source of eternal light: Shed forth your unending day
            upon us who watch for you, that our lips may praise you, our lives
            may bless you, and our worship on the morrow give you glory;
            through Jesus Christ our Lord. Amen.")

    "Sunday" ->
      (default "A Collect for Resurrection Hope (Sunday)")
      ++ (default "Lord God, whose Son our Savior Jesus Christ triumphed over the
            powers of death and prepared for us our place in the new Jerusalem:
            Grant that we, who have this day given thanks for his resurrection,
            may praise you in that City of which he is the light, and where he
            lives and reigns forever and ever. Amen.")

    _ -> []

forMission: Model -> List Html
forMission model =
  case (cycleDay model 3) of
    0 ->
      (default "O God and Father of all, whom the whole heavens adore: Let the
            whole earth also worship you, all nations obey you, all tongues
            confess and bless you, and men, women and children everywhere
            love you and serve you in peace; through Jesus Christ our Lord.
            Amen.")

    1 -> 
      (default "Keep watch, dear Lord, with those who work, or watch, or weep this
            night, and give your angels charge over those who sleep. Tend the
            sick, Lord Christ; give rest to the weary, bless the dying, soothe the
            suffering, pity the afflicted, shield the joyous; and all for your love’s
            sake. Amen.")

    _ ->
      (default "O God, you manifest in your servants the signs of your presence:
            Send forth upon us the Spirit of love, that in companionship with
            one another your abounding grace may increase among us; through
            Jesus Christ our Lord. Amen.")

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

epStyle: Model -> Attribute
epStyle model =
  hideable
    model.show
      [ ("font-family", "Georgia, Times New Roman, Times, serif")
      , ("font-size", "1.0em")
      ]


-- VIEW

view: Signal.Address Action -> Model -> Html
view address model =
  div
  [ epStyle model ]
  ( (title1 "Daily Evening Prayer")
  ++ (title1 model.date)
  ++ (title2Italic "Approved for Provincial Use")
  ++ (title2 "The Anglican Church in North America")
  ++ (title2Italic "Petertide, A.D. 2013")

  ++ (rubric "The Officiant may begin Evening Prayer by reading an opening sentence of Scripture found on pages 17-19 or another appropriate Scripture. The Confession of Sin may be said, or the Office may continue with “O Lord, open our lips.”")
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

  ++ (rubric "The following or some other suitable hymn or Psalm may be sung or said")
  ++ (phosHilaron)
  ++ (blankline)
  ++ (rubric "Then follows")

    ++ (section "The Psalm or Psalms Appointed")
  ++ (reading model (String.join " " (List.concat[["Appointed Psalms"], (List.map (\m -> m.body) model.epp)] )))
  ++ (rubric "At the end of the Psalms is sung or said")

  ++ (vs "Glory to the Father, and to the Son, and to the Holy Spirit;")
  ++ (vsIndent "as it was in the beginning, is now, and ever shall be,")
  ++ (vsIndent "world without end. Amen.")
  ++ (blankline)
  ++ (section "The Lessons")
  ++ (rubric "One or more Lessons, as appointed, are read, the Reader first saying")
  ++ (reading model (String.join " " (List.concat[["The First Lesson from"], (List.map (\m -> m.body) model.ep1)] )))
  ++ (rubric "A citation giving chapter and verse may be added.")
  ++ (rubric "After each Lesson the Reader may say")
  ++ (theWordOfTheLord)
  ++ (blankline)

  ++ (rubric "Or the Reader may say")
  ++ (versical "" "Here ends the Reading.")
  ++ (blankline)

  ++ (magnificat)

  ++ (blankline)
  ++ (reading model (String.join " " (List.concat[["The Second Lesson from"], (List.map (\m -> m.body) model.ep2)] )))
  ++ (theWordOfTheLord)
  ++ (blankline)

  ++ (nuncDimittis)
  ++ (blankline)
  ++ (rubric "If desired, a sermon on the Evening Lessons may be preached.")
  ++ (apostlesCreed)
  ++ (blankline)

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

  ++ (rubric "Unless the Eucharist is to follow, one of the following prayers for mission is added.")
  ++ (forMission model)

  ++ (rubric "Here may be sung a hymn or anthem.")
  ++ (rubric "The Officiant may invite the People to offer intercessions and thanksgivings. ")
  ++ (rubric "Before the close of the Office one or both of the following may be used")

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

