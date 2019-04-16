defmodule TransporterWeb.DeliveryLocationControllerTest do
  use TransporterWeb.ConnCase

  alias Transporter.Settings

  @create_attrs %{name: "some name", zone: "some zone"}
  @update_attrs %{name: "some updated name", zone: "some updated zone"}
  @invalid_attrs %{name: nil, zone: nil}

  def fixture(:delivery_location) do
    {:ok, delivery_location} = Settings.create_delivery_location(@create_attrs)
    delivery_location
  end

  describe "index" do
    test "lists all delivery_location", %{conn: conn} do
      conn = get conn, delivery_location_path(conn, :index)
      assert html_response(conn, 200) =~ "Listing Delivery location"
    end
  end

  describe "new delivery_location" do
    test "renders form", %{conn: conn} do
      conn = get conn, delivery_location_path(conn, :new)
      assert html_response(conn, 200) =~ "New Delivery location"
    end
  end

  describe "create delivery_location" do
    test "redirects to show when data is valid", %{conn: conn} do
      conn = post conn, delivery_location_path(conn, :create), delivery_location: @create_attrs

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == delivery_location_path(conn, :show, id)

      conn = get conn, delivery_location_path(conn, :show, id)
      assert html_response(conn, 200) =~ "Show Delivery location"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post conn, delivery_location_path(conn, :create), delivery_location: @invalid_attrs
      assert html_response(conn, 200) =~ "New Delivery location"
    end
  end

  describe "edit delivery_location" do
    setup [:create_delivery_location]

    test "renders form for editing chosen delivery_location", %{conn: conn, delivery_location: delivery_location} do
      conn = get conn, delivery_location_path(conn, :edit, delivery_location)
      assert html_response(conn, 200) =~ "Edit Delivery location"
    end
  end

  describe "update delivery_location" do
    setup [:create_delivery_location]

    test "redirects when data is valid", %{conn: conn, delivery_location: delivery_location} do
      conn = put conn, delivery_location_path(conn, :update, delivery_location), delivery_location: @update_attrs
      assert redirected_to(conn) == delivery_location_path(conn, :show, delivery_location)

      conn = get conn, delivery_location_path(conn, :show, delivery_location)
      assert html_response(conn, 200) =~ "some updated name"
    end

    test "renders errors when data is invalid", %{conn: conn, delivery_location: delivery_location} do
      conn = put conn, delivery_location_path(conn, :update, delivery_location), delivery_location: @invalid_attrs
      assert html_response(conn, 200) =~ "Edit Delivery location"
    end
  end

  describe "delete delivery_location" do
    setup [:create_delivery_location]

    test "deletes chosen delivery_location", %{conn: conn, delivery_location: delivery_location} do
      conn = delete conn, delivery_location_path(conn, :delete, delivery_location)
      assert redirected_to(conn) == delivery_location_path(conn, :index)
      assert_error_sent 404, fn ->
        get conn, delivery_location_path(conn, :show, delivery_location)
      end
    end
  end

  defp create_delivery_location(_) do
    delivery_location = fixture(:delivery_location)
    {:ok, delivery_location: delivery_location}
  end
end
