defmodule TransporterWeb.UserJobControllerTest do
  use TransporterWeb.ConnCase

  alias Transporter.Logistic

  @create_attrs %{job_id: 42, status: "some status", user_id: 42}
  @update_attrs %{job_id: 43, status: "some updated status", user_id: 43}
  @invalid_attrs %{job_id: nil, status: nil, user_id: nil}

  def fixture(:user_job) do
    {:ok, user_job} = Logistic.create_user_job(@create_attrs)
    user_job
  end

  describe "index" do
    test "lists all user_jobs", %{conn: conn} do
      conn = get conn, user_job_path(conn, :index)
      assert html_response(conn, 200) =~ "Listing User jobs"
    end
  end

  describe "new user_job" do
    test "renders form", %{conn: conn} do
      conn = get conn, user_job_path(conn, :new)
      assert html_response(conn, 200) =~ "New User job"
    end
  end

  describe "create user_job" do
    test "redirects to show when data is valid", %{conn: conn} do
      conn = post conn, user_job_path(conn, :create), user_job: @create_attrs

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == user_job_path(conn, :show, id)

      conn = get conn, user_job_path(conn, :show, id)
      assert html_response(conn, 200) =~ "Show User job"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post conn, user_job_path(conn, :create), user_job: @invalid_attrs
      assert html_response(conn, 200) =~ "New User job"
    end
  end

  describe "edit user_job" do
    setup [:create_user_job]

    test "renders form for editing chosen user_job", %{conn: conn, user_job: user_job} do
      conn = get conn, user_job_path(conn, :edit, user_job)
      assert html_response(conn, 200) =~ "Edit User job"
    end
  end

  describe "update user_job" do
    setup [:create_user_job]

    test "redirects when data is valid", %{conn: conn, user_job: user_job} do
      conn = put conn, user_job_path(conn, :update, user_job), user_job: @update_attrs
      assert redirected_to(conn) == user_job_path(conn, :show, user_job)

      conn = get conn, user_job_path(conn, :show, user_job)
      assert html_response(conn, 200) =~ "some updated status"
    end

    test "renders errors when data is invalid", %{conn: conn, user_job: user_job} do
      conn = put conn, user_job_path(conn, :update, user_job), user_job: @invalid_attrs
      assert html_response(conn, 200) =~ "Edit User job"
    end
  end

  describe "delete user_job" do
    setup [:create_user_job]

    test "deletes chosen user_job", %{conn: conn, user_job: user_job} do
      conn = delete conn, user_job_path(conn, :delete, user_job)
      assert redirected_to(conn) == user_job_path(conn, :index)
      assert_error_sent 404, fn ->
        get conn, user_job_path(conn, :show, user_job)
      end
    end
  end

  defp create_user_job(_) do
    user_job = fixture(:user_job)
    {:ok, user_job: user_job}
  end
end
