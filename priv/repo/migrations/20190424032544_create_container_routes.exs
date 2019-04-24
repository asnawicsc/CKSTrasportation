defmodule Transporter.Repo.Migrations.CreateContainerRoutes do
  use Ecto.Migration

  def change do
    create table(:container_routes) do
      add :job_id, :integer
      add :container_id, :integer
      add :from_id, :integer
      add :to_id, :integer
      add :driver_id, :integer
      add :from, :string
      add :to, :string
      add :driver, :string
      add :lorry, :string

      timestamps()
    end

  end
end
