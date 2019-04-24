defmodule TransporterWeb.UserJobController do
  use TransporterWeb, :controller

  alias Transporter.Logistic
  alias Transporter.Logistic.UserJob
  # require IEx

  def save_assignment(conn, params) do
    if params["map_job"] == "" do
      conn
      |> put_flash(:error, "Empty info.")
      |> redirect(to: user_path(conn, :index))
    else
      map_job = params["map_job"] |> Poison.decode!() |> Enum.uniq()

      for jobq <- map_job do
        us = Repo.get_by(Logistic.UserJob, job_id: jobq["job_id"], user_id: jobq["user_id"])
        IO.inspect(jobq)

        if us == nil do
          jobq = Map.put(jobq, "status", "pending accept")
          {:ok, usj} = Logistic.create_user_job(jobq)

          user = Repo.get(User, usj.user_id)

          if jobq["container_id"] != nil do
            container = Repo.get(Container, jobq["container_id"])

            if user.user_level == "LorryDriver" && container != nil do
              {:ok, con} =
                Logistic.update_container(container, %{
                  driver_name: user.username,
                  driver_id: user.id
                })
            end
          end

          {:ok, act} =
            Logistic.create_activity(
              %{
                created_by: conn.private.plug_session["user_name"],
                created_id: usj.user_id,
                job_id: usj.job_id,
                message: "Assigned to #{user.username}. Pending accept from #{user.user_level}.",
                activity_type: "#{String.downcase(user.user_level)}_assigned"
              },
              Repo.get(Job, usj.job_id),
              Repo.get(User, conn.private.plug_session["user_id"])
            )

          topic = "location:#{user.username}"
          event = "new_request"

          j = Repo.get(Job, usj.job_id)

          names = j.containers |> String.split(",")
          containers = Repo.all(from(c in Container, where: c.name in ^names))

          pending_containers =
            if user.user_level == "LorryDriver" do
              containers |> Enum.filter(fn x -> x.status == "Pending Transport" end)
            else
              containers
            end

          pending_containers =
            pending_containers
            |> Enum.map(fn x -> x.name end)
            |> Enum.join(",")

          desc =
            if user.user_level == "LorryDriver" && jobq["route_id"] != nil do
              route = Repo.get(ContainerRoute, jobq["route_id"])

              if route != nil do
                "#{route.from} to #{route.to}"
              else
                "route not set"
              end
            else
              j.description
            end

          message = %{
            job_no: j.job_no,
            description: desc,
            insertedAt: Timex.now() |> DateTime.to_unix(:millisecond),
            pendingContainers: pending_containers,
            completedContainers: ""
          }

          TransporterWeb.Endpoint.broadcast(topic, event, message)
        else
          user = Repo.get(User, us.user_id)

          if jobq["container_id"] != nil do
            container = Repo.get(Container, jobq["container_id"])

            if user.user_level == "LorryDriver" && container != nil do
              {:ok, con} =
                Logistic.update_container(container, %{
                  driver_name: user.username,
                  driver_id: user.id
                })
            end
          end

          if user.user_level == "LorryDriver" do
            {:ok, act} =
              Logistic.create_activity(
                %{
                  created_by: conn.private.plug_session["user_name"],
                  created_id: us.user_id,
                  job_id: us.job_id,
                  message: "Assigned to #{user.username}. Pending accept from #{user.user_level}.",
                  activity_type: "#{String.downcase(user.user_level)}_assigned"
                },
                Repo.get(Job, us.job_id),
                Repo.get(User, conn.private.plug_session["user_id"])
              )

            topic = "location:#{user.username}"
            event = "new_request"

            j = Repo.get(Job, us.job_id)

            message = %{
              job_no: j.job_no,
              description: j.description,
              insertedAt: Timex.now() |> DateTime.to_unix(:millisecond)
            }

            TransporterWeb.Endpoint.broadcast(topic, event, message)
          end
        end
      end

      conn
      |> put_flash(:info, "User job created successfully.")
      |> redirect(to: user_path(conn, :index))
    end
  end

  def index(conn, _params) do
    user_jobs = Logistic.list_user_jobs()
    render(conn, "index.html", user_jobs: user_jobs)
  end

  def new(conn, _params) do
    changeset = Logistic.change_user_job(%UserJob{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"user_job" => user_job_params}) do
    case Logistic.create_user_job(user_job_params) do
      {:ok, user_job} ->
        conn
        |> put_flash(:info, "User job created successfully.")
        |> redirect(to: user_job_path(conn, :show, user_job))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    user_job = Logistic.get_user_job!(id)
    render(conn, "show.html", user_job: user_job)
  end

  def edit(conn, %{"id" => id}) do
    user_job = Logistic.get_user_job!(id)
    changeset = Logistic.change_user_job(user_job)
    render(conn, "edit.html", user_job: user_job, changeset: changeset)
  end

  def update(conn, %{"id" => id, "user_job" => user_job_params}) do
    user_job = Logistic.get_user_job!(id)

    case Logistic.update_user_job(user_job, user_job_params) do
      {:ok, user_job} ->
        conn
        |> put_flash(:info, "User job updated successfully.")
        |> redirect(to: user_job_path(conn, :show, user_job))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", user_job: user_job, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    user_job = Logistic.get_user_job!(id)
    {:ok, _user_job} = Logistic.delete_user_job(user_job)

    conn
    |> put_flash(:info, "User job deleted successfully.")
    |> redirect(to: user_job_path(conn, :index))
  end
end
