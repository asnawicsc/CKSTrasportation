defmodule TransporterWeb.ContainerController do
  use TransporterWeb, :controller

  alias Transporter.Logistic
  alias Transporter.Logistic.Container

  def index(conn, _params) do
    containers = Logistic.list_containers()
    render(conn, "index.html", containers: containers)
  end

  def new(conn, _params) do
    changeset = Logistic.change_container(%Container{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"container" => container_params}) do
    case Logistic.create_container(container_params) do
      {:ok, container} ->
        conn
        |> put_flash(:info, "Container created successfully.")
        |> redirect(to: container_path(conn, :show, container))
      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    container = Logistic.get_container!(id)
    render(conn, "show.html", container: container)
  end

  def edit(conn, %{"id" => id}) do
    container = Logistic.get_container!(id)
    changeset = Logistic.change_container(container)
    render(conn, "edit.html", container: container, changeset: changeset)
  end

  def update(conn, %{"id" => id, "container" => container_params}) do
    container = Logistic.get_container!(id)

    case Logistic.update_container(container, container_params) do
      {:ok, container} ->
        conn
        |> put_flash(:info, "Container updated successfully.")
        |> redirect(to: container_path(conn, :show, container))
      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", container: container, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    container = Logistic.get_container!(id)
    {:ok, _container} = Logistic.delete_container(container)

    conn
    |> put_flash(:info, "Container deleted successfully.")
    |> redirect(to: container_path(conn, :index))
  end
end
