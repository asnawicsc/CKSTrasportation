defmodule TransporterWeb.JobController do
  use TransporterWeb, :controller

  alias Transporter.Logistic
  alias Transporter.Logistic.Job
  require IEx

  def index(conn, _params) do
    jobs = Logistic.list_jobs()
    render(conn, "index.html", jobs: jobs)
  end

  def new(conn, _params) do
    changeset =
      Job.changeset(%Job{}, %{
        eta: Timex.now(),
        ata: Timex.now(),
        atb: Timex.now(),
        dd_date: Timex.now()
      })

    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"job" => job_params}) do
    job_params = Map.put(job_params, "created_by", conn.private.plug_session["user_name"])

    case Logistic.create_job(job_params) do
      {:ok, job} ->
        case job_params["job_type"] do
          "Import" ->
            {:ok, act} =
              Logistic.create_activity(
                %{
                  created_by: "System",
                  created_id: 1,
                  job_id: job.id,
                  message: "Pending assignment for Forwarder.",
                  activity_type: "forwarder_assign"
                },
                job,
                Repo.get(User, conn.private.plug_session["user_id"])
              )

            true

          "Export" ->
            true

          "Local Transport" ->
            true
        end

        for name <- job_params["containers"] |> String.split(",") do
          a =
            Logistic.create_container(%{
              job_id: job.id,
              job_no: job.job_no,
              name: String.trim(name)
            })

          IO.inspect(a)
        end

        conn
        |> put_flash(:info, "Job created successfully.")
        |> redirect(to: job_path(conn, :show, job))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def map_image(activity_id) do
    a = Repo.get_by(Transporter.Logistic.Image, activity_id: activity_id)

    if a != nil do
      a.filename
    else
      ""
    end
  end

  def show(conn, %{"id" => id}) do
    job = Logistic.get_job!(id)

    activities =
      Logistic.list_activities(job.id)
      |> Enum.map(fn x -> Map.put(x, :img_url, map_image(x.id)) end)
      |> Enum.map(fn x -> Map.put(x, :date, format_date(x.inserted_at)) end)
      |> Enum.group_by(fn x -> x.date end)

    render(conn, "show.html", job: job, activities: activities)
  end

  def format_date(inserted_at) do
    "#{inserted_at.day}-#{inserted_at.month}-#{inserted_at.year}"
  end

  def edit(conn, %{"id" => id}) do
    job = Logistic.get_job!(id)
    changeset = Logistic.change_job(job)
    render(conn, "edit.html", job: job, changeset: changeset)
  end

  def update(conn, %{"id" => id, "job" => job_params}) do
    job = Logistic.get_job!(id)

    case Logistic.update_job(job, job_params) do
      {:ok, job} ->
        conn
        |> put_flash(:info, "Job updated successfully.")
        |> redirect(to: job_path(conn, :show, job))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", job: job, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    job = Logistic.get_job!(id)
    {:ok, _job} = Logistic.delete_job(job)

    conn
    |> put_flash(:info, "Job deleted successfully.")
    |> redirect(to: job_path(conn, :index))
  end
end
