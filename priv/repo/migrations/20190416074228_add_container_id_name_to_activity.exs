defmodule Transporter.Repo.Migrations.AddContainerIdNameToActivity do
  use Ecto.Migration

  def change do
    alter table("activities") do
      add(:container_id, :integer)
      add(:container_name, :string)
    end
  end
end
