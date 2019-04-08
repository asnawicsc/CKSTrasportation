defmodule Transporter.Repo.Migrations.CreateImages do
  use Ecto.Migration

  def change do
    create table(:images) do
      add :filename, :string
      add :activity_id, :integer
      add :thumbnail, :binary

      timestamps()
    end

  end
end
