defmodule Iphod.ReflectionController do
  use Iphod.Web, :controller

  alias Iphod.Reflection

  plug :scrub_params, "reflection" when action in [:create, :update]

  def index(conn, _params) do
    reflections = Repo.all from r in Reflection, order_by: :date
    render(conn, "index.html", reflections: reflections, page_controller: "reflection")
  end

  def new(conn, _params) do
    changeset = Reflection.changeset(%Reflection{})
    render(conn, "new.html", changeset: changeset, page_controller: "reflection")
  end

  def create(conn, %{"reflection" => reflection_params}) do
    changeset = Reflection.changeset(%Reflection{}, reflection_params)

    case Repo.insert(changeset) do
      {:ok, _reflection} ->
        conn
        |> put_flash(:info, "Reflection created successfully.")
        |> redirect(to: reflection_path(conn, :index))
      {:error, changeset} ->
        render(conn, "new.html", changeset: changeset, page_controller: "reflection")
    end
  end

  def show(conn, %{"id" => id}) do
    reflection = Repo.get!(Reflection, id)
    render(conn, "show.html", reflection: reflection, page_controller: "reflection")
  end

  def edit(conn, %{"id" => id}) do
    reflection = Repo.get!(Reflection, id)
    changeset = Reflection.changeset(reflection)
    render(conn, "edit.html", reflection: reflection, changeset: changeset, page_controller: "reflection")
  end

  def update(conn, %{"id" => id, "reflection" => reflection_params}) do
    reflection = Repo.get!(Reflection, id)
    changeset = Reflection.changeset(reflection, reflection_params)

    case Repo.update(changeset) do
      {:ok, reflection} ->
        conn
        |> put_flash(:info, "Reflection updated successfully.")
        |> redirect(to: reflection_path(conn, :show, reflection))
      {:error, changeset} ->
        render(conn, "edit.html", reflection: reflection, changeset: changeset, page_controller: "reflection")
    end
  end

  def delete(conn, %{"id" => id}) do
    reflection = Repo.get!(Reflection, id)

    # Here we use delete! (with a bang) because we expect
    # it to always work (and if it does not, it will raise).
    Repo.delete!(reflection)

    conn
    |> put_flash(:info, "Reflection deleted successfully.")
    |> redirect(to: reflection_path(conn, :index))
  end
end
