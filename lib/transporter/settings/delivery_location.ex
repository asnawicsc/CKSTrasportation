defmodule Transporter.Settings.DeliveryLocation do
  use Ecto.Schema
  import Ecto.Changeset

  schema "delivery_location" do
    field(:name, :string)
    field(:zone, :string)

    timestamps()
  end

  @doc false
  def changeset(delivery_location, attrs) do
    delivery_location
    |> cast(attrs, [:name, :zone])
    |> validate_required([:name])
  end
end
