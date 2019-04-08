defmodule Transporter.Repo.Migrations.CreateJobs do
  use Ecto.Migration

  def change do
    create table(:jobs) do
      add :job_no, :string
      add :description, :string
      add :created_by, :string
      add :last_activity, :string
      add :last_by, :string
      add :duration, :integer

      timestamps()
    end

  end
end
