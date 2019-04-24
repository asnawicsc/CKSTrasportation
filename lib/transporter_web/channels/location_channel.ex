defmodule TransporterWeb.LocationChannel do
  use TransporterWeb, :channel

  alias Transporter.Settings
  alias Transporter.Settings.User
  alias Transporter.Logistic
  alias Transporter.Logistic.{Activity, Job, UserJob, Image, Container}

  def join("location:" <> user_id, payload, socket) do
    if authorized?(payload, user_id) do
      {:ok, socket}
    else
      {:error, %{reason: "unauthorized"}}
    end
  end

  # need a channel to keep the user report order \ user \ position

  def handle_in("report_job", payload, socket) do
    IO.inspect(payload)
    # code = String.split(socket.topic, ":") |> List.last()
    # restaurant = Repo.all(from(b in Restaurant, where: b.code == ^code)) |> List.first()
    # item_map = payload["void_item"]

    # {:ok, datetime} = DateTime.from_unix(item_map["void_datetime"], :millisecond)

    # {:ok, v} =
    #   Reports.create_void_item(%{
    #     item_name: item_map["item_name"],
    #     void_by: item_map["void_by"],
    #     order_id: item_map["order_id"],
    #     table_name: item_map["table_name"],
    #     rest_id: restaurant.id,
    #     void_datetime: datetime,
    #     reason: item_map["reason"]
    #   })

    # IO.inspect(v)

    {:noreply, socket}
  end

  def handle_in("outStanding", payload, socket) do
    IO.inspect(payload)

    username = payload["user"]

    user = Repo.get_by(User, username: username)

    if user != nil do
      job_ids =
        Repo.all(
          from(
            u in UserJob,
            where: u.user_id == ^user.id and u.status == ^"pending accept",
            select: u.job_id
          )
        )

      jobs = Repo.all(from(j in Job, where: j.id in ^job_ids))
      IO.inspect(jobs)

      for j <- jobs do
        # find out the pending containers
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

        message = %{
          job_no: j.job_no,
          description: j.description,
          insertedAt:
            DateTime.from_naive!(j.inserted_at, "Etc/UTC") |> DateTime.to_unix(:millisecond),
          pendingContainers: pending_containers,
          completedContainers: "",
          by: j.last_by
        }

        IO.inspect(message)
        broadcast(socket, "new_request", message)
      end

      job_ids2 =
        Repo.all(
          from(
            u in UserJob,
            where: u.user_id == ^user.id and u.status == ^"pending report",
            select: u.job_id
          )
        )

      jobs2 = Repo.all(from(j in Job, where: j.id in ^job_ids2))
      # find out the pending containers
      IO.inspect(jobs2)

      for j <- jobs2 do
        names = j.containers |> String.split(",")
        containers = Repo.all(from(c in Container, where: c.name in ^names))

        pending_containers =
          case user.user_level do
            "LorryDriver" ->
              containers |> Enum.filter(fn x -> x.status == "Pending Transport" end)
              |> Enum.filter(fn x -> x.driver_id == user.id end)

            "Gateman" ->
              containers |> Enum.filter(fn x -> x.status == "Pending Checking" end)

            _ ->
              containers
          end

        IO.inspect(pending_containers)

        pending_containers =
          pending_containers
          |> Enum.map(fn x -> x.name end)
          |> Enum.join(",")

        completed_containers =
          case user.user_level do
            "LorryDriver" ->
              containers |> Enum.filter(fn x -> x.status == "Arrived Destination" end)
              |> Enum.filter(fn x -> x.driver_id == user.id end)

            "Gateman" ->
              containers |> Enum.filter(fn x -> x.status == "Pending Transport" end)

            _ ->
              containers
          end
          |> Enum.map(fn x -> x.name end)
          |> Enum.join(",")

        pickedContainers =
          if user.user_level == "LorryDriver" do
            containers |> Enum.filter(fn x -> x.status == "Pickup Container" end)
          else
            containers
          end
          |> Enum.map(fn x -> x.name end)
          |> Enum.join(",")

        message = %{
          job_no: j.job_no,
          description: j.description,
          insertedAt:
            DateTime.from_naive!(j.inserted_at, "Etc/UTC") |> DateTime.to_unix(:millisecond),
          pendingContainers: pending_containers,
          completedContainers: completed_containers,
          pickedContainers: pickedContainers
        }

        IO.inspect(message)

        broadcast(socket, "accepted_request", message)
      end

      job_ids3 =
        Repo.all(
          from(
            u in UserJob,
            where: u.user_id == ^user.id and u.status == ^"done",
            select: u.job_id
          )
        )

      jobs3 = Repo.all(from(j in Job, where: j.id in ^job_ids3))
      # find out the pending containers
      IO.inspect(jobs3)

      for j <- jobs3 do
        # find out the pending containers
        names = j.containers |> String.split(",")
        containers = Repo.all(from(c in Container, where: c.name in ^names))

        message = %{
          job_no: j.job_no,
          description: j.description,
          insertedAt:
            DateTime.from_naive!(j.updated_at, "Etc/UTC") |> DateTime.to_unix(:millisecond),
          pendingContainers: j.containers,
          completedContainers: ""
        }

        IO.inspect(message)
        broadcast(socket, "completed_request", message)
      end
    end

    # code = String.split(socket.topic, ":") |> List.last()
    # restaurant = Repo.all(from(b in Restaurant, where: b.code == ^code)) |> List.first()
    # item_map = payload["void_item"]

    # {:ok, datetime} = DateTime.from_unix(item_map["void_datetime"], :millisecond)

    # {:ok, v} =
    #   Reports.create_void_item(%{
    #     item_name: item_map["item_name"],
    #     void_by: item_map["void_by"],
    #     order_id: item_map["order_id"],
    #     table_name: item_map["table_name"],
    #     rest_id: restaurant.id,
    #     void_datetime: datetime,
    #     reason: item_map["reason"]
    #   })

    # IO.inspect(v)

    {:noreply, socket}
  end

  # Add authorization logic here as required.
  defp authorized?(payload, user_id) do
    IO.inspect(payload)
    true
  end
end
