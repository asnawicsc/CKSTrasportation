defmodule TransporterWeb.DeliveryLocationController do
  use TransporterWeb, :controller

  alias Transporter.Settings
  alias Transporter.Settings.DeliveryLocation

  def index(conn, _params) do
    delivery_location = Settings.list_delivery_location()
    render(conn, "index.html", delivery_location: delivery_location)
  end

  def new(conn, _params) do
    changeset = Settings.change_delivery_location(%DeliveryLocation{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"delivery_location" => delivery_location_params}) do
    case Settings.create_delivery_location(delivery_location_params) do
      {:ok, delivery_location} ->
        conn
        |> put_flash(:info, "Delivery location created successfully.")
        |> redirect(to: delivery_location_path(conn, :show, delivery_location))
      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    delivery_location = Settings.get_delivery_location!(id)
    render(conn, "show.html", delivery_location: delivery_location)
  end

  def edit(conn, %{"id" => id}) do
    delivery_location = Settings.get_delivery_location!(id)
    changeset = Settings.change_delivery_location(delivery_location)
    render(conn, "edit.html", delivery_location: delivery_location, changeset: changeset)
  end

  def update(conn, %{"id" => id, "delivery_location" => delivery_location_params}) do
    delivery_location = Settings.get_delivery_location!(id)

    case Settings.update_delivery_location(delivery_location, delivery_location_params) do
      {:ok, delivery_location} ->
        conn
        |> put_flash(:info, "Delivery location updated successfully.")
        |> redirect(to: delivery_location_path(conn, :show, delivery_location))
      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", delivery_location: delivery_location, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    delivery_location = Settings.get_delivery_location!(id)
    {:ok, _delivery_location} = Settings.delete_delivery_location(delivery_location)

    conn
    |> put_flash(:info, "Delivery location deleted successfully.")
    |> redirect(to: delivery_location_path(conn, :index))
  end
end
