defmodule Transporter.Logistic.UserJob do
  use Ecto.Schema
  import Ecto.Changeset

  schema "user_jobs" do
    field(:job_id, :integer)
    field(:status, :string, default: "pending")
    field(:user_id, :integer)

    timestamps()
  end

  @doc false
  def changeset(user_job, attrs) do
    user_job
    |> cast(attrs, [:user_id, :job_id, :status])
    |> validate_required([:user_id, :job_id, :status])
  end
end
