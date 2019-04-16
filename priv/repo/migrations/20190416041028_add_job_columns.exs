defmodule Transporter.Repo.Migrations.AddJobColumns do
  use Ecto.Migration

  def change do
    alter table("jobs") do
      add(:vessel_name, :string)
      add(:voyage_no, :string)
      add(:shipping_liner, :binary)
      add(:eta, :naive_datetime)
      add(:ata, :naive_datetime)
      add(:atb, :naive_datetime)
      add(:declared_by, :string)
      add(:shipper, :string)
      add(:customer, :string)
      add(:contact_no, :string)
      add(:dd_date, :naive_datetime)
      add(:from, :string)
      add(:delivery_mode, :string)
      add(:delivery_type, :string)
      add(:to, :string)
    end
  end
end
