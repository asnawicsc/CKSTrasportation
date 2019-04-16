defmodule Transporter.Repo.Migrations.CreateCompanies do
  use Ecto.Migration

  def change do
    create table(:companies) do
      add :name, :string
      add :address, :string
      add :gst, :string
      add :phone, :string
      add :mobile, :string
      add :fax, :string
      add :contact, :string
      add :person, :string

      timestamps()
    end

  end
end
