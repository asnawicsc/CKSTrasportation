defmodule TransporterWeb.UserJobController do
  use TransporterWeb, :controller

  alias Transporter.Logistic
  alias Transporter.Logistic.UserJob

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
