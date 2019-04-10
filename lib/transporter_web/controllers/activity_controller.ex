defmodule TransporterWeb.ActivityController do
  use TransporterWeb, :controller

  alias Transporter.Logistic
  alias Transporter.Logistic.Activity
  require IEx

  def index(conn, _params) do
    activities =
      Logistic.list_activities() |> Enum.map(fn x -> Map.put(x, :img_url, map_image(x.id)) end)

    render(conn, "index.html", activities: activities)
  end

  def map_image(activity_id) do
    a = Repo.get_by(Transporter.Logistic.Image, activity_id: activity_id)

    if a != nil do
      a.filename
    else
      ""
    end
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
      if user.user_level == "LorryDriver" && activity_params["image"] == nil do
        Map.put(
          activity_params,
          "message",
          "#{activity_params["message"]}"
        )
      else
        activity_params =
          Map.put(activity_params, "message", "#{user.username} #{activity_params["message"]}")
      end

    job = Repo.get(Job, activity_params["job_id"])

    assigned =
      job.last_activity |> String.split(" ") |> List.pop_at(2) |> elem(0)
      |> String.replace(".", "")

    # IEx.pry()

    if user.username == assigned do
      case Logistic.create_activity(activity_params, job) do
        {:ok, activity} ->
          if user.user_level == "LorryDriver" && activity_params["image"] != nil do
            map = Logistic.image_upload(activity_params["image"], activity.id)

            a =
              Logistic.create_image(%{
                activity_id: activity.id,
                filename: map.filename,
                thumbnail: map.bin
              })
          end

          conn
          |> put_flash(:info, "Activity updated successfully.")
          |> redirect(to: user_path(conn, :index))

        {:error, %Ecto.Changeset{} = changeset} ->
          render(conn, "new.html", changeset: changeset)
      end
    else
      if user.user_level == "LorryDriver" &&
           job.last_activity |> String.split(" ") |> List.pop_at(2) |> elem(0) == "pickup" do
        case Logistic.create_activity(activity_params, job) do
          {:ok, activity} ->
            if user.user_level == "LorryDriver" && activity_params["image"] != nil do
              map = Logistic.image_upload(activity_params["image"], activity.id)
            end

            a =
              Logistic.create_image(%{
                activity_id: activity.id,
                filename: map.filename,
                thumbnail: map.bin
              })

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
