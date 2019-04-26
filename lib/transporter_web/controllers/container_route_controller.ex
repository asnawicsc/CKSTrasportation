defmodule TransporterWeb.ContainerRouteController do
  use TransporterWeb, :controller

  alias Transporter.Logistic
  alias Transporter.Logistic.ContainerRoute
  require IEx

  def index(conn, _params) do
    container_routes = Logistic.list_container_routes()
    render(conn, "index.html", container_routes: container_routes)
  end

  def new(conn, _params) do
    changeset = Logistic.change_container_route(%ContainerRoute{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"container_route" => params}) do
    cont = Repo.get(Container, params["container_id"])
    params = Map.put(params, "job_id", cont.job_id)

    from = Repo.get_by(DeliveryLocation, name: params["from"])
    to = Repo.get_by(DeliveryLocation, name: params["to"])
    params = Map.put(params, "from_id", from.id)
    params = Map.put(params, "to_id", to.id)

    params =
      if conn.params["user_id"] != nil do
        user = Repo.get(User, conn.params["user_id"])

        if user != nil do
          params = Map.put(params, "driver_id", user.id)
          params = Map.put(params, "driver", user.username)
          params
        else
          params
        end
      else
        params
      end

    case Logistic.create_container_route(params) do
      {:ok, container_route} ->
        conn
        |> put_flash(:info, "Container route created successfully.")
        |> redirect(to: page_path(conn, :index))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    container_route = Logistic.get_container_route!(id)
    render(conn, "show.html", container_route: container_route)
  end

  def edit(conn, %{"id" => id}) do
    container_route = Logistic.get_container_route!(id)
    changeset = Logistic.change_container_route(container_route)
    render(conn, "edit.html", container_route: container_route, changeset: changeset)
  end

  def update(conn, %{"id" => id, "container_route" => container_route_params}) do
    container_route = Logistic.get_container_route!(id)

    case Logistic.update_container_route(container_route, container_route_params) do
      {:ok, container_route} ->
        conn
        |> put_flash(:info, "Container route updated successfully.")
        |> redirect(to: container_route_path(conn, :show, container_route))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", container_route: container_route, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    container_route = Logistic.get_container_route!(id)
    {:ok, _container_route} = Logistic.delete_container_route(container_route)

    conn
    |> put_flash(:info, "Container route deleted successfully.")
    |> redirect(to: container_route_path(conn, :index))
  end
end
