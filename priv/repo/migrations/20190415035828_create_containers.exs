defmodule Transporter.Repo.Migrations.CreateContainers do
  use Ecto.Migration

  def change do
    create table(:containers) do
      add :job_no, :string
      add :job_id, :integer
      add :name, :string
      add :status, :string

      timestamps()
    end

  end
end
