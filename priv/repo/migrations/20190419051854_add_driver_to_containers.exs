defmodule Transporter.Repo.Migrations.AddDriverToContainers do
  use Ecto.Migration

  def change do
    alter table("containers") do
      add(:driver_name, :string)
      add(:driver_id, :integer)
    end
  end
end
