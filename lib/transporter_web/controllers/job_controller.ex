defmodule TransporterWeb.JobController do
  use TransporterWeb, :controller

  alias Transporter.Logistic
  alias Transporter.Logistic.Job

  def index(conn, _params) do
    jobs = Logistic.list_jobs()
    render(conn, "index.html", jobs: jobs)
  end

  def new(conn, _params) do
    changeset = Logistic.change_job(%Job{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"job" => job_params}) do
    job_params = Map.put(job_params, "created_by", conn.private.plug_session["user_name"])

    case Logistic.create_job(job_params) do
      {:ok, job} ->
        case job_params["job_type"] do
          "Import" ->
            {:ok, act} =
              Logistic.create_activity(%{
                created_by: "System",
                created_id: 0,
                job_id: job.id,
                message: "Pending assignment for Forwarder."
              })

            Logistic.update_job(job, %{last_activity: act.message, last_by: "System"})

            true

          "Export" ->
            true

          "Local Transport" ->
            true
        end

        conn
        |> put_flash(:info, "Job created successfully.")
        |> redirect(to: job_path(conn, :show, job))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    job = Logistic.get_job!(id)
    render(conn, "show.html", job: job)
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
