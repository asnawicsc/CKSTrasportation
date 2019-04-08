defmodule Transporter.Repo.Migrations.CreateActivities do
  use Ecto.Migration

  def change do
    create table(:activities) do
      add :job_id, :integer
      add :created_by, :string
      add :created_id, :integer
      add :message, :binary
      add :location, :string
      add :fee, :decimal

      timestamps()
    end

  end
end
