defmodule Printable do
  def start_link do
    Agent.start_link fn -> build end, name: __MODULE__
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
      { "ACNA_All_Saints_lf.odt",
        "ODT",
        "8 1/2 x 11",
        "Eucharistic Prayer for All Saints"
      },
      { "ACNA_easter_lf.odt",
        "ODT",
        "8 1/2 x 11",
        "Eucharistic Prayer for Easter"
      },
      { "ACNA_Epiphany_lf.odt",
        "ODT",
        "8 1/2 x 11",
        "Eucharistic Prayer for Epiphany"
      },
      { "ACNA_advent_lf.odt",
        "ODT",
        "8 1/2 x 11",
        "Eucharistic Prayer for Advent"
      },
      { "ACNA_pentecost_lf.odt",
        "ODT",
        "8 1/2 x 11",
        "Eucharistic Prayer for Pentecost"
      },
      { "ACNA_holy_week_lf.odt",
        "ODT",
        "8 1/2 x 11",
        "Eucharistic Prayer for Holy Week"
      },
      { "ACNA_lent_lf.odt",
        "ODT",
        "8 1/2 x 11",
        "Eucharistic Prayer for Lent"
      },
    ]
  end

end
