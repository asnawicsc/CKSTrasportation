defmodule Transporter.Repo.Migrations.AddListContainersToJob do
  use Ecto.Migration

  def change do
    alter table(:jobs) do
      add(:containers, :binary)
    end
  end
end
