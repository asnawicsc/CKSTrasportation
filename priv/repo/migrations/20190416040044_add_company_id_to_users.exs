defmodule Transporter.Repo.Migrations.AddCompanyIdToUsers do
  use Ecto.Migration

  def change do
    alter table("users") do
      add(:company_id, :integer)
      add(:ic_no, :string)
      add(:license_expiry, :date)
      add(:locations, :binary)
      add(:rates, :binary)
      add(:phone1, :string)
      add(:phone2, :string)
      add(:alias, :string)
    end
  end
end
