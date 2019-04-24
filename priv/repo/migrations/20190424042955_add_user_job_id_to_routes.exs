defmodule Transporter.Repo.Migrations.AddUserJobIdToRoutes do
  use Ecto.Migration

  def change do
    alter table("user_jobs") do
      add(:route_id, :integer)
    end
  end
end
