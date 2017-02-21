require IEx
defmodule Iphod.ResourcesController do
  use Iphod.Web, :controller

  alias Iphod.Resources

  def printresources(conn, _params) do
    render(conn, "printresources.html", page_controller: "resources")
  end

  def inserts(conn, _params) do
    render(conn, "inserts.html", page_controller: "resources")
  end

  def linkresources(conn, _params) do
    render(conn, "linkresources.html", page_controller: "resources")
  end

  def humor(conn, _params) do
    render(conn, "humor.html", page_controller: "resources")
  end

  def index(conn, _params) do
    resources = Repo.all(Resources)
    render(conn, "index.html", resources: resources, page_controller: "resources")
  end

  def new(conn, _params) do
    changeset = Resources.changeset(%Resources{})
    render(conn, "new.html", changeset: changeset, page_controller: "resources")
  end

  def create(conn, %{"resources" => resources_params}) do
    changeset = Resources.changeset(%Resources{}, resources_params)

    case Repo.insert(changeset) do
      {:ok, resources} ->
        if upload = resources_params["file"] do
          extension = Path.extname(upload.filename)
          rootname = Path.rootname(upload.filename)
          filename = "./printresources/#{rootname}_#{resources.id}#{extension}"
          File.cp(upload.path, filename)
          new_changeset = Resources.changeset(resources, %{url: filename |> Path.basename})
          Repo.update(new_changeset)
        end
        conn
        |> put_flash(:info, "Resources created successfully.")
        |> redirect(to: resources_path(conn, :index))
      {:error, changeset} ->
        render(conn, "new.html", changeset: changeset, page_controller: "resources")
    end
  end

  def show(conn, %{"id" => id}) do
    resources = Repo.get!(Resources, id)
    render(conn, "show.html", resources: resources, page_controller: "resources")
  end

  def edit(conn, %{"id" => id}) do
    r = Repo.get!(Resources, id) 
    resources = Map.put(r, :key_string, r.keys |> make_key_string )
    changeset = Resources.changeset(resources)
    render(conn, "edit.html", resources: resources, changeset: changeset, page_controller: "resources")
  end

  def update(conn, %{"id" => id, "resources" => resources_params}) do
    resources = Repo.get!(Resources, id)
    changeset = Resources.changeset(resources, resources_params)

    case Repo.update(changeset) do
      {:ok, resources} ->
        conn
        |> put_flash(:info, "Resources updated successfully.")
        |> redirect(to: resources_path(conn, :show, resources))
      {:error, changeset} ->
        render(conn, "edit.html", resources: resources, changeset: changeset, page_controller: "resources")
    end
  end

  def delete(conn, %{"id" => id}) do
    resources = Repo.get!(Resources, id)
    resources |> remove_resource_file

    # Here we use delete! (with a bang) because we expect
    # it to always work (and if it does not, it will raise).
    Repo.delete!(resources)

    conn
    |> put_flash(:info, "Resources deleted successfully.")
    |> redirect(to: resources_path(conn, :index))
    
  end

  def send(conn, %{"filename" => basename}) do
    filename = "./printresources/#{basename}"
    conn
    |> put_resp_header("content-disposition", ~s(attachment; filename="#{filename |> Path.basename}"))
    |> send_file(200, filename)
  end

# HELPERS

  defp make_key_string(nil), do: ""
  defp make_key_string(list), do: list |> Enum.join(", ")

  defp remove_resource_file(%{url: nil}), do: :ok
  defp remove_resource_file(r) do
    filename = "./printresources/#{r.url}"
    if filename |> File.exists? do
      File.rm filename
    else
      # the file isn't there - carry on
      :ok
    end
  end

end
