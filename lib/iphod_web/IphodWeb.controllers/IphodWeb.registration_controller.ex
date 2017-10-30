defmodule IphodWeb.RegistrationController do
  use IphodWeb, :controller

  alias Iphod.User

  def new(conn, _params) do
    changeset = User.changeset(%User{})
    render conn, changeset: changeset, page_controller: "registration"
  end

  def create(conn, %{"user" => user_params}) do
    changeset = User.changeset(%User{}, user_params)

    case Iphod.Registration.create(changeset, Iphod.Repo) do
      {:ok, _changeset} ->
       conn
       |> put_session(:current_user, changeset.id)
       |> put_flash(:info, "Your account was created")
       |>redirect(to: "/calendar", page_controller: "registration")
      {:error, changeset} ->
        IO.puts ">>>>> CHANGESET: #{inspect changeset}"
        conn
        |> put_flash(:info, "Unable to create account")
        |> render("new.html", changeset: changeset, page_controller: "registration")
    end
  end
end