defmodule TransporterWeb.PageController do
  use TransporterWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end

  def webhook_get(conn, params) do
    IO.inspect(params)

    case params["scope"] do
      "login" ->
        res = Repo.all(from(u in User, where: u.pin == ^params["pin"]))

        if res != [] do
          user = hd(res)

          conn
          |> put_resp_content_type("application/json")
          |> send_resp(200, Poison.encode!(%{username: user.username, level: user.user_level}))
        else
          conn
          |> put_resp_content_type("application/json")
          |> send_resp(200, Poison.encode!(%{status: "received"}))
        end

      _ ->
        conn
        |> put_resp_content_type("application/json")
        |> send_resp(200, Poison.encode!(%{status: "received"}))
    end
  end

  def webhook_post(conn, params) do
    IO.inspect(params)

    case params["scope"] do
      "reportJob" ->
        user = Repo.get_by(User, username: params["username"])
        # important: the job no received is actually the container no

        container =
          if params["job_type"] == "gateman" do
            %{job_no: params["job_no"], id: 0, name: ""}
          else
            Repo.all(from(c in Container, where: c.name == ^params["job_no"])) |> List.first()
          end

        job = Repo.get_by(Job, job_no: container.job_no)

        {:ok, act} =
          case params["job_type"] do
            "mover" ->
              {:ok, act} =
                Logistic.create_activity(
                  %{
                    job_id: job.id,
                    created_by: user.username,
                    created_id: user.id,
                    message: "#{user.username} has checked container #{container.name}.",
                    location: Poison.encode!(params["position"]),
                    container_id: container.id,
                    container_name: container.name
                  },
                  job,
                  user
                )

              us = Repo.get_by(Logistic.UserJob, job_id: job.id, user_id: user.id)
              names = job.containers |> String.split(",")
              containers = Repo.all(from(c in Container, where: c.name in ^names))
              res2 = Logistic.update_container(container, %{status: "Pending Transport"})
              IO.inspect(res2)

              rem = Enum.filter(containers, fn x -> x.status == "Pending Checking" end)

              if Enum.count(rem) == 0 do
                res = Logistic.update_user_job(us, %{status: "done"})
                IO.inspect(res)
              end

              {:ok, act}

            "gateman" ->
              {:ok, act} =
                Logistic.create_activity(
                  %{
                    job_id: job.id,
                    created_by: user.username,
                    created_id: user.id,
                    message: "#{user.username} has cleared custom for #{job.job_no}.",
                    location: Poison.encode!(params["position"]),
                    container_id: container.id,
                    container_name: container.name
                  },
                  job,
                  user
                )

              us = Repo.get_by(Logistic.UserJob, job_id: job.id, user_id: user.id)
              # when all become pending checking then only update...
              names = job.containers |> String.split(",")
              containers = Repo.all(from(c in Container, where: c.name in ^names))

              res10 =
                for container2 <- containers do
                  res2 = Logistic.update_container(container2, %{status: "Pending Checking"})
                end

              rem = Enum.filter(containers, fn x -> x.status == "Pending Clearance" end)

              if Enum.count(rem) == 0 do
                res = Logistic.update_user_job(us, %{status: "done"})

                users2 = Repo.all(from(u in User, where: u.user_level == ^"Gateman"))
                now = Timex.now() |> DateTime.to_unix(:millisecond)

                for user2 <- users2 do
                  jobq = %{"job_id" => job.id, "user_id" => user2.id}
                  us = Repo.get_by(Logistic.UserJob, job_id: job.id, user_id: user2.id)

                  if us == nil do
                    jobq = Map.put(jobq, "status", "pending accept")
                    {:ok, usj} = Logistic.create_user_job(jobq)

                    {:ok, act2} =
                      Logistic.create_activity(
                        %{
                          created_by: user.username,
                          created_id: user.id,
                          job_id: usj.job_id,
                          message:
                            "Assigned to #{user2.username}. Pending accept from #{
                              user2.user_level
                            }."
                        },
                        job,
                        user
                      )

                    topic = "location:#{user2.username}"
                    event = "new_request"

                    message = %{
                      job_no: job.job_no,
                      description: job.description,
                      insertedAt: now,
                      pendingContainers: job.containers,
                      completedContainers: ""
                    }

                    TransporterWeb.Endpoint.broadcast(topic, event, message)
                  end
                end
              else
                IEx.pry()
              end

              # broadcast to all the gateman... 

              {:ok, act}

            "arrive" ->
              {:ok, act} =
                Logistic.create_activity(
                  %{
                    job_id: job.id,
                    created_by: user.username,
                    created_id: user.id,
                    message:
                      "#{user.username} with container #{container.name} arrived destination.",
                    location: Poison.encode!(params["position"]),
                    container_id: container.id,
                    container_name: container.name,
                    trailer_no: params["trailer"],
                    delivery_type: params["type"],
                    delivery_mode: params["mode"]
                  },
                  job,
                  user
                )

              res2 = Logistic.update_container(container, %{status: "Arrived Destination"})
              IO.inspect(res2)

              {:ok, act}

            "trailer" ->
              message =
                "#{user.username} has pickup container #{container.name} for #{job.job_no}"

              {:ok, act} =
                Logistic.create_activity(
                  %{
                    job_id: job.id,
                    created_by: user.username,
                    created_id: user.id,
                    message: message,
                    location: Poison.encode!(params["position"]),
                    container_id: container.id,
                    container_name: container.name,
                    trailer_no: params["trailer"],
                    delivery_type: params["type"],
                    delivery_mode: params["mode"]
                  },
                  job,
                  user
                )

              res2 =
                Logistic.update_container(container, %{
                  status: "Pickup Container",
                  trailer_no: params["trailer_no"]
                })

              IO.inspect(res2)

              {:ok, act}
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
