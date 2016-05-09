defmodule Morgue.Repo do
  use Ecto.Repo, otp_app: :iphod

  def log(log_entry) do
    :ok = :exometer.update ~w(iphod ecto query_exe_time)a, 
            (log_entry.query_time + log_entry.queue_time || 0) / 1_000
    :ok = :exometer.update ~w(iphod, ecto query_queue_time)a,
            (log_entry.queue_time || 0) / 1_000 # Note: you will have to add this to conf/exometer.exs if you want it
    :ok = :exometer.update ~w(iphod, ecto, query_count)a, 1

    super log_entry
  end
end