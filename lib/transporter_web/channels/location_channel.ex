defmodule TransporterWeb.LocationChannel do
  use TransporterWeb, :channel

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

  # Add authorization logic here as required.
  defp authorized?(payload, user_id) do
    IO.inspect(payload)
    true
  end
end
