defmodule TransporterWeb.ActivityController do
  use TransporterWeb, :controller

  alias Transporter.Logistic
  alias Transporter.Logistic.Activity
  require IEx

  def index(conn, _params) do
    activities = Logistic.list_activities()
    render(conn, "index.html", activities: activities)
  end

  def new(conn, _params) do
    changeset = Logistic.change_activity(%Activity{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"activity" => activity_params}) do
    user = Repo.get(User, conn.private.plug_session["user_id"])
    activity_params = Map.put(activity_params, "created_by", user.username)
    activity_params = Map.put(activity_params, "created_id", user.id)

    activity_params =
      Map.put(activity_params, "message", "#{user.username} #{activity_params["message"]}")

    job = Repo.get(Job, activity_params["job_id"])

    assigned =
      job.last_activity |> String.split(" ") |> List.pop_at(2) |> elem(0)
      |> String.replace(".", "")

    if user.username == assigned do
      case Logistic.create_activity(activity_params, job) do
        {:ok, activity} ->
          conn
          |> put_flash(:info, "Activity updated successfully.")
          |> redirect(to: user_path(conn, :index))

        {:error, %Ecto.Changeset{} = changeset} ->
          render(conn, "new.html", changeset: changeset)
      end
    else
      conn
      |> put_flash(:error, "Wasnt assigned to you.")
      |> redirect(to: user_path(conn, :index))
    end
  end

  def show(conn, %{"id" => id}) do
    activity = Logistic.get_activity!(id)
    render(conn, "show.html", activity: activity)
  end

  def edit(conn, %{"id" => id}) do
    activity = Logistic.get_activity!(id)
    changeset = Logistic.change_activity(activity)
    render(conn, "edit.html", activity: activity, changeset: changeset)
  end

  def update(conn, %{"id" => id, "activity" => activity_params}) do
    activity = Logistic.get_activity!(id)

    case Logistic.update_activity(activity, activity_params) do
      {:ok, activity} ->
        conn
        |> put_flash(:info, "Activity updated successfully.")
        |> redirect(to: activity_path(conn, :show, activity))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", activity: activity, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    activity = Logistic.get_activity!(id)
    {:ok, _activity} = Logistic.delete_activity(activity)

    conn
    |> put_flash(:info, "Activity deleted successfully.")
    |> redirect(to: activity_path(conn, :index))
  end
end
