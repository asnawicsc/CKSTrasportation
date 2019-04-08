defmodule Transporter.Logistic.Activity do
  use Ecto.Schema
  import Ecto.Changeset

  schema "activities" do
    field(:created_by, :string)
    field(:created_id, :integer)
    field(:fee, :decimal)
    field(:job_id, :integer)
    field(:location, :string)
    field(:message, :binary)

    timestamps()
  end

  @doc false
  def changeset(activity, attrs) do
    activity
    |> cast(attrs, [:job_id, :created_by, :created_id, :message, :location, :fee])
    |> validate_required([:job_id, :created_by, :created_id, :message])
  end
end
