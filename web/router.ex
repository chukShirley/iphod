defmodule Iphod.Router do
  use Iphod.Web, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", Iphod do
    pipe_through :browser # Use the default browser stack

    get "/", PageController, :index
    get "/printables", PrintableController, :index
  end

  # Other scopes may use custom stacks.
  # scope "/api", Iphod do
  #   pipe_through :api
  # end
end
