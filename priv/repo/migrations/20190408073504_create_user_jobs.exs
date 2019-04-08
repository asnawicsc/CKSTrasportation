defmodule Transporter.Repo.Migrations.CreateUserJobs do
  use Ecto.Migration

  def change do
    create table(:user_jobs) do
      add :user_id, :integer
      add :job_id, :integer
      add :status, :string

      timestamps()
    end

  end
end
