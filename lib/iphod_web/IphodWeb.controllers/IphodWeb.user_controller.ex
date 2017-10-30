require IEx
defmodule IphodWeb.UserController do
  use IphodWeb, :controller
  plug :authenticate when action in [:index, :show]

  alias Iphod.User

  def index(conn, _params) do
    users = Repo.all(User)
    render(conn, "index.html", users: users, page_controller: "user")
  end

  def new(conn, _params) do
    changeset = User.changeset(%User{})
    render(conn, "new.html", changeset: changeset, page_controller: "user")
  end

  def create(conn, %{"user" => user_params}) do
    changeset = User.changeset(%User{}, user_params)

    case Repo.insert(changeset) do
      {:ok, _user} ->
        conn
        |> put_flash(:info, "User created successfully.")
        |> redirect(to: user_path(conn, :index))
      {:error, changeset} ->
        render(conn, "new.html", changeset: changeset, page_controller: "user")
    end
  end

  def show(conn, %{"id" => id}) do
    user = Repo.get!(User, id)
    render(conn, "show.html", user: user, page_controller: "user")
  end

  def edit(conn, %{"id" => id}) do
    user = Repo.get!(User, id)
    changeset = User.changeset(user)
    render(conn, "edit.html", user: user, changeset: changeset, page_controller: "user")
  end

  def update(conn, %{"id" => id, "user" => user_params}) do
    user = Repo.get!(User, id)
    changeset = User.changeset(user, user_params)

    case Repo.update(changeset) do
      {:ok, user} ->
        conn
        |> put_flash(:info, "User updated successfully.")
        |> redirect(to: user_path(conn, :show, user))
      {:error, changeset} ->
        render(conn, "edit.html", user: user, changeset: changeset, page_controller: "user")
    end
  end

  def delete(conn, %{"id" => id}) do
    user = Repo.get!(User, id)

    # Here we use delete! (with a bang) because we expect
    # it to always work (and if it does not, it will raise).
    Repo.delete!(user)

    conn
    |> put_flash(:info, "User deleted successfully.")
    |> redirect(to: user_path(conn, :index))
  end

  def authenticate(conn, _opts) do
    if conn.assigns.current_user do
      IEx.pry
      conn
    else
      conn
      |> put_flash(:info, "You must be logged in to access that page")
      |> redirect(to: "/calendar")
      |> halt()
    end
  end

#   def authenticate_admin(conn) do
#     # if user is an admin
#     if do_something_smart_here do
#       conn
#     else
#       conn
#       |> put_flash("You must be logged in to author that page")
#       |> redirect(to: "/calendar")
#       |> halt()
#     end
#   end
#     
#   end
# 
#   def authenticate_author(conn) do
#     # if user is an author or admin
#     if do_something_smart_here do
#       conn
#     else
#       conn
#       |> put_flash("You must be logged in to author that page")
#       |> redirect(to: "/calendar")
#       |> halt()
#     end
#   end
end
