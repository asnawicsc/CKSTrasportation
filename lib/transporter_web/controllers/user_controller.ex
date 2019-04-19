defmodule TransporterWeb.UserController do
  use TransporterWeb, :controller
  require IEx

  def index(conn, params) do
    users = Settings.list_users()

    users =
      if params["type"] != nil do
        Settings.list_users(params["type"])
      else
        users
      end
      |> Enum.map(fn x -> Map.put(x, :jobs, Logistic.list_user_jobs(x.id)) end)

    jobs = Logistic.list_jobs()

    containers = Repo.all(from(c in Container))

    # need to show the list of user jobs....

    render(conn, "index.html", users: users, jobs: jobs, containers: containers)
  end

  def new(conn, _params) do
    changeset = Settings.change_user(%User{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"user" => user_params}) do
    user_params =
      if user_params["password"] != nil do
        Map.put(
          user_params,
          "crypted_password",
          Comeonin.Bcrypt.hashpwsalt(user_params["password"])
        )
        |> Map.put("password", nil)
      end

    case Settings.create_user(user_params) do
      {:ok, user} ->
        conn
        |> put_flash(:info, "User created successfully.")
        |> redirect(to: user_path(conn, :show, user))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    user = Settings.get_user!(id)
    render(conn, "show.html", user: user)
  end

  def edit(conn, %{"id" => id}) do
    user = Settings.get_user!(id)
    changeset = Settings.change_user(user)
    render(conn, "edit.html", user: user, changeset: changeset)
  end

  def update(conn, %{"id" => id, "user" => user_params}) do
    user = Settings.get_user!(id)

    user_params =
      if user_params["password"] != "" do
        Map.put(
          user_params,
          "crypted_password",
          Comeonin.Bcrypt.hashpwsalt(user_params["password"])
        )
        |> Map.put("password", nil)
      else
        Map.delete(user_params, "password")
      end

    case Settings.update_user(user, user_params) do
      {:ok, user} ->
        conn
        |> put_flash(:info, "User updated successfully.")
        |> redirect(to: user_path(conn, :show, user))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", user: user, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    user = Settings.get_user!(id)
    {:ok, _user} = Settings.delete_user(user)

    conn
    |> put_flash(:info, "User deleted successfully.")
    |> redirect(to: user_path(conn, :index))
  end

  def login(conn, _params) do
    render(conn, "login.html", layout: {TransporterWeb.LayoutView, "full_bg.html"})
  end

  def authenticate_login(conn, %{"name" => name, "password" => password}) do
    user = Repo.get_by(User, username: name)

    if user != nil do
      if Comeonin.Bcrypt.checkpw(password, user.crypted_password) do
        conn
        |> put_flash(:info, "Welcome!")
        |> put_session(:user_id, user.id)
        |> put_session(:user_name, user.username)
        |> put_session(:user_type, user.user_type)
        |> redirect(to: page_path(conn, :index))
      else
        conn
        |> put_flash(:error, "Wrong password!")
        |> redirect(to: user_path(conn, :login))
      end
    else
      conn
      |> put_flash(:error, "User not found")
      |> redirect(to: user_path(conn, :login))
    end
  end

  def logout(conn, _params) do
    conn
    |> delete_session(:user_id)
    |> put_flash(:info, "Logout successfully")
    |> redirect(to: user_path(conn, :login))
  end
end
