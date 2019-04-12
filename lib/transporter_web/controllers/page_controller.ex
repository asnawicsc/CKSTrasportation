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
          Logistic.create_activity(
            %{
              job_id: job.id,
              created_by: user.username,
              created_id: user.id,
              message: "arrived destination.",
              location: Poison.encode!(params["position"])
            },
            job,
            user
          )

        map = Logistic.image_upload(params["photos"], act.id)

        a =
          Logistic.create_image(%{
            activity_id: act.id,
            filename: map.filename,
            thumbnail: map.bin
          })
    end

    conn
    |> put_resp_content_type("application/json")
    |> send_resp(200, Poison.encode!(%{status: "received"}))
  end
end
