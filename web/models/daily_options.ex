require IEx
require Ecto.Query
alias Iphod.Repo

defmodule Iphod.DailyOptions do
  use Iphod.Web, :model
  import Lityear, only: [right_after_ash_wednesday?: 1, right_after_ascension?: 1]
  @dayNames ~w( Monday Tuesday Wednesday Thursday Friday Saturday Sunday)
  @christmasDays ~w( Dec29 Dec30 Dec31 Jan02 Jan03 Jan04 Jan05 )

  schema "daily_options" do
    field :date, Ecto.Date
    field :collect, :string
    field :invitatory, :string

    timestamps()
  end

  @required_fields ~w(date, collect, invitatory)
  @optional_field ~w()

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:date, :collect, :invitatory])
  end

  def get_daily_options(day, dreading) do # presumes day is in Elixir.Date form
    ectoDate = day |> date_to_ecto
    case resp = Repo.one(from r in Iphod.DailyOptions, where: [date: ^ectoDate]) do
      nil -> set_daily_options(day, dreading)
      _   -> {resp.invitatory, resp.collect}
    end
  end

  def set_daily_options(day, dreading) do
    invitatory = invitatory_canticle(dreading)
    collect = collect_of_week(day, dreading)
    Repo.insert(%Iphod.DailyOptions{date: day |> date_to_ecto , collect: collect, invitatory: invitatory})
    {invitatory, collect}
  end

  def invitatory_canticle(dreading) do
    cond do
      dreading.season == "lent" -> "lent_venite"
      dreading.season == "easterDay" && dreading.week == "1" -> "pascha_nostrum"
      dreading.season == "easter" -> ["venite", "jubilate", "pascha_nostrum"] |> Enum.random
      true -> ["venite", "jubilate"] |> Enum.random
    end
  end

  def collect_of_week(day, dreading) do
    c = 
      cond do
        dreading.title == "Monday of Easter Week"     -> Collects.get("easterWeek", "1").collects
        dreading.title == "Tuesday of Easter Week"    -> Collects.get("easterWeek", "2").collects
        dreading.title == "Wednesday of Easter Week"  -> Collects.get("easterWeek", "3").collects
        dreading.title == "Thursday of Easter Week"   -> Collects.get("easterWeek", "4").collects
        dreading.title == "Friday of Easter Week"     -> Collects.get("easterWeek", "5").collects
        dreading.title == "Saturday of Easter Week"   -> Collects.get("easterWeek", "6").collects

        day |> right_after_ash_wednesday?            -> Collects.get("ashWednesday", "1").collects

        day |> right_after_ascension?                -> Collects.get("ascension", "1").collects

        @christmasDays |> Enum.member?(dreading.day)  -> Collects.get(dreading.season, dreading.week).collects

        @dayNames |> Enum.member?(dreading.title)     -> Collects.get(dreading.season, dreading.week).collects

        @dayNames |> Enum.member?(dreading.day)       -> Collects.get(dreading.season, dreading.week).collects

        true                                          -> Collects.get("redLetter", dreading.day).collects
      end
      |> Enum.random
    c.collect
  end

  def date_to_ecto(day) do
    {:ok, date} = day |> Date.to_erl |> Ecto.Date.load
    date
  end
end
