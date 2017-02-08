defmodule Iphod.Endpoint do
  use Phoenix.Endpoint, otp_app: :iphod

  socket "/socket", Iphod.UserSocket

  # Serve at "/" the static files from "priv/static" directory.
  #
  # You should set gzip to true if you are running phoenix.digest
  # when deploying your static files in production.
  plug Plug.Static,
    at: "/", from: :iphod, gzip: false,
    only: ~w(css fonts images js favicon.ico robots.txt)

  # Code reloading can be explicitly enabled under the
  # :code_reloader configuration of your endpoint.
  if Mix.env == "dev" do
    if code_reloading? do
      socket "/phoenix/live_reload/socket", Phoenix.LiveReloader.Socket
      plug Phoenix.LiveReloader
      plug Phoenix.CodeReloader
    end
  end

  plug Plug.RequestId
  plug Plug.Logger

  plug Plug.Parsers,
    parsers: [:urlencoded, :multipart, :json],
    pass: ["*/*"],
    json_decoder: Poison

  plug Plug.MethodOverride
  plug Plug.Head

  plug Plug.Session,
    store: :cookie,
    key: "_iphod_key",
    signing_salt: "tFK8XVUK"

  plug Iphod.Router
end
