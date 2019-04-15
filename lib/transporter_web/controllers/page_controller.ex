defmodule TransporterWeb.PageController do
  use TransporterWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end

  def webhook_get(conn, params) do
    IO.inspect(params)

    conn
    |> put_resp_content_type("application/json")
    |> send_resp(200, Poison.encode!(%{status: "received"}))
  end

  def webhook_post(conn, params) do
    IO.inspect(params)

    case params["scope"] do
      "reportJob" ->
        user = Repo.get_by(User, username: params["username"])
        job = Repo.get_by(Job, job_no: params["job_no"])

        {:ok, act} =
          case params["job_type"] do
            "gateman" ->
              {:ok, act} =
                Logistic.create_activity(
                  %{
                    job_id: job.id,
                    created_by: user.username,
                    created_id: user.id,
                    message: "#{user.username} has cleared custom for #{job.job_no}.",
                    location: Poison.encode!(params["position"])
                  },
                  job,
                  user
                )

              us = Repo.get_by(Logistic.UserJob, job_id: job.id, user_id: user.id)

              res = Logistic.update_user_job(us, %{status: "done"})
              IO.inspect(res)
              {:ok, act}

            "arrive" ->
              Logistic.create_activity(
                %{
                  job_id: job.id,
                  created_by: user.username,
                  created_id: user.id,
                  message: "#{user.username} arrived destination.",
                  location: Poison.encode!(params["position"])
                },
                job,
                user
              )

            "trailer" ->
              message = "has pickup container for #{job.job_no}"

              Logistic.create_activity(
                %{
                  job_id: job.id,
                  created_by: user.username,
                  created_id: user.id,
                  message: message,
                  location: Poison.encode!(params["position"])
                },
                job,
                user
              )
          end

        map = Logistic.image_upload(params["photos"], act.id)

        a =
          Logistic.create_image(%{
            activity_id: act.id,
            filename: map.filename,
            thumbnail: map.bin
          })

      "acceptJob" ->
        user = Repo.get_by(User, username: params["username"])
        job = Repo.get_by(Job, job_no: params["job_no"])

        message =
          if user.user_level == "LorryDriver" do
            "Accepted by #{user.username}. Pending pickup container from #{user.user_level}."
          else
            "#{user.username} accepted job #{job.job_no}."
          end

        {:ok, act} =
          Logistic.create_activity(
            %{
              job_id: job.id,
              created_by: user.username,
              created_id: user.id,
              message: message
            },
            job,
            user
          )

        res = Repo.all(from(u in UserJob, where: u.user_id == ^user.id and u.job_id == ^job.id))
        usj = List.first(res)
        Logistic.update_user_job(usj, %{status: "pending report"})
    end

    conn
    |> put_resp_content_type("application/json")
    |> send_resp(200, Poison.encode!(%{status: "received"}))
  end
end
