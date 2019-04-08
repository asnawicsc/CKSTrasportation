defmodule Transporter.Settings.User do
  use Ecto.Schema
  import Ecto.Changeset

  schema "users" do
    field(:crypted_password, :string)
    field(:email, :string)
    field(:password, :string)
    field(:pin, :string)
    field(:user_level, :string)
    field(:user_type, :string)
    field(:username, :string)

    timestamps()
  end

  @doc false
  def changeset(user, attrs) do
    user
    |> cast(attrs, [
      :username,
      :password,
      :email,
      :user_type,
      :user_level,
      :pin,
      :crypted_password
    ])
    |> validate_required([:username, :email, :user_type, :user_level, :pin, :crypted_password])
  end
end
