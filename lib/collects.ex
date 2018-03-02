require IEx
defmodule Collects do
  @default_show true
  def start_link do
    Agent.start_link fn -> build() end, name: __MODULE__
  end
  def identity(), do: Agent.get(__MODULE__, &(&1))
  def get(key) when key |> is_bitstring do
    {instruction, title, collects} =  identity().collects[key]
    cmap = collects
      |> Enum.map( fn({c, pkeys}) -> 
        %{ collect: c, propers: list_propers(pkeys)} 
      end)
    %{ instruction: instruction, title: title, collects: cmap, show: @default_show }
  end
  def get({season, week, _lityear, _date}), do: season <> week |> get
  def get("redLetter", week), do: week |> get
  def get(season, week), do: season <> week |> get

  def proper(key), do: identity().propers[key]
  def list_propers(pkeys) do
    pkeys
    |> Enum.map( fn(key)->
        {title, text} = proper(key)
        %{title: title, text: text}
      end)
  end


  def build do
    # model...
    # {instruction, title, list_of[collect, list_of[propers]]}
    %{ collects: %{
      "advent1" =>
        { "",
          "The First Sunday in Advent",
          [ { "Almighty God, give us grace to cast away the works of darkness, and put on the armor of light, now
                in the time of this mortal life in which your Son Jesus Christ came to visit us in great humility; that in
                the last day, when he shall come again in his glorious majesty to judge both the living and the dead,
                we may rise to the life immortal; through him who lives and reigns with you and the Holy Spirit, one
                God, now and forever. Amen.",
              [:advent]
            }
          ]
        },
      "advent2" =>
        { "", 
          "The Second Sunday in Advent",
          [ { "Blessed Lord, who caused all holy Scriptures to be written for our learning: Grant us so to hear them,
                read, mark, learn, and inwardly digest them, that by patience and the comfort of your Holy Word we
                may embrace and ever hold fast the blessed hope of everlasting life, which you have given us in our
                Savior Jesus Christ; who lives and reigns with you and the Holy Spirit, one God, for ever and ever.
                Amen.",
              [:advent]
            }
          ]
        },
      "advent3" =>
        { "",
          "The Third Sunday in Advent",
          [ { "Lord Jesus Christ, who sent your messengers the prophets to preach repentance and prepare the way
                for our salvation: Grant that the ministers and stewards of your mysteries may likewise make ready
                your way, by turning the hearts of the disobedient to the wisdom of the just, that at your second
                coming to judge the world, we may be found a people acceptable in your sight; who with the Father
                and the Holy Spirit, lives and reigns, one God, now and forever. Amen.",
              [:advent]
            }
          ]
        },
      "advent4" =>
        { "Wednesday, Friday, and Saturday of this week are the traditional Winter Ember Days.",
          "The Fourth Sunday in Advent [Annunciation]",
          [ { "Stir up your power, O Lord, and with great might come among us; and as we are sorely hindered by
                our sins from running the race that is set before us, let your bountiful grace and mercy speedily help
                and deliver us; through Jesus Christ our Lord, to whom, with you and the Holy Spirit, be honor and
                glory, now and forever. Amen",
              [:advent]
            }
          ]
        },
      "christmasEve" =>
        { "",
          "Christmas Eve",
          [ { "O God, you have caused this holy night to shine with the brightness of the true Light: Grant that we,
                who have known the revelation of that Light on earth, may also enjoy him perfectly in heaven; where 
                with you and the Holy Spirit he lives and reigns, one God, in glory everlasting. Amen.",
              [:incarnation]
            }
          ]
        },
      "christmasDay1" =>
        { "This Collect and any of the sets of Proper Lessons for Christmas Day serve for any weekdays between Holy
            Innocents’ Day and the First Sunday of Christmas
            When Christmas Day falls on a Sunday, subsequent Sundays are Sundays after Christmas.",
            "Christmas Day",
          [ { "Almighty God, you have given your only-begotten Son to take our nature upon him, and to be born
                [this day] of a pure virgin: Grant that we, who have been born again and made your children by
                adoption and grace, may daily be renewed by your Holy Spirit; through our Lord Jesus Christ, to
                whom with you and the same Spirit be honor and glory, now and forever. Amen.",
              [:incarnation]
            }
          ]
        },
      "christmas1" =>
        { "",
          "The First Sunday of Christmas",
          [ { "Almighty God, you have poured upon us the new light of your incarnate Word: Grant that this light,
                enkindled in our hearts, may shine forth in our lives; through Jesus Christ our Lord, who lives and
                reigns with you, in the unity of the Holy Spirit, one God, now and forever. Amen.",
              [:incarnation]
            }
          ]
        },
      "holyName1" =>
        { "",
          "The Holy Name of Our Lord Jesus Christ [January 1]",
          [ { "Almighty God, whose blessed Son was circumcised for our sake in obedience to the Covenant of
                Moses, and given the Name that is above every name: give us the grace to faithfully bear his Name,
                to worship him in the Spirit given in the New Covenant, and to proclaim him as the Savior of the
                world; who lives and reigns with you, in the unity of the Holy Spirit, one God, now and forever.
                Amen.",
                []
              }
            ]
          },
      "christmas2" =>
        { "",
          "The Second Sunday of Christmas",
          [ { "O God, who wonderfully created, and yet more wonderfully restored, the dignity of human nature:
                Grant that we may share the divine life of him who humbled himself to share our humanity, your
                Son Jesus Christ; who lives and reigns with you, in the unity of the Holy Spirit, one God, for ever
                and ever. Amen.",
              [:incarnation]
            }
          ]
        },
      "theEpiphany1" =>
        { "The Collect, with the Psalm and Lessons for the Epiphany, or those for the Second Sunday after Christmas, serves for
            weekdays between the Epiphany and the following Sunday.
            When the Epiphany falls on a Sunday, subsequent Sundays are Sundays after Epiphany.",
            "The Epiphany, or the Manifestation of Christ to the Gentiles [January 6]",
          [ { "O God, by the leading of a star you manifested your only Son to the peoples of the earth: Lead us,
                who know you now by faith, to your presence, where we may see your glory face to face; through
                Jesus Christ our Lord, who lives and reigns with you and the Holy Spirit, one God, now and forever.
                Amen.",
              [:epiphany]
            }
          ]
        },
      "epiphany0" =>
        { "The Collect, with the Psalm and Lessons for the Epiphany, or those for the Second Sunday after Christmas, serves for
            weekdays between the Epiphany and the following Sunday.
            When the Epiphany falls on a Sunday, subsequent Sundays are Sundays after Epiphany.",
            "The Epiphany, or the Manifestation of Christ to the Gentiles [January 6]",
          [ { "O God, by the leading of a star you manifested your only Son to the peoples of the earth: Lead us,
                who know you now by faith, to your presence, where we may see your glory face to face; through
                Jesus Christ our Lord, who lives and reigns with you and the Holy Spirit, one God, now and forever.
                Amen.",
              [:epiphany]
            }
          ]
        },
      "epiphany1" =>
        { "",
          "The First Sunday of Epiphany [Baptism of Our Lord]",
          [ { "Eternal Father, who at the baptism of Jesus revealed him to be your Son, anointing him with the
                Holy Spirit: grant to us, who are born again by water and the Spirit, that we may be faithful to our
                calling as your adopted children; through Jesus Christ your Son our Lord, who is alive and reigns
                with you, in the unity of the Holy Spirit, one God, now and forever. Amen.",
              [:epiphany]
            }
          ]
        },
      "epiphany2" =>
        { "",
          "The Second Sunday of Epiphany",
          [ { "Almighty God, whose Son our Savior Jesus Christ is the light of the world: Grant that your people,
                illumined by your Word and Sacraments, may shine with the radiance of Christ’s glory, that he may
                be known, worshiped, and obeyed to the ends of the earth; through Jesus Christ our Lord, who with
                you and the Holy Spirit lives and reigns, one God, now and forever. Amen.",
              [:epiphany]
            }
          ]
        },
      "epiphany3" =>
        { "",
          "The Third Sunday of Epiphany",
          [ { "Give us grace, O Lord, to answer readily the call of our Savior Jesus Christ and proclaim to all people
                the Good News of his salvation, that we and the whole world may perceive the glory of his
                marvelous works; who lives and reigns with you and the Holy Spirit, one God, for ever and ever.
                Amen.",
              [:epiphany]
            }
          ]
        },
      "epiphany4" =>
        { "",
          "The Fourth Sunday of Epiphany",
          [ { "O God, you know that we are set in the midst of so many and grave dangers that in the frailty of our
                nature we cannot always stand upright: Grant us your strength and protection to support us in all
                dangers and carry us through every temptation; through Jesus Christ our Lord, who lives and reigns
                with you and the Holy Spirit, one God, world without end. Amen.",
              [:epiphany]
            }
          ]
        },
      "presentation" =>
        { "",
          "The Presentation of Christ in the Temple [February 2]",
          [ { "Almighty and everliving God, we humbly pray that, as your only-begotten Son was this day presented
                in the temple in the substance of our flesh, so we may be presented to you with pure and clean hearts
                by Jesus Christ our Lord; who lives and reigns with you and the Holy Spirit, one God, now and
                forever. Amen.",
              [:epiphany]
            }
          ]
        },
      "epiphany5" =>
        { "The pre-Lenten “-gesimas” may be observed on the last three Sundays before Lent",
          "The Fifth Sunday of Epiphany",
          [ { "O Lord, our Creator and Redeemer, we ask you to keep your household the Church continually in
                your true religion; so that we who trust in the hope of your heavenly grace may always be defended
                by your mighty power; through Jesus Christ our Lord, who lives and reigns with you and the Holy
                Spirit, both now and forever. Amen",
              [:lordsDay, :epiphany]
            }
          ]
        },
      "epiphany6" =>
        { "The pre-Lenten “-gesimas” may be observed on the last three Sundays before Lent",
          "The Sixth Sunday of Epiphany",
          [ { "Almighty God, we ask you mercifully to look upon your people; that by your great goodness they
                may be governed and preserved evermore; through Jesus Christ our Lord, who lives and reigns with
                you and the Holy Spirit, now and forever. Amen.",
              [:lordsDay,:epiphany]
            }
          ]
        },
      "epiphany7" =>
        { "The pre-Lenten “-gesimas” may be observed on the last three Sundays before Lent",
          "The Seventh Sunday of Epiphany", 
          [ { "O God, the strength of all who put their trust in you: mercifully accept our prayers, and because
                through the weakness of our mortal nature we can do no good thing without you, grant us the help
                of your grace to keep your commandments; so that we may please you in will and deed; we ask this
                through Jesus Christ our Lord. Amen.",
              [:lordsDay, :epiphany]
            }
          ]
        },
      "epiphany8" =>
        { "The pre-Lenten “-gesimas” may be observed on the last three Sundays before Lent",
          "The Eighth Sunday of Epiphany",
          [ { "Lord God, you know that without your grace we cannot put our trust in anything that we do; defend
                us, by your mighty power, from all adversities which might assault and hurt our souls; we ask this
                through Jesus Christ our Lord, who with you and the Holy Spirit, lives and reigns as one God, now
                and forever. Amen.",
              [:lordsDay,:epiphany]
            }
          ]
        },
      "missionSunday" =>
        {"The pre-Lenten “-gesimas” may be observed on the last three Sundays before Lent\\n
        This collect, with corresponding psalms and lessons, may be substituted for any Sunday of Epiphany, except the First
        or the Last.",
        "The Second to last Sunday of Epiphany [Mission Sunday]",
        [{"Give us grace, O Lord, to answer readily the call of our Savior Jesus Christ and proclaim to all people
        the Good News of his salvation, that we and the whole world may perceive the glory of his
        marvelous works; who lives and reigns with you and the Holy Spirit, one God, for ever and ever.
        Amen.",
        [:epiphany]
      }
    ]
  },
      "epiphany9" =>
        { "",
          "The Last Sunday of Epiphany [Transfiguration]",
          [ { "O God, who before the passion of your only-begotten Son revealed his glory upon the holy
                mountain: Grant that we, beholding by faith the light of his countenance, may be strengthened to
                bear our cross, and be changed into his likeness from glory to glory; through Jesus Christ our Lord,
                who lives and reigns with you and the Holy Spirit, one God, for ever and ever. Amen.",
              [:epiphany]
            }
          ]
        },
      "ashWednesday1" =>
        { "This Collect, with the corresponding Psalm and Lessons, also serves for the weekdays which follow, except as otherwise
            appointed.",
          "Ash Wednesday",
          [ { "Almighty and everlasting God, you hate nothing you have made and forgive the sins of all who are
                penitent: Create and make in us new and contrite hearts, that we, worthily lamenting our sins and
                acknowledging our wretchedness, may obtain of you, the God of all mercy, perfect remission and
                forgiveness; through Jesus Christ our Lord, who lives and reigns with you and the Holy Spirit, one
                God, for ever and ever. Amen.",
              [:lent]
            }
          ]
        },
      "lent1" =>
        { "Wednesday, Friday, and Saturday of this week are the traditional Spring Ember Days.",
          "The First Sunday in Lent",
          [ { "Almighty God, whose blessed Son was led by the Spirit to be tempted by Satan: Come quickly to
                help us who are assaulted by many temptations; and, as you know the weaknesses of each of us, let
                each one find you mighty to save; through Jesus Christ your Son our Lord, who lives and reigns with
                you and the Holy Spirit, one God, now and forever. Amen.",
              [:lent]
            }
          ]
        },
      "lent2" =>
        { "",
          "The Second Sunday in Lent",
          [ { "Almighty God, you know that we have no power in ourselves to help ourselves: Keep us both
                outwardly in our bodies and inwardly in our souls, that we may be defended from all adversities
                which may happen to the body, and from all evil thoughts which may assault and hurt the soul;
                through Jesus Christ our Lord, who lives and reigns with you and the Holy Spirit, one God, for ever
                and ever. Amen.",
              [:lent]
            }
          ]
        },
      "lent3" =>
        { "",
          "The Third Sunday in Lent",
          [ { "Heavenly Father, you made us for yourself, and our hearts are restless until they rest in you: Look
                upon the heartfelt desires of your humble servants, and stretch forth the strong hand of your Majesty
                to be our defense against our enemies; through Jesus Christ our Lord, who lives and reigns with you
                and the Holy Spirit, world without end. Amen.",
              [:lent]
            }
          ]
        },
      "lent4" =>
        { "",
          "The Fourth Sunday in Lent",
          [ { "Gracious Father, whose blessed Son Jesus Christ came down from heaven to be the true bread which
                gives life to the world: Evermore give us this bread, that he may live in us, and we in him; who lives
                and reigns with you and the Holy Spirit, one God, now and forever. Amen.",
              [:lent]
            }
          ]
        },
      "lent5" =>
        { "",
          "The Fifth Sunday in Lent [Passion Sunday]",
          [ { "Almighty God, you alone can bring into order the unruly wills and affections of sinners: Grant your
                people grace to love what you command and desire what you promise; that, among the swift and
                varied changes of this world, our hearts may surely there be fixed where true joys are to be found;
                through Jesus Christ our Lord, who lives and reigns with you and the Holy Spirit, one God, now and
                forever. Amen.",
              [:lent]
            }
          ]
        },
      "palmSunday1" =>
        { "",
          "Palm Sunday",
          [ { "Almighty and everliving God, in your tender love for the human race you sent your Son our Savior
                Jesus Christ to take upon himself our nature, and to suffer death upon the cross, giving us the
                example of his great humility: Mercifully grant that we may walk in the way of his suffering, and also
                share in his resurrection; through Jesus Christ our Lord, who lives and reigns with you and the Holy
                Spirit, one God, for ever and ever. Amen.",
              [:holyWeek]
            }
          ]
        },
      "holyWeek1" =>
        { "",
          "Monday of Holy Week",
          [ { "Almighty God, whose most dear Son went not up to joy but first he suffered pain, and entered not
                into glory before he was crucified: Mercifully grant that we, walking in the way of the cross, may find
                it none other than the way of life and peace; through Jesus Christ your Son our Lord. Amen",
              [:holyWeek]
            }
          ]
        },
      "holyWeek2" =>
        { "",
          "Tuesday of Holy Week",
          [ { "Lord our God, whose blessed Son our Savior gave his back to be whipped and did not hide his face
                from shame and spitting: Give us grace to accept joyfully the sufferings of the present time,
                confident of the glory that shall be revealed; through Jesus Christ your Son our Lord. Amen.",
              [:holyWeek]
            }
          ]
        },
      "holyWeek3" =>
        { "",
          "Wednesday of Holy Week",
          [ { "Assist us mercifully with your grace, Lord God of our salvation; that we may enter with joy upon the
                meditation of those mighty acts by which you have promised us life and immortality; through Jesus
                Christ our Lord. Amen.",
              [:holyWeek]
            }
          ]
        },
      "holyWeek4" =>
        { "",
          "Maundy Thursday",
          [ { "Almighty Father, whose dear Son, on the night before he suffered, instituted the Sacrament of his
                Body and Blood: Mercifully grant that we may receive it thankfully in remembrance of Jesus Christ
                our Lord, who in these holy mysteries gives us a pledge of eternal life; and who now lives and reigns
                with you and the Holy Spirit, one God, for ever and ever. Amen.",
              [:maundyThursday]
            }
          ]
        },
      "holyWeek5" =>
        { "",
          "Good Friday",
          [ { "Almighty God, we pray you graciously to behold this your family, for whom our Lord Jesus Christ
                was willing to be betrayed, and given into the hands of sinners, and to suffer death upon the cross;
                who now lives and reigns with you and the Holy Spirit, one God, for ever and ever. Amen.",
              []
            }
          ]
        },
      "holyWeek6" =>
        { "",
          "Holy Saturday",
          [ { "O God, Creator of heaven and earth: Grant that, as the crucified body of your dear Son was laid in
                the tomb and rested on this holy Sabbath, so we may await with him the coming of the third day, and
                rise with him to newness of life; who now lives and reigns with you and the Holy Spirit, one God, for
                ever and ever. Amen.",
              []
            }
          ]
        },
      "easterDayVigil1" =>
        { "",
          "Easter Eve",
          [ { "Grant us, dear Lord, your grace: that as we are baptized into the death of your Son our Savior Jesus
                Christ, and our corrupt affections buried with him, we may pass through the grave and gate of death,
                and rise with him to our joyful resurrection; who now is alive and reigns with you and the Holy Spirit
                in everlasting glory. Amen.",
              [:easter]
            },
            { "O God, who made this most holy night to shine with the glory of the Lord’s resurrection: Stir up in
                your Church that Spirit of adoption which is given to us in Baptism, that we, being renewed both in
                body and mind, may worship you in sincerity and truth; through Jesus Christ our Lord, who lives and
                reigns with you, in the unity of the Holy Spirit, one God, now and forever. Amen.",
              [:easter]
            }
          ]
        },
      "easterDay1" =>
        { "",
          "Easter Day",
          [ { "Almighty God, who through your only-begotten Son Jesus Christ overcame death and opened to us
                the gate of everlasting life: Grant that we, who celebrate with joy the day of the Lord’s resurrection,
                may be raised from the death of sin by your life-giving Spirit; through Jesus Christ our Lord, who
                lives and reigns with you and the Holy Spirit, one God, now and forever. Amen.",
              [:easter]
            },
            { "O God, who for our redemption gave your only begotten Son to die upon the cross, and by his
                glorious resurrection delivered us from the power of death and the devil: Grant us the grace to die
                daily to sin, that we may live with him in the joy of his resurrection, through the same, Jesus Christ
                our Lord, who lives and reigns with you and the Holy Spirit now and forever. Amen",
              [:easter]
            }
          ]
        },
      "easterWeek1" =>
        { "",
          "Monday of Easter Week",
          [ { "Grant, we pray, Almighty God, that we who celebrate with awe the Paschal feast may be found
                worthy to attain to everlasting joys; through Jesus Christ our Lord, who lives and reigns with you and
                the Holy Spirit, one God, now and forever. Amen.",
              [:easter]
            }
          ]
        },
      "easterWeek2" =>
        { "",
          "Tuesday of Easter Week",
          [ { "O God, who by the glorious resurrection of your Son Jesus Christ destroyed death and brought life
                and immortality to light: Grant that we, who have been raised with him, may abide in his presence
                and rejoice in the hope of eternal glory; through Jesus Christ our Lord, to whom, with you and the
                Holy Spirit, be dominion and praise for ever and ever. Amen.",
              [:easter]
            }
          ]
        },
      "easterWeek3" =>
        { "",
          "Wednesday of Easter Week",
          [ { "O God, whose blessed Son made himself known to his disciples in the breaking of bread: Open the
                eyes of our faith, that we may behold him in all his redeeming work; who lives and reigns with you, in
                the unity of the Holy Spirit, one God, now and forever. Amen.",
              [:easter]
            }
          ]
        },
      "easterWeek4" =>
        { "",
          "Thursday of Easter Week",
          [ { "Almighty God, you show those in error the light of your truth so that they may return to the path of
                righteousness: Grant that all who have been reborn into the fellowship of Christ’s Body may show
                forth in their lives what they profess by their faith; through Jesus Christ our Lord, who lives and
                reigns with you and the Holy Spirit, one God, now and forever. Amen.",
              [:easter]
            }
          ]
        },
      "easterWeek5" =>
        { "",
          "Friday of Easter Week",
          [ { "Almighty Father, who gave your only Son to die for our sins and to rise for our justification: Give us
                grace so to put away the leaven of malice and wickedness, that we may always serve you in pureness
                of living and truth; through Jesus Christ your Son our Lord, who lives and reigns with you and the
                Holy Spirit, one God, now and forever. Amen.",
              [:easter]
            }
          ]
        },
      "easterWeek6" =>
        { "",
          "Saturday of Easter Week",
          [ { "We thank you, heavenly Father, that you have delivered us from the dominion of sin and death and
                brought us into the kingdom of your Son; and we pray that, as by his death he has recalled us to life,
                so by his love he may raise us to eternal joys; who lives and reigns with you, in the unity of the Holy
                Spirit, one God, now and forever. Amen.",
              [:easter]
            }
          ]
        },
      "easter2" =>
        { "",
          "The Second Sunday of Easter",
          [ { "Almighty and everlasting God, who in the Paschal mystery established the new covenant of
                reconciliation: Grant that all who have been reborn into the fellowship of Christ’s Body may show 
                forth in their lives what they profess by their faith; through Jesus Christ our Lord, who lives and
                reigns with you and the Holy Spirit, one God, for ever and ever. Amen.",
              [:easter]
            }
          ]
        },
      "easter3" =>
        { "",
          "The Third Sunday of Easter",
          [ { "Almighty God, you gave your only Son to be for us both a sacrifice for sin and an example of godly
                living: Give us the grace thankfully to receive this his inestimable benefit, and daily to follow the
                blessed steps of his most holy life; through Jesus Christ our Lord. Amen",
              [:easter]
            }
          ]
        },
      "easter4" =>
        { "",
          "The Fourth Sunday of Easter [Good Shepherd]",
          [ { "O God, whose Son Jesus is the good shepherd of your people: Grant that when we hear his voice we
                may know him who calls us each by name, and follow where he leads; who, with you and the Holy
                Spirit, lives and reigns, one God, for ever and ever. Amen.",
              [:easter]
            }
          ]
        },
      "easter5" =>
        { "",
          "The Fifth Sunday of Easter",
          [ { "Almighty God, whom truly to know is everlasting life: Grant us so perfectly to know your Son Jesus
                Christ to be the way, the truth, and the life, that we may steadfastly follow his steps in the way that
                leads to eternal life; through Jesus Christ your Son our Lord, who lives and reigns with you, in the
                unity of the Holy Spirit, one God, for ever and ever. Amen.",
              [:easter]
            }
          ]
        },
      "easter6" =>
        { "Monday, Tuesday, and Wednesday of this week are the traditional Rogation Days.",
          "The Sixth Sunday of Easter [Rogation]",
          [ { "O God, you have prepared for those who love you such good things as surpass our understanding:
                Pour into our hearts such love towards you, that we, loving you in all things and above all things,
                may obtain your promises, which exceed all that we can desire; through Jesus Christ our Lord, who
                lives and reigns with you and the Holy Spirit, one God, for ever and ever. Amen.",
              [:easter]
            }
          ]
        },
      "ascension1" =>
        { "",
          "Ascension Day",
          [ { "Grant, we pray, Almighty God, that as we believe your only-begotten Son our Lord Jesus Christ to
                have ascended into heaven, so we may also in heart and mind there ascend, and with him continually
                dwell; who lives and reigns with you and the Holy Spirit, one God, for ever and ever. Amen.",
              [:ascension]
            }
          ]
        },
      "easter7" =>
        { "",
          "The Sunday after the Ascension",
          [ { "O God, the King of glory, you have exalted your only Son Jesus Christ with great triumph to your
                kingdom in heaven: Do not leave us comfortless, but send us your Holy Spirit to strengthen us, and
                exalt us to that place where our Savior Christ has gone before; who lives and reigns with you and the 
                Holy Spirit, one God, in glory everlasting. Amen.",
              [:ascension]
            }
          ]
        },
      "pentecost1" =>
        { "",
          "Day of Pentecost (Whitsunday)",
          [ { "Almighty God, on this day you opened the way of eternal life to every race and nation by the
                promised gift of your Holy Spirit: Shed abroad this gift throughout the world by the preaching of the
                Gospel, that it may reach to the ends of the earth; through Jesus Christ our Lord, who lives and
                reigns with you, in the unity of the Holy Spirit, one God, for ever and ever. Amen.",
              [:pentecost]
            },
            {"O God, who on this day taught the hearts of your faithful people by sending to them the light of
                your Holy Spirit: Grant us by the same Spirit to have a right judgment in all things, and evermore to
                rejoice in his holy comfort; through Jesus Christ your Son our Lord, who lives and reigns with you, in
                the unity of the Holy Spirit, one God, for ever and ever. Amen.",
              [:pentecost]
            }
          ]
        },
      "pentecostWeekday1" =>
        { "The Wednesday, Friday and Saturday of this week are the traditional Summer Ember Days.",
          "Weekdays of Whitsun Week",
          [ { "Almighty God, send your Holy Spirit into our hearts, that he may direct and rule us according to
                your will; comfort us in our afflictions, defend us from all error, and lead us into all truth; through
                Jesus Christ our Lord, who with you and the same Spirit, lives and reigns, one God, world without
                end. Amen.",
              [:pentecost]
            },
            { "Grant, O merciful God, that your Church, being gathered together in unity by your Holy Spirit, may
                show forth your power among all peoples, to the glory of your Name; through Jesus Christ our Lord,
                who lives and reigns with you and the Holy Spirit, one God, for ever and ever. Amen.",
              [:pentecost]
            }
          ]
        },
      "trinity1" =>
        { "The readings for the early Sundays after Trinity Sunday are those not previously used for Sundays after the Feast of the Presentation in Epiphany.",
          "Trinity Sunday",
          [ { "Almighty and everlasting God, you have given to us your servants grace, by the confession of a true
                faith, to acknowledge the glory of the eternal Trinity, and in the power of your divine Majesty to
                worship the Unity: Keep us steadfast in this faith and worship, and bring us at last to see you in your
                one and eternal glory, O Father; who with the Son and the Holy Spirit live and reign, one God, for
                ever and ever. Amen.",
              [:trinitySunday]
            }
          ]
        },
      "proper1" =>
        { "",
          "Week of the Sunday closest to May 11",
          [ { "O God, the strength of all who put their trust in you: Mercifully accept our prayers, and because
                through the weakness of our mortal nature we can do no good thing without you, grant us the help
                of your grace to keep your commandments, that we may please you in will and deed; through Jesus
                Christ our Lord. Amen.",
              [:lordsDay]
            }
          ]
        },
      "proper2" =>
        { "",
          "Week of the Sunday closest to May 18",
          [ { "O Lord, you never fail to support and govern those whom you bring up in your steadfast fear and
                love: Keep us, we pray, under your continual protection and providence, and give us a perpetual fear
                and love of your Name; through Jesus Christ our Lord. Amen",
              [:lordsDay]
            }
          ]
        },
      "proper3" =>
        { "",
          "Week of the Sunday closest to May 25",
          [ { "O Lord, we ask you mercifully to hear us, and grant that we, to whom you have given the desire to
                pray, may by your mighty aid be defended and comforted in all our adversities; through Jesus Christ
                our lord. Amen.",
              [:lordsDay]
            }
          ]
        },
      "proper4" =>
        { "",
          "Week of the Sunday closest to June 1",
          [ { "O God, the protector of all those who trust in you, without whom nothing is strong, nothing is holy:
                Increase and multiply in us your mercy, that, with you as our ruler and guide, we may so pass through
                things temporal that we lose not the things eternal; grant this, heavenly Father, for the sake of your
                Son, Jesus Christ. Amen",
              [:lordsDay]
            }
          ]
        },
      "proper5" =>
        { "",
          "Week of the Sunday closest to June 8",
          [ { "Grant, O Lord, that the course of this world may be so peaceably ordered in your providence, that
                your Church may joyfully serve you in all godly quietness and peace; through Jesus Christ our Lord.
                Amen.",
              [:lordsDay]
            }
          ]
        },
      "proper6" =>
        { "",
          "Week of the Sunday closest to June 15",
          [ { "O Lord, from whom comes all good things; grant us, your humble servants, the inspiration to always
                think and do those things which are good, and by your merciful guiding we may perform the same;
                through Jesus Christ our lord. Amen.",
              [:lordsDay]
            }
          ]
        },
      "proper7" =>
        { "",
          "Week of the Sunday closest to June 22",
          [ { "Lord of all power and might, the author and giver of all good things: Graft in our hearts the love of
                your Name, increase in us true religion, nourish us with all goodness, and bring forth in us the fruit
                of good works; through Jesus Christ our Lord, who lives and reigns with you and the Holy Spirit, one
                God for ever and ever. Amen.",
              [:lordsDay]
            }
          ]
        },
      "proper8" =>
        { "",
          "Week of the Sunday closest to June 29",
          [ { "O God, your never-failing providence sets in order all things both in heaven and on earth: Put away
                from us all hurtful things, and give us those things which are profitable for us; through Jesus Christ
                our Lord, who lives and reigns with you and the Holy Spirit, one God, for ever and ever. Amen.",
              [:lordsDay]
            }
          ]
        },
      "proper9" =>
        { "",
          "Week of the Sunday closest to July 6",
          [ { "Grant us, Lord, we pray, the spirit to think and do always those things that are right, that we, who
                cannot exist without you, may by you be enabled to live according to your will; through Jesus Christ
                our Lord, who lives and reigns with you and the Holy Spirit, one God, for ever and ever. Amen.",
              [:lordsDay]
            }
          ]
        },
      "proper10" =>
        { "",
          "Week of the Sunday closest to July 13",
          [ { "Hear us, O Lord, when we cry out to you; and that we might receive what we ask, enable us by your
                Holy Spirit to ask only what accords with your will; through Jesus Christ our Lord, who with you and
                the same Spirit lives and reigns for ever and ever. Amen.",
              [:lordsDay]
            }
          ]
        },
      "proper11" =>
        { "",
          "Week of the Sunday closest to July 20",
          [ { "O God, you declare your almighty power chiefly in showing mercy and pity: Grant us the fullness of
                your grace, that we, running to obtain your promises, may become partakers of your heavenly
                treasure; through Jesus Christ our Lord, who lives and reigns with you and the Holy Spirit, one God,
                for ever and ever. Amen.",
              [:lordsDay]
            }
          ]
        },
      "proper12" =>
        { "",
          "Week of the Sunday closest to July 27",
          [ { "Almighty and everlasting God, you are always more ready to hear than we to pray, and to give more
                than we either desire or deserve: Pour upon us the abundance of your mercy, forgiving us those
                things of which our conscience is afraid, and giving us those good things for which we are not
                worthy to ask, except through the merits and mediation of Jesus Christ our Savior; who lives and
                reigns with you and the Holy Spirit, one God, for ever and ever. Amen.",
              [:lordsDay]
            }
          ]
        },
      "proper13" =>
        { "",
          "Week of the Sunday closest to August 3",
          [ { "Almighty and merciful God, it is only by your grace that your faithful people offer you true and
                laudable service: Grant that we may run without stumbling to obtain your heavenly promises;
                through Jesus Christ our Lord, who lives and reigns with you and the Holy Spirit, one God, now and
                forever. Amen.",
              [:lordsDay]
            }
          ]
        },
      "proper14" =>
        { "",
          "Week of the Sunday closest to August 10",
          [ { "Almighty God, give us the increase of faith, hope, and love; and, so that we may obtain what you
                have promised, make us love what you command; through Jesus Christ our Lord. Amen.",
              [:lordsDay]
            }
          ]
        },
      "proper15" =>
        { "",
          "Week of the Sunday closest to August 17",
          [ { "Keep your Church in safety, O Lord; for without your grace the frailty of our nature cannot but
                make us fall; but in your mercy keep us from all things hurtful, and lead us in all things profitable for
                our salvation; through Jesus Christ our Lord. Amen.",
              [:lordsDay]
            }
          ]
        },
      "proper16" =>
        { "",
          "Week of the Sunday closest to August 24",
          [ { "Let your continual mercy, O Lord, cleanse and defend your Church; and, because it cannot continue
                in safety without your help, protect and govern it always by your goodness; through Jesus Christ our
                Lord, who lives and reigns with you and the Holy Spirit, one God, for ever and ever. Amen.",
              [:lordsDay]
            }
          ]
        },
      "proper17" =>
        { "",
          "Week of the Sunday closest to August 31",
          [ { "O Lord, we pray that your grace may always both precede and follow after us, that we may
                continually be given to good works; through Jesus Christ our Lord, who lives and reigns with you
                and the Holy Spirit, one God, now and forever. Amen.",
              [:lordsDay]
            }
          ]
        },
      "proper18" =>
        { "",
          "Week of the Sunday closest to September 7",
          [ { "Lord God, grant your people grace to withstand the temptations of the world, the flesh, and the
                devil; that we may love you faithfully with all our heart and soul and mind and strength; through
                Jesus Christ our Lord, who lives and reigns with you and the Holy Spirit, one God, now and forever.
                Amen.",
              [:lordsDay]
            }
          ]
        },
      "proper19" =>
        { "Wednesday, Friday, and Saturday after September 14 are the traditional autumnal Ember Days.",
          "Week of the Sunday closest to September 14",
          [ { "O God, because without you we are not able to please you, mercifully grant that your Holy Spirit
                may in all things direct and rule our hearts; through Jesus Christ our Lord, who lives and reigns with
                you and the Holy Spirit, one God, now and forever. Amen.",
              [:lordsDay]
            }
          ]
        },
      "proper20" =>
        { "",
          "Week of the Sunday closest to September 21",
          [ { "Almighty and merciful God, in your goodness keep us, we pray, from all things that may hurt us, that
                we, being ready both in mind and body, may accomplish with free hearts those things which belong
                to your purpose; through Jesus Christ our Lord, who lives and reigns with you and the Holy Spirit,
                one God, now and forever. Amen.",
              [:lordsDay]
            }
          ]
        },
      "proper21" =>
        { "",
          "Week of the Sunday closest to September 28",
          [ { "Merciful Lord, grant to your faithful people pardon and peace; that by your grace we may be cleansed
                from all our sins and serve you with a quiet mind; through Jesus Christ our Lord, who lives and
                reigns with you and the Holy Spirit, one God, now and forever. Amen.",
              [:lordsDay]
            }
          ]
        },
      "proper22" =>
        { "",
          "Week of the Sunday closest to October 5",
          [ { "Keep, O Lord, your household the Church in continual godliness; that through your protection it
                may be free from all adversities, and devotedly serve you in good works, to the glory of your Name;
                through Jesus Christ our Lord, who lives and reigns with you and the Holy Spirit, one God, now and
                forever. Amen.",
              [:lordsDay]
            }
          ]
        },
      "proper23" =>
        { "",
          "Week of the Sunday closest to October 12",
          [ { "God, our refuge and strength, true source of all godliness: Graciously hear the devout prayers of your
                Church, and grant that those things which we ask faithfully we may obtain effectually; through Jesus
                Christ our Lord, who sits at your right hand to intercede for us, and who with you and the Holy
                Spirit lives and reigns in everlasting glory. Amen.",
              [:lordsDay]
            }
          ]
        },
      "proper24" =>
        { "",
          "Week of the Sunday closest to October 19",
          [ { "Set us free, loving Father, from the bondage of our sins, and in your goodness and mercy give us the
                liberty of that abundant life which you have made known to us in our Savior Jesus Christ; who lives
                and reigns with you, in the unity of the Holy Spirit, one God, now and forever. Amen.",
              [:lordsDay]
            }
          ]
        },
      "proper25" =>
        { "",
          "Week of the Sunday closest to October 26",
          [ { "Almighty and everlasting God, you govern all things both in heaven and on earth: Mercifully hear the
                supplications of your people, and in our time grant us your peace; through Jesus Christ our Lord,
                who lives and reigns with you and the Holy Spirit, one God, for ever and ever. Amen.",
              [:lordsDay]
            }
          ]
        },
      "allSaints" =>
        { "",
          "All Saints’ Day [November 1]",
          [ { "Almighty God, you have knit together your elect in one communion and fellowship in the mystical
                body of your Son Christ our Lord: Give us grace so to follow your blessed saints in all virtuous and
                godly living, that we may come to those ineffable joys that you have prepared for those who truly
                love you; through Jesus Christ our Lord, who with you and the Holy Spirit lives and reigns, one God,
                in glory everlasting. Amen.",
              [:allSaints]
            }
          ]
        },
      "proper26" =>
        { "",
          "Week of the Sunday closest to November 2 ",
          [ { "Grant us, Lord, not to be anxious about earthly things, but to love things heavenly; and even now,
                while we are placed among things that are passing away, to hold fast to those that shall endure;
                through Jesus Christ our Lord, who lives and reigns with you and the Holy Spirit, one God, for ever
                and ever. Amen.",
              [:lordsDay]
            }
          ]
        },
      "proper27" =>
        { "",
          "Week of the Sunday closest to November 9",
          [ { "O God, whose blessed Son came into the world that he might destroy the works of the devil and
                make us children of God and heirs of eternal life: Grant that, having this hope, we may purify
                ourselves as he is pure; that, when he comes again with power and great glory, we may be made like
                him in his eternal and glorious kingdom; where he lives and reigns with you and the Holy Spirit, one
                God, for ever and ever. Amen.",
              [:lordsDay]
            }
          ]
        },
      "proper28" =>
        { "",
          "Week of the Sunday closest to November 16",
          [ { "Stir up, O Lord, the wills of your faithful people; that they may plenteously bring forth the fruit of
                good works, as they await the coming of our Lord Jesus Christ to restore all things to their original
                perfection; who with you and the Holy Spirit lives and reigns for ever and ever. Amen.",
              [:lordsDay]
             }
          ]
        },
      "proper29" =>
        { "",
          "Week of the Sunday closest to November 23 [Christ the King]",
          [ { "Almighty and everlasting God, whose will it is to restore all things in your well-beloved Son, the King
                of kings and Lord of lords: Mercifully grant that the peoples of the earth, divided and enslaved by
                sin, may be freed and brought together under his most gracious rule; who lives and reigns with you
                and the Holy Spirit, one God, now and forever. Amen.",
              [:lordsDay]
            }
          ]
        },
      "stAndrew" =>
        { "",
          "Saint Andrew [November 30]",
          [ { "Almighty God, who gave such grace to your apostle Andrew that he readily obeyed the call of your
                Son Jesus Christ, and brought his brother with him: Give us, who are called by your holy Word,
                grace to follow him without delay, and to bring those near to us into his gracious presence; who lives
                and reigns with you and the Holy Spirit, one God, now and forever. Amen.",
              [:apostles]
            }
          ]
        },
      "stThomas" =>
        { "",
          "Saint Thomas [December 21]",
          [ { "Everliving God, who strengthened your apostle Thomas with firm and certain faith in your Son’s
                resurrection: Grant us so perfectly and without doubt to believe in Jesus Christ, our Lord and our
                God, that our faith may never be found wanting in your sight; through him who lives and reigns with 
                you and the Holy Spirit, one God, now and forever. Amen.",
              [:apostles]
            }
          ]
        },
      "stStephen" =>
        { "",
          "Saint Stephen [December 26]",
          [ { "Grant, O Lord, that in all our sufferings here upon earth for the testimony of your truth, we may
                steadfastly look up to heaven, and by faith behold the glory that shall be revealed; and being filled
                with the Holy Spirit, may learn to love and bless our persecutors by the example of your first martyr
                Stephen, who prayed for his murderers as did his Lord and Savior, who now sits at the right hand of
                God to intercede for all who suffer in his Name, and who lives and reigns with the Father and the
                Holy Spirit for ever and ever. Amen.",
              [:incarnation]
            }
          ]
        },
      "stJohn" =>
        { "",
          "Saint John the Evangelist [December 27]",
          [ { "Shed upon your Church, O Lord, the brightness of your light, that we, being illumined by the
                teaching of your apostle and evangelist John, may so walk in the light of your truth, that at length we
                may attain to the fullness of eternal life; through Jesus Christ our Lord, who lives and reigns with you
                and the Holy Spirit, one God, for ever and ever. Amen.",
              [:incarnation]
            }
          ]
        },
      "holyInnocents" =>
        { "",
          "The Holy Innocents [December 28]",
          [ { "Almighty God, out of the mouths of children you manifest your truth, and by the death of the holy
                innocents at the hands of evil tyrants you show your strength in our weakness: We ask you to mortify
                all that is evil within us, and so strengthen us by your grace, that we may glorify your holy Name by
                the innocency of our lives and the constancy of our faith even unto death; through Jesus Christ our
                Lord, who died for us and now lives with you and the Holy Spirit, world without end. Amen.",
              [:incarnation]
            }
          ]
        },
      "confessionOfStPeter" =>
        { "",
          "Confession of Saint Peter [January 18]",
          [ { "Almighty Father, who inspired Simon Peter, first among the apostles, to confess Jesus as Messiah
                and Son of the living God: Keep your Church steadfast upon the rock of this faith, so that in unity
                and peace we may proclaim the one truth and follow the one Lord, our Savior Jesus Christ; who lives
                and reigns with you and the Holy Spirit, one God, now and forever. Amen.",
              [:apostles]
            }
          ]
        },
      "conversionOfStPaul" =>
        { "",
          "Conversion of Saint Paul [January 25]",
          [ { "O God, by the preaching of your apostle Paul you have caused the light of the Gospel to shine
                throughout the world: Grant, we pray, that we, having his wonderful conversion in remembrance,
                may show ourselves thankful to you by following his holy teaching; through Jesus Christ our Lord,
                who lives and reigns with you, in the unity of the Holy Spirit, one God, now and forever. Amen.",
              [:apostles]
            }
          ]
        },
      "stMatthias" =>
        { "",
        # "Within the Sunday Lectionary.",
        # "The Presentation of Christ in the Temple [February 2]",
          "Saint Matthias [February 24]",
          [ { "Almighty God, who in the place of Judas chose your faithful servant Matthias to be numbered
                among the Twelve: Grant that your Church, being delivered from false apostles, may always be
                guided and governed by faithful and true pastors; through Jesus Christ our Lord, who lives and
                reigns with you, in the unity of the Holy Spirit, one God, now and forever. Amen.",
              [:apostles]
            }
          ]
        },
      "stJoseph" =>
        { "",
          "Saint Joseph [March19]",
          [ { "O God, who from the family of your servant David raised up Joseph to be the guardian of your
                incarnate Son and the husband of his virgin mother: Give us grace to imitate his uprightness of life
                and his obedience to your commands; through Jesus Christ our Lord, who lives and reigns with you
                and the Holy Spirit, one God, for ever and ever. Amen.",
              [:epiphany]
            }
          ]
        },
      "annunciation" =>
        { "",
          "The Annunciation March 25",
          [ { "Pour your grace into our hearts, O Lord, that we who have known the incarnation of your Son Jesus
                Christ, announced by an angel to the Virgin Mary, may by his cross and passion be brought to the
                glory of his resurrection; who lives and reigns with you, in the unity of the Holy Spirit, one God, now
                and forever. Amen.",
              [:epiphany]
            }
          ]
        },
      "stMark" =>
        { "",
          "Saint Mark [April 25]",
          [ { "Almighty God, by the hand of Mark the evangelist you have given to your Church the Gospel of
                Jesus Christ: We thank you for his witness, and pray that you will give us the grace to know the truth
                and not be carried about by every wind of false doctrine; so that we may truly and firmly accept Jesus
                Christ as our Lord and Savior, who lives and reigns with you and the Holy Spirit, one God, for ever
                and ever. Amen.",
              [:allSaints]
            }
          ]
        },
      "stsPhilipAndJames" =>
        { "",
          "Saint Philip and Saint James [May 1]",
          [ { "Almighty God, who gave to your apostles Philip and James the grace and strength to bear witness to
                Jesus as the way, the truth, and the life: Grant that we, being mindful of their victory of faith, may
                glorify in life and death the Name of our Lord Jesus Christ; who lives and reigns with you and the
                Holy Spirit, one God, now and forever. Amen.",
              [:apostles]
            }
          ]
        },
      "visitation" =>
        { "",
          "The Visitation [May 31]",
          [ { "Father in heaven, by your grace the virgin mother of your incarnate Son was blessed in bearing him,
                but still more blessed in keeping your word: Grant us who honor the exaltation of her lowliness to
                follow the example of her devotion to your will; through Jesus Christ our Lord, who lives and reigns
                with you and the Holy Spirit, one God, for ever and ever. Amen.",
              [:epiphany]
            }
          ]
        },
      "stBarnabas" =>
        { "",
          "Saint Barnabas [June 11]",
          [ { "Grant, O God, that we may follow the example of your faithful servant Barnabas, who, seeking not
                his own renown but the well-being of your Church, gave generously of his life and substance for the
                relief of the poor and went forth courageously in mission for the spread of the Gospel; through Jesus
                Christ our Lord, who lives and reigns with you and the Holy Spirit, one God, for ever and ever.
                Amen.",
              [:apostles]
            }
          ]
        },
      "nativityOfJohnTheBaptist" =>
        { "",
          "The Nativity of Saint John the Baptist [June 24]",
          [ { "Almighty God, by whose providence your servant John the Baptist was wonderfully born, and sent
                to prepare the way of your Son our Savior by preaching repentance: Make us so to follow his
                teaching and holy life, that we may truly repent according to his preaching; and, following his
                example, constantly speak the truth, boldly rebuke vice, and patiently suffer for the truth’s sake;
                through Jesus Christ your Son our Lord, who lives and reigns with you and the Holy Spirit, one God,
                for ever and ever. Amen.",
              [:advent]
            }
          ]
        },
      "stPeterAndPaul" =>
        { "",
          "Saint Peter and Saint Paul [June 29]",
          [ { "Almighty God, whose blessed apostles Peter and Paul glorified you by their martyrdom: Grant that
                your Church, instructed by their teaching and example, and knit together in unity by your Spirit, may
                ever stand firm upon the one foundation, which is Jesus Christ our Lord; who lives and reigns with
                you, in the unity of the Holy Spirit, one God, now and forever. Amen.",
              [:apostles]
            }
          ]
        },
      "stMaryMagdalene" =>
        { "",
          "Saint Mary Magdalene [July 22]",
          [ { "Almighty God, whose blessed Son restored Mary Magdalene to health of body and of mind, and
                called her to be a witness of his resurrection: Mercifully grant that by your grace we may be healed
                from all our infirmities and know you in the power of his unending life; who with you and the Holy
                Spirit lives and reigns, one God, now and forever. Amen.",
              [:apostles]
            }
          ]
        },
      "stJames" =>
        { "",
          "Saint James [July 25]",
          [ { "O gracious God, we remember before you today your servant and apostle James, first among the
                Twelve to suffer martyrdom for the Name of Jesus Christ; and we pray that you will pour out upon
                the leaders of your Church that spirit of self-denying service by which alone they may have true
                authority among your people; through Jesus Christ our Lord, who lives and reigns with you and the
                Holy Spirit, one God, now and forever. Amen.",
              [:apostles]
            }
          ]
        },
      "transfiguration" =>
        { "",
          "The Transfiguration [August 6]",
          [ { "O God, who on the holy mount revealed to chosen witnesses your well-beloved Son, wonderfully
                transfigured, in raiment white and glistening: Mercifully grant that we, being delivered from the 
                disquietude of this world, may by faith behold the King in his beauty; who with you, O Father, and
                you, O Holy Spirit, lives and reigns, one God, for ever and ever. Amen.",
              [:epiphany]
            }
          ]
        },
      "bvm" =>
        { "",
          "Saint Mary the Virgin [August 15]",
          [ { "O God, you have taken to yourself the blessed Virgin Mary, mother of your incarnate Son: Grant
                that we, who have been redeemed by his blood, may share with her the glory of your eternal
                kingdom; through Jesus Christ our Lord, who lives and reigns with you, in the unity of the Holy
                Spirit, one God, now and forever. Amen.",
              [:incarnation]
            }
          ]
        },
      "stBartholomew" =>
        { "",
          "Saint Bartholomew [August 24]",
          [ { "Almighty and everlasting God, who gave to your apostle Bartholomew grace truly to believe and to
                preach your Word: Grant that your Church may love what he believed and preach what he taught;
                through Jesus Christ our Lord, who lives and reigns with you and the Holy Spirit, one God, for ever
                and ever. Amen.",
              [:apostles]
            }
          ]
        },
      "holyCross" =>
        { "",
          "Holy Cross Day [September 14]",
          [ { "Almighty God, whose Son our Savior Jesus Christ was lifted high upon the cross that he might draw
                the whole world to himself: Mercifully grant that we, who glory in the mystery of our redemption,
                may have grace to take up our cross and follow him; who lives and reigns with you and the Holy
                Spirit, one God, in glory everlasting. Amen.",
              [:holyWeek]
            }
          ]
        },
      "stMatthew" =>
        { "",
          "Saint Matthew [September 21]",
          [ { "Lord Jesus, you called Matthew from collecting taxes to become your apostle and evangelist; grant us
                the grace to forsake all covetous desires and the pursuit of inordinate riches, so that we may also
                follow you as he did and proclaim to the world around us the good news of your salvation; who live
                and reign with the Father and the Holy Spirit, one God, now and forever. Amen.",
              [:apostles]
            }
          ]
        },
      "michaelAllAngels" =>
        { "",
          "Holy Michael and All Angels [September 29]",
          [ { "Everlasting God, you have ordained and constituted in a wonderful order the ministries of angels and
                mortals: Mercifully grant that, as your holy angels always serve and worship you in heaven, so by your
                appointment they may help and defend us here on earth; through Jesus Christ our Lord, who lives
                and reigns with you and the Holy Spirit, one God, for ever and ever. Amen.",
              [:trinitySunday]
            }
          ]
        },
      "stLuke" =>
        { "",
          "Saint Luke [October 18]",
          [ { "Almighty God, you called Luke the physician, to be an evangelist and physician of the soul: We pray
                that we, by the wholesome medicine of the doctrine which he taught, may have all the diseases of our
                souls be healed; through Jesus Christ our Lord, who lives and reigns with you and the Holy Spirit, 
                one God, now and forever. Amen.",
              [:apostles]
            }
          ]
        },
      "stJamesOfJerusalem" =>
        { "",
          "Saint James of Jerusalem [October 23]",
          [ { "Grant, O God, that, following the example of your apostle James the Just, kinsman of our Lord, your
                Church may give itself continually to prayer and to the reconciliation of all who are at variance and
                enmity; through Jesus Christ our Lord, who lives and reigns with you and the Holy Spirit, one God,
                now and forever. Amen.",
              [:apostles]
            }
          ]
        },
      "stsSimonAndJude" =>
        { "",
          "Saint Simon and Saint Jude [October 28]",
          [ { "O God, we thank you for the glorious company of the apostles, and especially on this day for Simon
                and Jude; and we pray that, as they were faithful and zealous in their mission, so we may with ardent
                devotion make known the love and mercy of our Lord and Savior Jesus Christ; who lives and reigns
                with you and the Holy Spirit, one God, for ever and ever. Amen.",
              [:apostles]
            }
          ]
        },
      "dominion" =>
        { "",
          "Dominion Day [Canada on July 1]",
          [ { "Lord God, you provide for your people by your power, and rule over them in love: So bless your
                servant our King/Queen N., and her/his Government in this Dominion of Canada, that your people
                may dwell in peace and safety, and your Church serve you in all godly quietness; through Jesus Christ
                our Lord. Amen.",
              [:trinitySunday]
            }
          ]
        },
      "independence" =>
        { "",
          "Independence Day [United States of America on July 4]",
          [ { "Lord God Almighty, in whose Name the founders of this country won liberty for themselves and for
                us, and lit the torch of freedom for nations then unborn: Grant that we and all the people of this
                land may have grace to maintain our liberties in righteousness and peace; through Jesus Christ our
                Lord, who lives and reigns with you and the Holy Spirit, one God, for ever and ever. Amen.",
              [:trinitySunday]
            }
          ]
        },
      "thanksgiving" =>
        { "",
          "Thanksgiving Day [Canada and United States of America]",
          [ { "Most merciful Father, we humbly thank you for all your gifts so freely bestowed upon us; for life and
                health and safety; for strength to work and leisure to rest; for all that is beautiful in creation and in
                human life; but above all we thank you for our spiritual mercies in Christ Jesus our Lord; who with
                you and the Holy Spirit lives and reigns, one God, for ever and ever. Amen.",
              [:trinitySunday]
            }
          ]
        },
      "remembrance" =>
        { "",
          "Remembrance (Veterans) Day [November 11]",
          [ { "O King and Judge of the nations: We remember before you with grateful hearts the men and women
                of our armed forces, who in the day of decision ventured much for the liberties we now enjoy; grant
                that we may not rest until all the people of this land share the benefits of true freedom and gladly
                accept its disciplines; through Jesus Christ our Lord, who with you and the Holy Spirit, lives and
                reigns, now and forever. Amen.",
              [:ofASaint]
            }
          ]
        },
      "memorial" =>
        { "",
          "Memorial Day [United States of America - Monday nearest May 28]]",
          [ { "O King and Judge of the nations: We remember before you with grateful hearts the men and women
                of our armed forces, who in the day of decision ventured much for the liberties we now enjoy; grant
                that we may not rest until all the people of this land share the benefits of true freedom and gladly
                accept its disciplines; through Jesus Christ our Lord, who with you and the Holy Spirit, lives and
                reigns, now and forever. Amen.",
              [:ofASaint]
            }
          ]
        },
      "apostleOrEvangelist" =>
        { "The festival of a saint is observed in accordance with the rules of precedence set forth in the Calendar of the Church Year. At the
            discretion of the Celebrant, and as appropriate, any of the following Collects, with one of the corresponding sets of Psalms and
            Lessons, may be used a) at the commemoration of a saint listed in the Calendar for which no Proper is provided in this Book, or b)
            at the patronal festival or commemoration of a saint not listed in the Calendar.",
          "Of an Apostle or Evangelist [or New Testament Saint]",
          [ { "Almighty and everlasting God, who kindled the flame of your love in the heart of your servant N.;
                Grant to us, your humble servants, a like faith and power of love, that we who rejoice in his
                companionship may profit by his example; through Jesus Christ our Lord, who lives and reigns with
                you and the Holy Spirit, one God, for ever and ever. Amen.",
              [:apostles]
            }
          ]
        },
      "martyr" =>
        { "",
          "Of a Martyr",
          [ { "Almighty God, who gave to your servant N. boldness to confess the Name of our Savior Jesus Christ
                before the rulers of this world, and courage to die for this faith: Grant that we may always be ready
                to give a reason for the hope that is in us, and to suffer gladly for the sake of our Lord Jesus Christ;
                who lives and reigns with you and the Holy Spirit, one God, for ever and ever. Amen.",
              [:holyWeek]
            }
          ]
        },
      "missionary" =>
        { "",
          "Of a Missionary",
          [ { "Almighty and everlasting God, we thank you for your servant N., whom you called to preach the
                Gospel to the people of_________ (or to the__________ people); raise up in this and every land
                evangelists and heralds of your kingdom, that your Church may proclaim the unsearchable riches of
                our Savior Jesus Christ; who lives and reigns with you and the Holy Spirit, one God, now and
                forever. Amen.",
              [:pentecost]
            }
          ]
        },
      "pastor" =>
        { "",
          "Of a Pastor",
          { [ "O God, our heavenly Father, who raised up your faithful servant N., to be a [bishop and] pastor in
                your Church and to feed your flock: Give abundantly to all pastors the gifts of your Holy Spirit, that
                they may minister in your household as true servants of Christ and stewards of your divine mysteries;
                through Jesus Christ our Lord, who lives and reigns with you and the Holy Spirit, one God, for ever
                and ever. Amen.",
              [:ofASaint]
            ]
          }
        },
      "teacher" =>
        { "",
          "Of a Teacher of the Faith",
          [ { "Almighty God, you gave to your servant N. special gifts of grace to understand and teach the truth as
                it is in Christ Jesus: Grant that by this teaching we may know you, the one true God, and Jesus Christ
                whom you have sent; who lives and reigns with you and the Holy Spirit, one God, for ever and ever.
                Amen.",
              [:ofASaint,:trinitySunday]
            }
          ]
        },
      "monastic" =>
        { "",
          "Of a Monastic",
          [{"O God, whose blessed Son became poor that we through his poverty might be rich: Deliver us from
              an inordinate love of this world, that we, inspired by the devotion of your servant N., may serve you
              with singleness of heart, and attain to the riches of the age to come; through Jesus Christ our Lord,
              who lives and reigns with you, in the unity of the Holy Spirit, one God, now and forever. Amen.",
              [:ofASaint]
          }]
        },
      "reformerOfTheChurch" =>
        {"",
        [{"Of a Reformer of the Church",
            "O God, by whose grace your servant N., kindled with the flame of your love, became a burning and a
            shining light in your Church, turning error into truth and arrogance into humility: Grant that we also
            may be aflame with the same spirit of love and discipline, and walk before you as children of light;
            that your Church on earth may more closely resemble your heavenly kingdom; through Jesus Christ
            our Lord, who lives and reigns with you, in the unity of the Holy Spirit, one God, now and forever.
            Amen.",
            [:pentecost]
        }]
        },
      "reformerOfSociety" =>
        { "",
          "Of a Reformer of Society",
          [ { "Almighty and everlasting God, who kindled the flame of your love in the heart of your servant N. to
                manifest your compassion and mercy on the poor and the persecuted; Grant to us, your humble
                servants, a like faith and power of love, that we who give thanks for his righteous zeal may profit by
                his example; through Jesus Christ our Lord, who lives and reigns with you and the Holy Spirit, one
                God, for ever and ever. Amen.",
              [:ofASaint]
            }
          ]
        },
      "ecumenist" =>
        { "",
          "Of an Ecumenist",
          [ { "Almighty God, we give you thanks for the ministry of N. who labored that the Church of Jesus
                Christ might be one: Grant that we, instructed by his teaching and example, and knit together in unity
                by your Spirit, may ever stand firm upon the one foundation, which is Jesus Christ our Lord; who
                lives and reigns with you, in the unity of the Holy Spirit, one God, now and forever. Amen.",
              [:pentecost]
            }
          ]
        },
      "saint" =>
        { "",
          "Of a Saint",
          [ {"Almighty God, you have surrounded us with a great cloud of witnesses: Grant that we, encouraged
                by the good example of your servant N., may persevere in running the race that is set before us, until
                at last we may with him attain to your eternal joy; through Jesus Christ, the pioneer and perfecter of 
                our faith, who lives and reigns with you and the Holy Spirit, one God, for ever and ever. Amen.",
              [:ofASaint]
            },
            { "Almighty God, by your Holy Spirit you have made us one with your saints in heaven and on earth:
                Grant that in our earthly pilgrimage we may always be supported by this fellowship of love and
                prayer, and know ourselves to be surrounded by their witness to your power and mercy. We ask this
                for the sake of Jesus Christ, in whom all our intercessions are acceptable through the Spirit, and who
                lives and reigns for ever and ever. Amen.", 
              [:ofASaint]
            }
          ]
        },
      "emberDays" =>
        { "Ember Days (The Ministry of the Church),
            For use on the traditional days or at other times",
          [ { "Almighty God, you have committed into human hands the ministry of reconciliation: We ask that
                you pour down upon us the inspiration of your Holy Spirit to discern those whom you call to Holy
                Orders, and put into the hearts of those whom you call the desire to offer themselves for your
                service; that thereby the whole world will be drawn into your blessed kingdom; through Jesus Christ
                our Lord. Amen.",
              [:apostles]
            },
            { "Almighty God, the giver of all good gifts, in your divine providence you have appointed various
                orders in your Church: Give your grace, we humbly pray, to all who are [now] called to any office
                and ministry for your people; and so fill them with the truth of your doctrine and clothe them with
                holiness of life, that they may faithfully serve before you, to the glory of your great Name and for the
                benefit of your holy Church; through Jesus Christ our Lord, who lives and reigns with you, in the
                unity of the Holy Spirit, one God, now and forever. Amen.",
              [:apostles]
            },
            { "O God, you led your holy apostles to ordain ministers in every place: Grant that your Church, under
                the guidance of the Holy Spirit, may choose suitable persons for the ministry of Word and
                Sacrament, and may uphold them in their work for the extension of your kingdom; through him who
                is the Shepherd and Bishop of our souls, Jesus Christ our Lord, who lives and reigns with you and
                the Holy Spirit, one God, for ever and ever. Amen.",
              [:season]
            },
            { "Almighty and everlasting God, by whose Spirit the whole body of your faithful people is governed
                and sanctified: Receive our supplications and prayers, which we offer before you for all members of
                your holy Church, that in their vocation and ministry they may truly and devoutly serve you; through
                our Lord and Savior Jesus Christ, who lives and reigns with you, in the unity of the Holy Spirit, one
                God, now and forever. Amen.",
              [:baptism]
            },
            { "O God, you have made of one blood all the peoples of the earth, and sent your blessed Son to
                preach peace to those who are far off and to those who are near: Grant that people everywhere may
                seek after you and find you, bring the nations into your fold, pour out your Spirit upon all flesh, and
                hasten the coming of your kingdom; through Jesus Christ our Lord, who lives and reigns with you 
                and the Holy Spirit, one God, now and forever. Amen.",
              [:pentecost]
            }
          ]
      },
      "rogation" =>
        { "",
          "Rogation Days (Agriculture and Industry)",
          [ { "Almighty God, Lord of all heaven and earth; we ask that you pour forth your blessing upon this land,
                and to give it a fruitful season; that we, receiving your bounty, may evermore give you thanks;
                through Jesus Christ our Lord. Amen.",
              [:season]
            },
            { "Almighty God, Lord of heaven and earth: We humbly pray that your gracious providence may give
                and preserve to our use the harvests of the land and of the seas, and may prosper all who labor to
                gather them, that we, who are constantly receiving good things from your hand, may always give you
                thanks; through Jesus Christ our Lord, who lives and reigns with you and the Holy Spirit, one God,
                for ever and ever. Amen.",
              [:season]
            },
            { "Almighty God, whose Son Jesus Christ in his earthly life shared our toil and hallowed our labor: Be
                present with your people where they work; make those who carry on the industries and commerce of
                this land responsive to your will; and give to us all a pride in what we do, and a just return for our
                labor; through Jesus Christ our Lord, who lives and reigns with you, in the unity of the Holy Spirit,
                one God, now and forever. Amen.",
              [:season]
            },
            { "O merciful Creator, your hand is open wide to satisfy the needs of every living creature: Make us
                always thankful for your loving providence; and grant that we, remembering the account that we
                must one day give, may be faithful stewards of your good gifts; through Jesus Christ our Lord, who
                with you and the Holy Spirit lives and reigns, one God, for ever and ever. Amen.",
              [:season]
            }
          ]
        }
    }, # end of collects
    propers: %{
      lordsDay:
          { "Preface for the Lord's Day",
            "Through Jesus Christ our Lord; who on the first day of the week
            overcame death and the grave, and by his glorious resurrection
            opened to us the way of everlasting life."},
      advent:
          { "Preface of Advent",
            "Because you sent your beloved Son to redeem us from sin and death,
            and to make us heirs in him of everlasting life; that when he shall
            come again in power and great glory to judge the world, we may
            without shame or fear rejoice to behold his appearing."},
      incarnation:
          { "Preface of the Incarnation",
            "Because you gave Jesus Christ, your only Son, to be born for us; who,
            by the working of the Holy Spirit, was made truly man, taking on the
            flesh of the Virgin Mary his mother; and yet without the stain of sin,
            to make us clean from sin."},
      epiphany:
          { "Preface of the Epiphany",
            "Through Jesus Christ our Lord, who took on our mortal flesh to
            reveal His glory; that he might bring us out of darkness and into his
            own glorious light."},
      presentation:
          { "Preface of the Presentation",
            "Because in the mystery of the Word made flesh, you have caused a
            new light to shine in our hearts, to give the knowledge of your glory
            in the face of your Son Jesus Christ our Lord."},
      lent:
          { "Preface of Lent",
            "Because you have given us the spirit of discipline, that we may
            triumph over the flesh, and live no longer for ourselves but for
            Him who died for us and rose again, your Son Jesus Christ our Lord."},
      holyWeek:
          { "Preface of Holy Week",
            "Because you gave your only Son, our Savior Jesus Christ, to redeem
            mankind from the power of darkness; who, having finished the work
            you gave him to do, was lifted high upon the cross that he might
            draw the whole world to himself, and, being made perfect through
            suffering, might become the author of eternal salvation to all who
            obey him."},
      maundyThursday:
          { "Preface of Maundy Thursday",
            "Through Jesus Christ our Lord; who having loved his own who were
            in the world, loved them to the end, and on the night before he
            suffered, instituted these holy mysteries; that we, receiving the
            benefits of his passion and resurrection, might be made partakers of
            his divine nature."},
      easter:
          { "Preface of Easter",
            "But chiefly are we bound to praise you for the glorious resurrection
            of your Son Jesus Christ our Lord: for he is the true Paschal Lamb,
            which was offered for us, and has taken away the sin of the world;
            who by his death has destroyed death, and by his rising to life again
            has restored us to everlasting life."},
      ascension:
          { "Preface of the Ascension",
            "Through your most dearly beloved Son Jesus Christ our Lord; who
            after his most glorious resurrection, appeared to his Apostles, and in
            their sight ascended up into heaven, to prepare a place for us; that
            where he is, there we might also ascend, and reign with him in glory."},
      pentecost:
          { "Preface of Pentecost",
            "Through Jesus Christ our Lord; according to whose most true
            promise, the Holy Spirit came down from heaven, lighting upon the
            disciples, to teach them, and to lead them into all truth; giving them
            boldness and fervent zeal constantly to preach the Gospel to all
            nations; by which we have been brought out of darkness and error
            into the clear light and true knowledge of you, and of your Son Jesus
            Christ."},
      trinitySunday:
          { "Preface of Trinity Sunday",
            "Who, with your co-eternal Son, and Holy Spirit, are one God, one
            Lord, in Trinity of Persons and in Unity of Substance. For that which
            we believe of your glory, O Father, we believe the same of your Son,
            and of the Holy Spirit, without any: difference of inequality."},
      allSaints:
          { "Preface of All Saints",
            "For in the multitude of your Saints, you have surrounded us with so
            great a cloud of witnesses that we, rejoicing in their fellowship, may
            run with patience the race that is set before us, and, together with
            them, may receive the crown of glory that does not fade away."},
      apostles:
          { "Preface of Apostles and Ordinations",
            "Through the great shepherd of your flock, Jesus Christ our Lord;
            who after his resurrection sent forth his apostles to preach the
            Gospel and to teach all nations; and promised to be with them
            always, even to the end of the ages."},
      dedicationOfChurch:
          { "Preface for Dedicatgion of a Church",
            "Through Jesus Christ our great High Priest; in whom we are built up
            as living stones of a holy temple, that we might offer before you a
            sacrifice of praise and prayer which is holy and pleasing in your sight."},
      baptism:
          { "Preface for Baptism",
            "Because in Jesus Christ our Lord, you have received us as your sons
            and daughters, made us citizens of your kingdom, and given us the
            Holy Spirit to guide us into all truth."},
      marriage:
          { "Preface for Marriage",
            "Because in the love of wife and husband, you have given us an image
            of the heavenly Jerusalem, adorned as a bride for her bridegroom,
            your Son Jesus Christ our Lord; who loves her and gave himself for
            her, that he might make the whole creation new."},
      ofASaint:
          { "Preface of a Saint",
            "Because thou art greatly glorified in the assembly of thy saints.
            All thy creatures praise thee, and thy faithful servants bless
            thee, confessing before the rulers of this world the great Name
            of thine only Son. (BCP Rite I)"},
      season:
          { "Preface of the Season",
            ""
          }
    } # end of propers
    } # end of map
  end # of build
end # of module