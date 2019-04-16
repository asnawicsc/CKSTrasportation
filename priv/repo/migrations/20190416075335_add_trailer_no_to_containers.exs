defmodule Transporter.Repo.Migrations.AddTrailerNoToContainers do
  use Ecto.Migration

  def change do
    alter table("containers") do
      add(:trailer_no, :string)
    end
  end
end
