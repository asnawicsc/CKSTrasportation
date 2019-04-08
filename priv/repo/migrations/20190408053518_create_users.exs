defmodule Transporter.Repo.Migrations.CreateUsers do
  use Ecto.Migration

  def change do
    create table(:users) do
      add :username, :string
      add :password, :string
      add :email, :string
      add :user_type, :string
      add :user_level, :string
      add :pin, :string
      add :crypted_password, :string

      timestamps()
    end

  end
end
