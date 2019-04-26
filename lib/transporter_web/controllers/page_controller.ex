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
            container: c.name,
            customer: j.customer,
            pic: j.created_by,
            eta: j.eta,
            etb: j.atb,
            dd: j.dd_date
          },
          order_by: [c.name]
        )
      )
      |> Enum.map(fn x -> Map.put(x, :forwarder_assign, find_act("forwarder_assign", x)) end)
      |> Enum.map(fn x -> Map.put(x, :forwarder_assigned, find_act("forwarder_assigned", x)) end)
      |> Enum.map(fn x -> Map.put(x, :forwarder_ack, find_act("forwarder_ack", x)) end)
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
      |> Enum.map(fn x ->
        Map.put(x, :in_lorrydriver_start, find_act("in_lorrydriver_start", x))
      end)
      |> Enum.map(fn x -> Map.put(x, :in_lorrydriver_end, find_act("in_lorrydriver_end", x)) end)
      |> Enum.map(fn x -> Map.put(x, :bal, get_last_day(x.dd, x.job_id)) end)

    activities = Logistic.list_activities()
    containers = Logistic.list_containers()
    user_data = Settings.list_users()
    users = user_data |> Enum.filter(fn x -> x.user_level == "LorryDriver" end)
    forwarders = user_data |> Enum.filter(fn x -> x.user_level == "Forwarder" end)

    html =
      Phoenix.View.render_to_string(
        TransporterWeb.UserView,
        "user_level.html",
        users: forwarders,
        conn: conn
      )

    locations = Settings.list_delivery_location()

    render(
      conn,
      "index.html",
      activities: activities,
      info: info,
      users: users,
      containers: containers,
      locations: locations
    )
  end

  def get_last_day(dd_date, job_id) do
    latest =
      Repo.all(
        from(
          a in Activity,
          where: a.job_id == ^job_id,
          select: a.inserted_at,
          order_by: [a.inserted_at]
        )
      )
      |> List.last()

    seconds =
      DateTime.diff(
        DateTime.from_naive!(dd_date, "Etc/UTC"),
        DateTime.from_naive!(latest, "Etc/UTC"),
        1
      )

    Timex.Duration.from_seconds(seconds) |> Timex.format_duration(:humanized) |> String.split(",")
    |> hd()
  end

  def find_act(type, x) do
    lorry = [
      # "lorrydriver_assigned",
      # "out_lorrydriver_ack",
      "out_lorrydriver_start",
      "out_lorrydriver_end",
      "in_lorrydriver_start",
      "in_lorrydriver_end"
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
    user_data = Settings.list_users()

    case params["scope"] do
      "get_users" ->
        users = user_data |> Enum.filter(fn x -> x.user_level == params["level"] end)

        html =
          Phoenix.View.render_to_string(
            TransporterWeb.UserView,
            "user_level.html",
            users: users,
            conn: conn
          )

        json_map = Poison.encode!(html)

        conn
        |> put_resp_content_type("application/json")
        |> send_resp(200, json_map)

      "show_job" ->
        job = Logistic.get_job!(params["job_id"])

        activities =
          Logistic.list_activities(job.id)
          |> Enum.map(fn x ->
            Map.put(x, :img_url, TransporterWeb.JobController.map_image(x.id))
          end)
          |> Enum.map(fn x ->
            Map.put(x, :date, TransporterWeb.JobController.format_date(x.inserted_at))
          end)
          |> Enum.group_by(fn x -> x.date end)

        html =
          Phoenix.View.render_to_string(
            TransporterWeb.JobView,
            "show.html",
            job: job,
            activities: activities,
            conn: conn
          )

        json_map = Poison.encode!(html)

        conn
        |> put_resp_content_type("application/json")
        |> send_resp(200, json_map)

      "route_used" ->
        res =
          Repo.all(
            from(
              cr in ContainerRoute,
              left_join: c in Container,
              on: c.id == cr.container_id,
              left_join: u in User,
              on: cr.driver_id == u.id,
              where: cr.container_id == ^params["cont_id"],
              select: %{
                to: cr.to,
                from: cr.from,
                driver: cr.driver,
                truck: u.truck_type,
                no: u.truck_no
              }
            )
          )

        json_map = Poison.encode!(res)

        conn
        |> put_resp_content_type("application/json")
        |> send_resp(200, json_map)

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
              names = job.containers |> String.split(",") |> Enum.map(fn x -> String.trim(x) end)
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

              # assign to drivers
              cr_res =
                Repo.all(
                  from(
                    cr in ContainerRoute,
                    left_join: d in DeliveryLocation,
                    on: cr.from_id == d.id,
                    where: cr.container_id == ^container.id and d.zone == "Home",
                    select: {cr.driver_id, cr.id}
                  )
                )

              if cr_res != [] do
                user2 = Repo.get(User, elem(hd(cr_res), 0))

                jobq = %{
                  "job_id" => job.id,
                  "user_id" => user2.id,
                  "route_id" => elem(hd(cr_res), 1)
                }

                us =
                  Repo.get_by(
                    Logistic.UserJob,
                    job_id: job.id,
                    user_id: user2.id,
                    route_id: elem(hd(cr_res), 1)
                  )

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
                          "Assigned to #{user2.username}. Pending accept from #{user2.user_level}.",
                        activity_type: "lorrydriver_assigned"
                      },
                      job,
                      user
                    )

                  topic = "location:#{user2.username}"
                  event = "new_request"

                  desc =
                    if user2.user_level == "LorryDriver" && elem(hd(cr_res), 1) != nil do
                      route = Repo.get(ContainerRoute, elem(hd(cr_res), 1))

                      if route != nil do
                        "#{route.from} to #{route.to}"
                      else
                        "route not set"
                      end
                    else
                      job.description
                    end

                  jobno =
                    if user2.user_level == "LorryDriver" && elem(hd(cr_res), 1) != nil do
                      "#{job.job_no}_#{elem(hd(cr_res), 1)}"
                    else
                      job.job_no
                    end

                  message = %{
                    job_no: jobno,
                    description: desc,
                    insertedAt: Timex.now() |> DateTime.to_unix(:millisecond),
                    pendingContainers: elem(res2, 1).name,
                    completedContainers: "",
                    by: act.created_by
                  }

                  TransporterWeb.Endpoint.broadcast(topic, event, message)
                else
                  # user job already exist?
                end
              else
                # route wasn't assigned, then how?
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
              names = job.containers |> String.split(",") |> Enum.map(fn x -> String.trim(x) end)
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
              route = Repo.get(ContainerRoute, params["route_id"])

              type =
                if route != nil do
                  loc = Repo.get_by(DeliveryLocation, name: route.to)

                  if loc.zone == "Home" do
                    "in_lorrydriver_end"
                  else
                    "out_lorrydriver_end"
                  end
                else
                  "error no route found..."
                end

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
                    activity_type: type
                  },
                  job,
                  user
                )

              res2 = Logistic.update_container(container, %{status: "Arrived Destination"})

              usj =
                Repo.get_by(
                  UserJob,
                  user_id: user.id,
                  job_id: job.id,
                  route_id: params["route_id"]
                )

              Logistic.update_user_job(usj, %{status: "done"})
              {:ok, act}

            "trailer" ->
              message =
                "#{user.username} has pickup container #{container.name} for #{job.job_no}"

              route = Repo.get(ContainerRoute, params["route_id"])

              type =
                if route != nil do
                  loc = Repo.get_by(DeliveryLocation, name: route.to)

                  if loc.zone == "Home" do
                    "in_lorrydriver_start"
                  else
                    "out_lorrydriver_start"
                  end
                else
                  "error no route found..."
                end

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
                    activity_type: type
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

        job =
          if user.user_level == "LorryDriver" do
            Repo.get_by(Job, job_no: String.split(params["job_no"], "_") |> hd())
          else
            Repo.get_by(Job, job_no: params["job_no"])
          end

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

        route =
          if user.user_level == "LorryDriver" do
            Repo.get_by(ContainerRoute, id: String.split(params["job_no"], "_") |> List.last())
          else
            nil
          end

        if route != nil do
          Logistic.update_container_route(route, %{driver_id: user.id, driver: user.username})

          res =
            Repo.all(
              from(
                u in UserJob,
                where: u.user_id == ^user.id and u.job_id == ^job.id and u.route_id == ^route.id
              )
            )

          usj = List.first(res)
          Logistic.update_user_job(usj, %{status: "pending report", route_id: route.id})
        else
          res = Repo.all(from(u in UserJob, where: u.user_id == ^user.id and u.job_id == ^job.id))
          usj = List.first(res)
          Logistic.update_user_job(usj, %{status: "pending report"})
        end

        # if some one cant finish the job... we dont have a handling for this situation yet.
        # its expected the users finish the job when they acknowledge it.
    end

    conn
    |> put_resp_content_type("application/json")
    |> send_resp(200, Poison.encode!(%{status: "received"}))
  end
end
