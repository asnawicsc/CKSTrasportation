defmodule Transporter.Repo.Migrations.AddDeliveryModeTypeToActivity do
  use Ecto.Migration

  def change do
    alter table("activities") do
      add(:delivery_mode, :string)
      add(:delivery_type, :string)
      add(:trailer_no, :string)
    end
  end
end
