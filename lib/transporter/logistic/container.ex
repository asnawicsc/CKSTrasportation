defmodule Transporter.Logistic.Container do
  use Ecto.Schema
  import Ecto.Changeset

  schema "containers" do
    field(:job_id, :integer)
    field(:job_no, :string)
    field(:name, :string)
    field(:status, :string, default: "Pending Clearance")
    field(:trailer_no, :string)
    field(:return_depot, :string)
    field(:driver_name, :string)
    field(:driver_id, :integer)
    timestamps()
  end

  @doc false
  def changeset(container, attrs) do
    container
    |> cast(attrs, [
      :driver_name,
      :driver_id,
      :return_depot,
      :trailer_no,
      :job_no,
      :job_id,
      :name,
      :status
    ])
    |> validate_required([:job_no, :job_id, :name, :status])
  end
end
