require IEx
defmodule Leaflets do
  # import Lityear

  def start_link do
    Agent.start_link fn -> build() end, name: __MODULE__
  end

  def identity(), do: Agent.get(__MODULE__, &(&1))
  def for_this_sunday(season, wk, yr), do: identity()[season][wk][yr]
  def for_this_date(date) do
    {season, wk, yr, _} = Lityear.to_season(date)
    for_this_sunday(season, wk, yr)
  end

  def build() do
  %{
    "advent" =>
      %{  "1" =>
          %{  "a" => %{ reg: "", lp: "" },
              "b" => %{ reg: "", lp: "" },
              "c" => %{ reg: "", lp: "" }
             },
          "2" =>
          %{  "a" => %{ reg: "", lp: "" },
              "b" => %{ reg: "", lp: "" },
              "c" => %{ reg: "", lp: "" }
          },
          "3" =>
          %{  "a" => %{ reg: "", lp: "" },
              "b" => %{ reg: "", lp: "" },
              "c" => %{ reg: "", lp: "" }
          },
          "4" =>
          %{  "a" => %{ reg: "", lp: "" },
              "b" => %{ reg: "", lp: "" },
              "c" => %{ reg: "", lp: "" }
          }
       },
  "christmasDay" =>
    %{  "1" =>
        %{  "a" => %{ reg: "", lp: "" },
            "b" => %{ reg: "", lp: "" },
            "c" => %{ reg: "", lp: "" }
          },
        "2" =>
          %{  "a" => %{ reg: "", lp: "" },
              "b" => %{ reg: "", lp: "" },
              "c" => %{ reg: "", lp: "" }
            },
        "3" =>
          %{  "a" => %{ reg: "", lp: "" },
              "b" => %{ reg: "", lp: "" },
              "c" => %{ reg: "", lp: "" }
          }
    },
  "christmas" =>
    %{  "1" =>
          %{  "a" => %{ reg: "", lp: "" },
              "b" => %{ reg: "", lp: "" },
              "c" => %{ reg: "", lp: "" }
            },
        "2" =>
          %{  "a" => %{ reg: "", lp: "" },
              "b" => %{ reg: "", lp: "" },
              "c" => %{ reg: "", lp: "" }
          }
    },
  "holyName" =>
    %{  "1" =>
        %{  "a" => %{ reg: "", lp: "" },
            "b" => %{ reg: "", lp: "" },
            "c" => %{ reg: "", lp: "" }
        }
    },
  "theEpiphany" =>
    %{  "1" =>
        %{  "a" => %{ reg: "", lp: "" },
            "b" => %{ reg: "", lp: "" },
            "c" => %{ reg: "", lp: "" }
        }
    },
  "epiphany" =>
    %{  "0" =>
        %{  "a" => %{ reg: "", lp: "" },
            "b" => %{ reg: "", lp: "" },
            "c" => %{ reg: "", lp: "" }
          },
        "1" =>
          %{  "a" => %{ reg: "", lp: "" },
              "b" => %{ reg: "", lp: "" },
              "c" => %{ reg: "", lp: "" }
            },
        "2" =>
          %{  "a" => %{ reg: "", lp: "" },
              "b" => %{ reg: "", lp: "" },
              "c" => %{ reg: "", lp: "" }
            },
        "3" =>
          %{  "a" => %{ reg: "", lp: "" },
              "b" => %{ reg: "", lp: "" },
              "c" => %{ reg: "", lp: "" }
            },
        "4" =>
          %{  "a" => %{ reg: "", lp: "" },
              "b" => %{ reg: "", lp: "" },
              "c" => %{ reg: "", lp: "" }
            },
        "5" =>
          %{  "a" => %{ reg: "", lp: "" },
              "b" => %{ reg: "", lp: "" },
              "c" => %{ reg: "", lp: "" }
            },
        "6" =>
          %{  "a" => %{ reg: "", lp: "" },
              "b" => %{ reg: "", lp: "" },
              "c" => %{ reg: "", lp: "" }
            },
        "7" =>
          %{  "a" => %{ reg: "", lp: "" },
              "b" => %{ reg: "", lp: "" },
              "c" => %{ reg: "", lp: "" }
            },
        "8" =>
          %{  "a" => %{ reg: "", lp: "" },
              "b" => %{ reg: "", lp: "" },
              "c" => %{ reg: "", lp: "" }
            },
        "9" =>
          %{  "a" => %{ reg: "", lp: "" },
              "b" => %{ reg: "", lp: "" },
              "c" => %{ reg: "", lp: "" }
          }
    },
  "presentation" =>
    %{  "1" =>
        %{  "a" => %{ reg: "", lp: "" },
            "b" => %{ reg: "", lp: "" },
            "c" => %{ reg: "", lp: "" }
        }
    },
  "ashWednesday" =>
    %{  "1" =>
        %{  "a" => %{ reg: "", lp: "" },
            "b" => %{ reg: "", lp: "" },
            "c" => %{ reg: "", lp: "" }
        }
    },  
  "lent" =>
    %{  "1" =>
          %{  "a" => %{ reg: "", lp: "" },
              "b" => %{ reg: "", lp: "" },
              "c" => %{ reg: "", lp: "" }
            },  
        "2" =>
          %{  "a" => %{ reg: "", lp: "" },
              "b" => %{ reg: "", lp: "" },
              "c" => %{ reg: "", lp: "" }
            },
        "3" =>
          %{  "a" => %{ reg: "", lp: "" },
              "b" => %{ reg: "", lp: "" },
              "c" => %{ reg: "", lp: "" }
            },
        "4" =>
          %{  "a" => %{ reg: "", lp: "" },
              "b" => %{ reg: "", lp: "" },
              "c" => %{ reg: "", lp: "" }
            },
        "5" =>
          %{  "a" => %{ reg: "", lp: "" },
              "b" => %{ reg: "", lp: "" },
              "c" => %{ reg: "", lp: "" }
          }
    },
  "palmSundayPalms" =>
    %{  "1" =>
          %{}
      },
  "palmSunday" =>
    %{  "1" =>
          %{  "a" => %{ reg: "", lp: "" },
              "b" => %{ reg: "", lp: "" },
              "c" => %{ reg: "", lp: "" }
          }
      },
  "holyWeek" =>
    %{  "1" =>
          %{  "a" => %{ reg: "", lp: "" },
              "b" => %{ reg: "", lp: "" },
              "c" => %{ reg: "", lp: "" }
            },
        "2" =>
          %{  "a" => %{ reg: "", lp: "" },
              "b" => %{ reg: "", lp: "" },
              "c" => %{ reg: "", lp: "" }
            },
        "3" =>
          %{  "a" => %{ reg: "", lp: "" },
              "b" => %{ reg: "", lp: "" },
              "c" => %{ reg: "", lp: "" }
            },
        "4" =>
          %{  "a" => %{ reg: "", lp: "" },
              "b" => %{ reg: "", lp: "" },
              "c" => %{ reg: "", lp: "" }
            },
        "5" =>
          %{  "a" => %{ reg: "", lp: "" },
              "b" => %{ reg: "", lp: "" },
              "c" => %{ reg: "", lp: "" }
            },
        "6" =>
          %{  "a" => %{ reg: "", lp: "" },
              "b" => %{ reg: "", lp: "" },
              "c" => %{ reg: "", lp: "" }
            }
      },
  "easterDayVigil" =>
    %{  "1" =>
          %{  "a" => %{ reg: "", lp: "" },
              "b" => %{ reg: "", lp: "" },
              "c" => %{ reg: "", lp: "" }
          }
      },
  "easterDay" =>
    %{  "2" =>
          %{  "a" => %{ reg: "", lp: "" },
              "b" => %{ reg: "", lp: "" },
              "c" => %{ reg: "", lp: "" }
            },
        "1" =>
           %{ "a" => %{ reg: "", lp: "" },
              "b" => %{ reg: "", lp: "" },
              "c" => %{ reg: "", lp: "" }
            },
        "3" =>
          %{  "a" => %{ reg: "", lp: "" },
              "b" => %{ reg: "", lp: "" },
              "c" => %{ reg: "", lp: "" }
          }
      },
  "easterWeek" =>
    %{ "1" =>
        %{  "a" => %{ reg: "", lp: "" },
            "b" => %{ reg: "", lp: "" },
            "c" => %{ reg: "", lp: "" }
          },
        "2" =>
          %{  "a" => %{ reg: "", lp: "" },
              "b" => %{ reg: "", lp: "" },
              "c" => %{ reg: "", lp: "" }
            },
        "3" =>
          %{  "a" => %{ reg: "", lp: "" },
              "b" => %{ reg: "", lp: "" },
              "c" => %{ reg: "", lp: "" }
            },
        "4" =>
          %{  "a" => %{ reg: "", lp: "" },
              "b" => %{ reg: "", lp: "" },
              "c" => %{ reg: "", lp: "" }
            },
        "5" =>
          %{  "a" => %{ reg: "", lp: "" },
              "b" => %{ reg: "", lp: "" },
              "c" => %{ reg: "", lp: "" }
            },
        "6" =>
          %{  "a" => %{ reg: "", lp: "" },
              "b" => %{ reg: "", lp: "" },
              "c" => %{ reg: "", lp: "" }
          }
      },
  "easter" =>
    %{  "2" =>
          %{  "a" => %{ reg: "", lp: "" },
              "b" => %{ reg: "", lp: "" },
              "c" => %{ reg: "", lp: "" }
            },      
        "3" =>
            %{  "a" => %{ reg: "", lp: "" },
                "b" => %{ reg: "", lp: "" },
                "c" => %{ reg: "", lp: "" }
              },
        "4" =>
            %{  "a" => %{ reg: "", lp: "" },
                "b" => %{ reg: "", lp: "" },
                "c" => %{ reg: "", lp: "" }
              },
        "5" =>
            %{  "a" => %{ reg: "", lp: "" },
                "b" => %{ reg: "", lp: "" },
                "c" => %{ reg: "", lp: "" }
              },
        "6" =>
          %{  "a" => %{ reg: "", lp: "" },
              "b" => %{ reg: "", lp: "" },
              "c" => %{ reg: "", lp: "" }
            },
        "7" =>
          %{  "a" => %{ reg: "", lp: "" },
              "b" => %{ reg: "", lp: "" },
              "c" => %{ reg: "", lp: "" }
          }
      },
  "ascension" =>
    %{  "1" =>
          %{  "a" => %{ reg: "", lp: ""},
              "b" => %{ reg: "", lp: "" },
              "c" => %{ reg: "", lp: "" }
            }

    },
  "pentecost" =>
    %{  "1" =>
          %{ "a" => %{  reg: "https://s3.amazonaws.com/acna/A-41-Pentecost-landscape-2.pdf", 
                    lp:  "https://s3.amazonaws.com/acna/A-41-Pentecost2pdf"
                  },
              "b" => %{ reg: "", lp: "" },
              "c" => %{ reg: "", lp: "" }
            }
      },
  "trinity" =>
    %{  "1" =>
          %{  "a" => %{ reg: "https://s3.amazonaws.com/acna/A-42-TrinitySunday-landscape%202.pdf", 
                    lp:  "https://s3.amazonaws.com/acna/A-42-TrinitySundaypdf" 
                  },
              "b" => %{ reg: "", lp: "" },
              "c" => %{ reg: "", lp: "" }
          }
      },
  "pentecostWeekday" =>
    %{  "1" =>
          %{  "a" => %{ reg: "", lp: "" },
              "b" => %{ reg: "", lp: "" },
              "c" => %{ reg: "", lp: "" }
            },
        "2" =>
          %{  "a" => %{ reg: "", lp: "" },
              "b" => %{ reg: "", lp: "" },
              "c" => %{ reg: "", lp: "" }
            }

      },
  "proper" =>
    %{  "1" =>
          %{  "a" => %{ reg: "https://s3.amazonaws.com/acna/A-43-May%208-Pentecost%20landscape-2.pdf", 
                    lp:  "https://s3.amazonaws.com/acna/A-43-May%208-Pentecost-2pdf"
                  },
              "b" => %{ reg: "", lp: "" },
              "c" => %{ reg: "", lp: "" }
            },
        "2" =>
          %{  "a" => %{ reg: "https://s3.amazonaws.com/acna/A-44-After%20Pentecost-May15-21-landscape2.pdf", 
                        lp:  "https://s3.amazonaws.com/acna/A-44-After-Pentecost5-15-21-2pdf" 
                      },
              "b" => %{ reg: "", lp: "" },
              "c" => %{ reg: "", lp: "" }
            },
        "3" =>
          %{  "a" => %{ reg: "https://s3.amazonaws.com/acna/A-45-After%20Pentecost-May22-28-landscape-2.pdf", 
                        lp:  "https://s3.amazonaws.com/acna/A-45-After%20Pentecost-May22-28-2pdf" 
                      },
              "b" => %{ reg: "", lp: "" },
              "c" => %{ reg: "", lp: "" }
            },
        "4" =>
          %{  "a" => %{ reg: "https://s3.amazonaws.com/acna/A-46-After-Pentecost5-29-6-4-landscape-2.pdf", 
                        lp:  "https://s3.amazonaws.com/acna/A-46-After-Pentecost5-29-6-4-2pdf" 
                      },
              "b" => %{ reg: "", lp: "" },
              "c" => %{ reg: "", lp: "" }
            },
        "5" =>
          %{  "a" => %{ reg: "https://s3.amazonaws.com/acna/A-47-After-Pentecost-6-5-6-11-landscape-2.pdf", 
                        lp:  "https://s3.amazonaws.com/acna/A-47-After-Pentecost-6-5-6-11-2pdf" 
                      },
              "b" => %{ reg: "", lp: "" },
              "c" => %{ reg: "", lp: "" }
            },
        "6" =>
          %{  "a" => %{ reg: "https://s3.amazonaws.com/acna/A-43-May%208-Pentecost%20landscape-2.pdf", 
                        lp:  "https://s3.amazonaws.com/acna/A-43-May%208-Pentecost-2pdf" 
                      },
              "b" => %{ reg: "", lp: "" },
              "c" => %{ reg: "", lp: "" }
            },
        "7" =>
          %{  "a" => %{ reg: "https://s3.amazonaws.com/acna/A-49-After-Pentecost-6-19-25-landscape-2.pdf", 
                        lp:  "https://s3.amazonaws.com/acna/A-49-After-Pentecost-6-19-25-2pdf" 
                      },
              "b" => %{ reg: "", lp: "" },
              "c" => %{ reg: "", lp: "" }
            },
        "8" =>
          %{  "a" => %{ reg: "https://s3.amazonaws.com/acna/A-50-After-Pentecost-6-26-7-2-landscape-2.pdf", 
                        lp:  "https://s3.amazonaws.com/acna/A-50-After-Pentecost-6-26-7-2pdf" 
                      },
              "b" => %{ reg: "", lp: "" },
              "c" => %{ reg: "", lp: "" }
            },
        "9" =>
          %{  "a" => %{ reg: "https://s3.amazonaws.com/acna/A-51-After-Pentecost-7-3-9-landscape.pdf", 
                        lp:  "https://s3.amazonaws.com/acna/A-51-After-Pentecost-7-3-9pdf" 
                      },
              "b" => %{ reg: "", lp: "" },
              "c" => %{ reg: "", lp: "" }
            },
        "10" =>
          %{  "a" => %{ reg: "https://s3.amazonaws.com/acna/A-52-After-Pentecost-7-10-16-landscape.pdf", 
                        lp: "https://s3.amazonaws.com/acna/A-52-After-Pentecost-7-10-16.pdf" 
                        },
              "b" => %{ reg: "", lp: "" },
              "c" => %{ reg: "", lp: "" }
            },
        "11" =>
          %{  "a" => %{ reg: "https://s3.amazonaws.com/acna/A-53-After-Pentecost-7-17-23-landscape.pdf", 
                        lp: "https://s3.amazonaws.com/acna/A-53-After-Pentecost-7-17-23.pdf" 
                      },
              "b" => %{ reg: "", lp: "" },
              "c" => %{ reg: "", lp: "" }
            },
        "12" =>
          %{  "a" => %{ reg: "https://s3.amazonaws.com/acna/A-54-After-Pentecost-7-24-30-landscape.pdf", 
                        lp: "https://s3.amazonaws.com/acna/A-54-After-Pentecost-7-24-30.pdf" 
                      },
              "b" => %{ reg: "", lp: "" },
              "c" => %{ reg: "", lp: "" }
            },
        "13" =>
          %{  "a" => %{ reg: "https://s3.amazonaws.com/acna/A-55-After-Pentecost-7-31-8-6-landscape.pdf", 
                        lp: "https://s3.amazonaws.com/acna/A-55-After-Pentecost-7-31-8-6.pdf" 
                      },
              "b" => %{ reg: "", lp: "" },
              "c" => %{ reg: "", lp: "" }
            },
        "14" =>
          %{  "a" => %{ reg: "https://s3.amazonaws.com/acna/A-57-After%20Pentecost%208-7-13-landscape.pdf", 
                        lp: "https://s3.amazonaws.com/acna/A-57-After%20Pentecost%208-7-13.pdf" 
                      },
              "b" => %{ reg: "", lp: "" },
              "c" => %{ reg: "", lp: "" }
            },
        "15" =>
          %{  "a" => %{ reg: "https://s3.amazonaws.com/acna/A-57-After%20Pentecost%208-14-20-landscape.pdf", 
                        lp: "https://s3.amazonaws.com/acna/A-57-After%20Pentecost%208-14-20.pdf" 
                      },
              "b" => %{ reg: "", lp: "" },
              "c" => %{ reg: "", lp: "" }
            },
        "16" =>
          %{  "a" => %{ reg: "https://s3.amazonaws.com/acna/A-58-After%20Pentecost%208-21-27-landscape.pdf", 
                        lp: "https://s3.amazonaws.com/acna/A-58-After%20Pentecost%208-21-27.pdf" 
                      },
              "b" => %{ reg: "", lp: "" },
              "c" => %{ reg: "", lp: "" }
            },
        "17" =>
          %{  "a" => %{ reg: "https://s3.amazonaws.com/acna/A-59-After%20Pentecost%208-28-9-3-landscape.pdf", 
                        lp: "https://s3.amazonaws.com/acna/A-59-After%20Pentecost%208-28-9-3.pdf" 
                      },
              "b" => %{ reg: "", lp: "" },
              "c" => %{ reg: "", lp: "" }
            },
        "18" =>
          %{  "a" => %{ reg: "", 
                        lp: "" 
                      },
              "b" => %{ reg: "", lp: "" },
              "c" => %{ reg: "", lp: "" }
            },
        "19" =>
          %{  "a" => %{ reg: "", 
                        lp: "" 
                      },
              "b" => %{ reg: "", lp: "" },
              "c" => %{ reg: "", lp: "" }
            },
        "20" =>
          %{  "a" => %{ reg: "", lp: "" },
              "b" => %{ reg: "", lp: "" },
              "c" => %{ reg: "", lp: "" }
            },
        "21" =>
          %{  "a" => %{ reg: "", lp: "" },
              "b" => %{ reg: "", lp: "" },
              "c" => %{ reg: "", lp: "" }
            },
        "22" =>
          %{  "a" => %{ reg: "", lp: "" },
              "b" => %{ reg: "", lp: "" },
              "c" => %{ reg: "", lp: "" }
            },
        "23" =>
          %{  "a" => %{ reg: "", lp: "" },
              "b" => %{ reg: "", lp: "" },
              "c" => %{ reg: "", lp: "" }
            },
        "24" =>
          %{  "a" => %{ reg: "", lp: "" },
              "b" => %{ reg: "", lp: "" },
              "c" => %{ reg: "", lp: "" }
            },
        "25" =>
          %{  "a" => %{ reg: "", lp: "" },
              "b" => %{ reg: "", lp: "" },
              "c" => %{ reg: "", lp: "" }
            },
        "26" =>
          %{  "a" => %{ reg: "", lp: "" },
              "b" => %{ reg: "", lp: "" },
              "c" => %{ reg: "", lp: "" }
            },
        "27" =>
          %{  "a" => %{ reg: "", lp: "" },
              "b" => %{ reg: "", lp: "" },
              "c" => %{ reg: "", lp: "" }
            },
        "28" =>
          %{  "a" => %{ reg: "", lp: "" },
              "b" => %{ reg: "", lp: "" },
              "c" => %{ reg: "", lp: "" }
            },
        "29" =>
          %{  "a" => %{ reg: "", lp: "" },
              "b" => %{ reg: "", lp: "" },
              "c" => %{ reg: "", lp: "" }
          }
    },
  "allSaints" =>
    %{  "1" =>
          %{  "a" => %{ reg: "", lp: "" },
              "b" => %{ reg: "", lp: "" },
              "c" => %{ reg: "", lp: "" }
          }
      },
  "redLetter" =>
    %{  "stAndrew" =>
          %{  "a" => %{ reg: "", lp: "" },
              "b" => %{ reg: "", lp: "" },
              "c" => %{ reg: "", lp: "" }
            },
        "stThomas" =>
          %{  "a" => %{ reg: "", lp: "" },
              "b" => %{ reg: "", lp: "" },
              "c" => %{ reg: "", lp: "" }
            },
        "stStephen" =>
          %{  "a" => %{ reg: "", lp: "" },
              "b" => %{ reg: "", lp: "" },
              "c" => %{ reg: "", lp: "" }
            },
        "stJohn" =>
          %{  "a" => %{ reg: "", lp: "" },
              "b" => %{ reg: "", lp: "" },
              "c" => %{ reg: "", lp: "" }
            },
        "holyInnocents" =>
          %{  "a" => %{ reg: "", lp: "" },
              "b" => %{ reg: "", lp: "" },
              "c" => %{ reg: "", lp: "" }
            },
        "confessionOfStPeter" =>
          %{  "a" => %{ reg: "", lp: "" },
              "b" => %{ reg: "", lp: "" },
              "c" => %{ reg: "", lp: "" }
            },
        "conversionOfStPaul" =>
          %{  "a" => %{ reg: "", lp: "" },
              "b" => %{ reg: "", lp: "" },
              "c" => %{ reg: "", lp: "" }
            },
        "presentation" =>
          %{  "a" => %{ reg: "", lp: "" },
              "b" => %{ reg: "", lp: "" },
              "c" => %{ reg: "", lp: "" }
            },
        "stMatthias" =>
          %{  "a" => %{ reg: "", lp: "" },
              "b" => %{ reg: "", lp: "" },
              "c" => %{ reg: "", lp: "" }
            },
        "stJoseph" =>
          %{  "a" => %{ reg: "", lp: "" },
              "b" => %{ reg: "", lp: "" },
              "c" => %{ reg: "", lp: "" }
            },
        "annunciation" =>
          %{  "a" => %{ reg: "", lp: "" },
              "b" => %{ reg: "", lp: "" },
              "c" => %{ reg: "", lp: "" }
            },
        "stMark" =>
          %{  "a" => %{ reg: "", lp: "" },
              "b" => %{ reg: "", lp: "" },
              "c" => %{ reg: "", lp: "" }
            },
        "stsPhilipAndJames" =>
          %{  "a" => %{ reg: "", lp: "" },
              "b" => %{ reg: "", lp: "" },
              "c" => %{ reg: "", lp: "" }
            },
        "visitation" =>
          %{  "a" => %{ reg: "", lp: "" },
              "b" => %{ reg: "", lp: "" },
              "c" => %{ reg: "", lp: "" }
            },
        "stBarnabas" =>
          %{  "a" => %{ reg: "", lp: "" },
              "b" => %{ reg: "", lp: "" },
              "c" => %{ reg: "", lp: "" }
            },
        "nativityOfJohnTheBaptist" =>
          %{  "a" => %{ reg: "", lp: "" },
              "b" => %{ reg: "", lp: "" },
              "c" => %{ reg: "", lp: "" }
            },
        "stPeterAndPaul" =>
          %{  "a" => %{ reg: "", lp: "" },
              "b" => %{ reg: "", lp: "" },
              "c" => %{ reg: "", lp: "" }
            },
        "dominion" =>
          %{  "a" => %{ reg: "", lp: "" },
              "b" => %{ reg: "", lp: "" },
              "c" => %{ reg: "", lp: "" }
            },
        "independence" =>
          %{  "a" => %{ reg: "", lp: "" },
              "b" => %{ reg: "", lp: "" },
              "c" => %{ reg: "", lp: "" }
            },
        "stMaryMagdalene" =>
          %{  "a" => %{ reg: "", lp: "" },
              "b" => %{ reg: "", lp: "" },
              "c" => %{ reg: "", lp: "" }
            },
        "stJames" =>
          %{  "a" => %{ reg: "", lp: "" },
              "b" => %{ reg: "", lp: "" },
              "c" => %{ reg: "", lp: "" }
            },
        "transfiguration" =>
          %{  "a" => %{ reg: "", lp: "" },
              "b" => %{ reg: "", lp: "" },
              "c" => %{ reg: "", lp: "" }
            },
        "bvm" =>
          %{  "a" => %{ reg: "", lp: "" },
              "b" => %{ reg: "", lp: "" },
              "c" => %{ reg: "", lp: "" }
            },
        "stBartholomew" =>
          %{  "a" => %{ reg: "", lp: "" },
              "b" => %{ reg: "", lp: "" },
              "c" => %{ reg: "", lp: "" }
            },
        "holyCross" =>
          %{  "a" => %{ reg: "", lp: "" },
              "b" => %{ reg: "", lp: "" },
              "c" => %{ reg: "", lp: "" }
            },
        "stMatthew" =>
          %{  "a" => %{ reg: "", lp: "" },
              "b" => %{ reg: "", lp: "" },
              "c" => %{ reg: "", lp: "" }
            },
        "michaelAllAngels" =>
          %{  "a" => %{ reg: "", lp: "" },
              "b" => %{ reg: "", lp: "" },
              "c" => %{ reg: "", lp: "" }
            },
        "stLuke" =>
          %{  "a" => %{ reg: "", lp: "" },
              "b" => %{ reg: "", lp: "" },
              "c" => %{ reg: "", lp: "" }
            },
        "stJamesOfJerusalem" =>
          %{  "a" => %{ reg: "", lp: "" },
              "b" => %{ reg: "", lp: "" },
              "c" => %{ reg: "", lp: "" }
            },
        "stsSimonAndJude" =>
          %{  "a" => %{ reg: "", lp: "" },
              "b" => %{ reg: "", lp: "" },
              "c" => %{ reg: "", lp: "" }
            },
         "allSaints" =>
          %{  "a" => %{ reg: "", lp: "" },
              "b" => %{ reg: "", lp: "" },
              "c" => %{ reg: "", lp: "" }
            },
        "thanksgiving" =>
          %{  "a" => %{ reg: "", lp: "" },
              "b" => %{ reg: "", lp: "" },
              "c" => %{ reg: "", lp: "" }
            },
        "remembrance" =>
          %{  "a" => %{ reg: "", lp: "" },
              "b" => %{ reg: "", lp: "" },
              "c" => %{ reg: "", lp: "" }
            },
        "memorial" =>
          %{  "a" => %{ reg: "", lp: "" },
              "b" => %{ reg: "", lp: "" },
              "c" => %{ reg: "", lp: "" }
          }
      }
  }
  end
    
end