defmodule Transporter.Repo.Migrations.AddReturnDepotToContainers do
  use Ecto.Migration

  def change do
    alter table("containers") do
      add(:return_depot, :string)
    end
  end
end
