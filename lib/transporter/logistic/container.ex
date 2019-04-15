defmodule Transporter.Logistic.Container do
  use Ecto.Schema
  import Ecto.Changeset

  schema "containers" do
    field(:job_id, :integer)
    field(:job_no, :string)
    field(:name, :string)
    field(:status, :string, default: "Pending Clearance")

    timestamps()
  end

  @doc false
  def changeset(container, attrs) do
    container
    |> cast(attrs, [:job_no, :job_id, :name, :status])
    |> validate_required([:job_no, :job_id, :name, :status])
  end
end
