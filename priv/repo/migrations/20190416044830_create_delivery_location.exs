defmodule Transporter.Repo.Migrations.CreateDeliveryLocation do
  use Ecto.Migration

  def change do
    create table(:delivery_location) do
      add :name, :string
      add :zone, :string

      timestamps()
    end

  end
end
