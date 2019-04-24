defmodule TransporterWeb.ContainerRouteControllerTest do
  use TransporterWeb.ConnCase

  alias Transporter.Logistic

  @create_attrs %{container_id: 42, driver: "some driver", driver_id: 42, from: "some from", from_id: 42, job_id: 42, lorry: "some lorry", to: "some to", to_id: 42}
  @update_attrs %{container_id: 43, driver: "some updated driver", driver_id: 43, from: "some updated from", from_id: 43, job_id: 43, lorry: "some updated lorry", to: "some updated to", to_id: 43}
  @invalid_attrs %{container_id: nil, driver: nil, driver_id: nil, from: nil, from_id: nil, job_id: nil, lorry: nil, to: nil, to_id: nil}

  def fixture(:container_route) do
    {:ok, container_route} = Logistic.create_container_route(@create_attrs)
    container_route
  end

  describe "index" do
    test "lists all container_routes", %{conn: conn} do
      conn = get conn, container_route_path(conn, :index)
      assert html_response(conn, 200) =~ "Listing Container routes"
    end
  end

  describe "new container_route" do
    test "renders form", %{conn: conn} do
      conn = get conn, container_route_path(conn, :new)
      assert html_response(conn, 200) =~ "New Container route"
    end
  end

  describe "create container_route" do
    test "redirects to show when data is valid", %{conn: conn} do
      conn = post conn, container_route_path(conn, :create), container_route: @create_attrs

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == container_route_path(conn, :show, id)

      conn = get conn, container_route_path(conn, :show, id)
      assert html_response(conn, 200) =~ "Show Container route"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post conn, container_route_path(conn, :create), container_route: @invalid_attrs
      assert html_response(conn, 200) =~ "New Container route"
    end
  end

  describe "edit container_route" do
    setup [:create_container_route]

    test "renders form for editing chosen container_route", %{conn: conn, container_route: container_route} do
      conn = get conn, container_route_path(conn, :edit, container_route)
      assert html_response(conn, 200) =~ "Edit Container route"
    end
  end

  describe "update container_route" do
    setup [:create_container_route]

    test "redirects when data is valid", %{conn: conn, container_route: container_route} do
      conn = put conn, container_route_path(conn, :update, container_route), container_route: @update_attrs
      assert redirected_to(conn) == container_route_path(conn, :show, container_route)

      conn = get conn, container_route_path(conn, :show, container_route)
      assert html_response(conn, 200) =~ "some updated driver"
    end

    test "renders errors when data is invalid", %{conn: conn, container_route: container_route} do
      conn = put conn, container_route_path(conn, :update, container_route), container_route: @invalid_attrs
      assert html_response(conn, 200) =~ "Edit Container route"
    end
  end

  describe "delete container_route" do
    setup [:create_container_route]

    test "deletes chosen container_route", %{conn: conn, container_route: container_route} do
      conn = delete conn, container_route_path(conn, :delete, container_route)
      assert redirected_to(conn) == container_route_path(conn, :index)
      assert_error_sent 404, fn ->
        get conn, container_route_path(conn, :show, container_route)
      end
    end
  end

  defp create_container_route(_) do
    container_route = fixture(:container_route)
    {:ok, container_route: container_route}
  end
end
