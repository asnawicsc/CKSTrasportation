defmodule Transporter.Logistic.Job do
  use Ecto.Schema
  import Ecto.Changeset

  schema "jobs" do
    field(:created_by, :string)
    field(:description, :string)
    field(:duration, :integer)
    field(:job_no, :string)
    field(:last_activity, :string)
    field(:last_by, :string)

    timestamps()
  end

  @doc false
  def changeset(job, attrs) do
    job
    |> cast(attrs, [:job_no, :description, :created_by, :last_activity, :last_by, :duration])
    |> validate_required([:job_no, :description, :created_by])
  end
end
