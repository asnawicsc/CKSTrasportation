defmodule TransporterWeb.PageController do
  use TransporterWeb, :controller
  require IEx

  def delivery(conn, params) do
    data = Transporter.Logistic.delivery_summary()

    IO.inspect(data)
    render(conn, "delivery_summary.html", data: data)
  end

  def container(conn, params) do
    data = Transporter.Logistic.outstanding_container()

    IO.inspect(data)
    render(conn, "outstanding_container.html", data: data)
  end

  def forwarding(conn, params) do
    data = Transporter.Logistic.outstanding_forwarding()
    IO.inspect(data)
    render(conn, "outstanding_forwarding.html", data: data)
  end

  def index(conn, _params) do
    info =
      Repo.all(
        from(
          j in Job,
          left_join: c in Container,
          on: c.job_id == j.id,
          select: %{
            job_id: j.id,
            job_no: j.job_no,
            vessel_name: j.vessel_name,
            voyage_no: j.voyage_no,
            container: c.name
          },
          order_by: [c.name]
        )
      )
      |> Enum.map(fn x -> Map.put(x, :forwarder_assign, find_act("forwarder_assign", x)) end)
      |> Enum.map(fn x -> Map.put(x, :forwarder_assigned, find_act("forwarder_ack", x)) end)
      |> Enum.map(fn x -> Map.put(x, :forwarder_clear, find_act("forwarder_clear", x)) end)
      |> Enum.map(fn x -> Map.put(x, :gateman_assigned, find_act("gateman_assigned", x)) end)
      |> Enum.map(fn x -> Map.put(x, :gateman_ack, find_act("gateman_ack", x)) end)
      |> Enum.map(fn x -> Map.put(x, :gateman_clear, find_act("gateman_clear", x)) end)
      |> Enum.map(fn x ->
        Map.put(x, :lorrydriver_assigned, find_act("lorrydriver_assigned", x))
      end)
      |> Enum.map(fn x -> Map.put(x, :out_lorrydriver_ack, find_act("out_lorrydriver_ack", x)) end)
      |> Enum.map(fn x ->
        Map.put(x, :out_lorrydriver_start, find_act("out_lorrydriver_start", x))
      end)
      |> Enum.map(fn x -> Map.put(x, :out_lorrydriver_end, find_act("out_lorrydriver_end", x)) end)

    activities = Logistic.list_activities()
    render(conn, "index.html", activities: activities, info: info)
  end

  def find_act(type, x) do
    lorry = [
      # "lorrydriver_assigned",
      # "out_lorrydriver_ack",
      "out_lorrydriver_start",
      "out_lorrydriver_end"
    ]

    gate = ["gateman_clear"]

    res =
      if Enum.any?(lorry, fn x -> x == type end) || Enum.any?(gate, fn x -> x == type end) do
        Repo.all(
          from(
            a in Activity,
            where:
              a.job_id == ^x.job_id and a.activity_type == ^type and
                a.container_name == ^x.container,
            select: %{datetime: a.inserted_at, pic: a.created_by}
          )
        )
      else
        Repo.all(
          from(
            a in Activity,
            where: a.job_id == ^x.job_id and a.activity_type == ^type,
            select: %{datetime: a.inserted_at, pic: a.created_by}
          )
        )
      end

    if res != [] do
      hd(res)
    else
      nil
    end
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
                    container_name: container.name,
                    activity_type: "gateman_clear"
                  },
                  job,
                  user
                )

              us = Repo.get_by(Logistic.UserJob, job_id: job.id, user_id: user.id)
              names = job.containers |> String.split(",")
              containers = Repo.all(from(c in Container, where: c.name in ^names))

              res2 =
                Logistic.update_container(container, %{
                  status: "Pending Transport",
                  return_depot: params["return_depot"]
                })

              rem = Enum.filter(containers, fn x -> x.status == "Pending Checking" end)

              if Enum.count(rem) == 0 do
                res = Logistic.update_user_job(us, %{status: "done"})
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
                    container_name: container.name,
                    activity_type: "forwarder_clear"
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

              containers3 = Repo.all(from(c in Container, where: c.name in ^names))
              rem = Enum.filter(containers3, fn x -> x.status == "Pending Clearance" end)

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
                            }.",
                          activity_type: "gateman_assigned"
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
                      completedContainers: "",
                      by: act2.created_by
                    }

                    TransporterWeb.Endpoint.broadcast(topic, event, message)
                  end
                end
              else
                IO.print("error...")
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
                    delivery_mode: params["mode"],
                    activity_type: "out_lorrydriver_end"
                  },
                  job,
                  user
                )

              res2 = Logistic.update_container(container, %{status: "Arrived Destination"})

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
                    delivery_mode: params["mode"],
                    activity_type: "out_lorrydriver_start"
                  },
                  job,
                  user
                )

              res2 =
                Logistic.update_container(container, %{
                  status: "Pickup Container",
                  trailer_no: params["trailer_no"]
                })

              {:ok, act}
          end

        if params["photos"] != nil do
          map = Logistic.image_upload(params["photos"], act.id)

          a =
            Logistic.create_image(%{
              activity_id: act.id,
              filename: map.filename,
              thumbnail: map.bin
            })
        end

      "acceptJob" ->
        user = Repo.get_by(User, username: params["username"])
        job = Repo.get_by(Job, job_no: params["job_no"])

        message =
          if user.user_level == "LorryDriver" do
            "Accepted by #{user.username}. Pending pickup container from #{user.user_level}."
          else
            "#{user.username} accepted job #{job.job_no}."
          end

        message2 =
          if user.user_level == "LorryDriver" do
            "out_lorrydriver_ack"
          else
            "#{String.downcase(user.user_level)}_ack"
          end

        {:ok, act} =
          Logistic.create_activity(
            %{
              job_id: job.id,
              created_by: user.username,
              created_id: user.id,
              message: message,
              activity_type: message2
            },
            job,
            user
          )

        res = Repo.all(from(u in UserJob, where: u.user_id == ^user.id and u.job_id == ^job.id))
        usj = List.first(res)
        Logistic.update_user_job(usj, %{status: "pending report"})
        # if some one cant finish the job... we dont have a handling for this situation yet.
        # its expected the users finish the job when they acknowledge it.
    end

    conn
    |> put_resp_content_type("application/json")
    |> send_resp(200, Poison.encode!(%{status: "received"}))
  end
end
