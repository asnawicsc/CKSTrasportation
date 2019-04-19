defmodule Transporter.Repo.Migrations.AddActivityTypeToActivity do
  use Ecto.Migration

  def change do
    alter table("activities") do
      add(:activity_type, :string)
    end
  end
end
