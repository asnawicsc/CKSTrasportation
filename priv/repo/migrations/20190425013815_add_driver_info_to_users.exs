defmodule Transporter.Repo.Migrations.AddDriverInfoToUsers do
  use Ecto.Migration

  def change do
    alter table("users") do
      add(:insurance_exp, :date)
      add(:inspection, :date)
      add(:road_tax_exp, :date)
      add(:truck_type, :string)
      add(:truck_no, :string)
    end
  end
end
