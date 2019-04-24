defmodule Transporter.Logistic.ContainerRoute do
  use Ecto.Schema
  import Ecto.Changeset

  schema "container_routes" do
    field(:container_id, :integer)
    field(:driver, :string)
    field(:driver_id, :integer)
    field(:from, :string)
    field(:from_id, :integer)
    field(:job_id, :integer)
    field(:lorry, :string)
    field(:to, :string)
    field(:to_id, :integer)

    timestamps()
  end

  @doc false
  def changeset(container_route, attrs) do
    container_route
    |> cast(attrs, [
      :job_id,
      :container_id,
      :from_id,
      :to_id,
      :driver_id,
      :from,
      :to,
      :driver,
      :lorry
    ])
    |> validate_required([:job_id, :container_id, :from_id, :to_id, :from, :to])
  end
end
