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
    field(:container_id, :integer)
    field(:container_name, :string)
    field(:delivery_mode, :string)
    field(:delivery_type, :string)
    field(:trailer_no, :string)
    field(:activity_type, :string)
    timestamps()
  end

  @doc false
  def changeset(activity, attrs) do
    activity
    |> cast(attrs, [
      :activity_type,
      :trailer_no,
      :delivery_type,
      :delivery_mode,
      :container_id,
      :container_name,
      :job_id,
      :created_by,
      :created_id,
      :message,
      :location,
      :fee
    ])
    |> validate_required([:activity_type, :job_id, :created_by, :created_id, :message])
  end
end
