defmodule Printable do
  def start_link do
    Agent.start_link fn -> build() end, name: __MODULE__
  end
  def identity(), do: Agent.get(__MODULE__, &(&1))

  def build do
    [
      { "16_Page_Booklet_Sunday.pdf",
        "PDF",
        "8 1/2 x 11 booklet",
        "Sunday & Red Letter Lectionary Booklet"
      },
      { "20_Page_Booklet_DOL.pdf",
        "PDF",
        "8 1/2 x 11 booklet",
        "Daily Office Lectionary Booklet"
      },
      { "ACNA_advent_lf.pdf",
        "PDF",
        "8 1/2 x 11",
        "On Altar: Eucharistic Prayer for Advent"
      },
      { "ACNA_Christmas_lf.pdf",
        "PDF",
        "8 1/2 x 11",
        "On Altar: Eucharistic Prayer for All Saints"
      },
      { "ACNA_Epiphany_lf.pdf",
        "PDF",
        "8 1/2 x 11",
        "On Altar: Eucharistic Prayer for Epiphany"
      },
      { "ACNA_lent_lf.pdf",
        "PDF",
        "8 1/2 x 11",
        "On Altar: Eucharistic Prayer for Lent"
      },
      { "ACNA_holyweek_lf.pdf",
        "PDF",
        "8 1/2 x 11",
        "On Altar: Eucharistic Prayer for Holy Week"
      },
      { "ACNA_maunday_thursday_lf.pdf",
        "PDF",
        "8 1/2 x 11",
        "On Altar: Eucharistic Prayer for Holy Week"
      },
      { "ACNA_easter_lf.pdf",
        "PDF",
        "8 1/2 x 11",
        "On Altar: Eucharistic Prayer for Easter"
      },
      { "ACNA_witsunday_lf.pdf",
        "PDF",
        "8 1/2 x 11",
        "On Altar: Eucharistic Prayer for Easter"
      },
      { "ACNA_trinity_lf.pdf",
        "PDF",
        "8 1/2 x 11",
        "On Altar: Eucharistic Prayer for Easter"
      },
      { "ACNA_pentecost_lf.pdf",
        "PDF",
        "8 1/2 x 11",
        "On Altar: Eucharistic Prayer for Pentecost"
      },
      { "ACNA_All_Saints_lf.pdf",
        "PDF",
        "8 1/2 x 11",
        "On Altar: Eucharistic Prayer for All Saints"
      },
      { "easter.pdf",
        "PDF",
        "8 1/2 x 14 booklet",
        "LARGE PRINT Holy Eucharistic, long form"
      },
    ]
  end

end
