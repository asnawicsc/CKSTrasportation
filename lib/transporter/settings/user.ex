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
    field(:company_id, :integer)
    field(:locations, :binary)
    field(:rates, :binary)
    field(:ic_no, :string)
    field(:license_expiry, :date)
    field(:phone1, :string)
    field(:phone2, :string)
    field(:alias, :string)
    timestamps()
  end

  @doc false
  def changeset(user, attrs) do
    user
    |> cast(attrs, [
      :alias,
      :phone1,
      :phone2,
      :ic_no,
      :license_expiry,
      :username,
      :password,
      :email,
      :user_type,
      :user_level,
      :pin,
      :crypted_password,
      :company_id,
      :locations,
      :rates
    ])
    |> validate_required([
      :username,
      :email,
      :user_type,
      :user_level,
      :pin,
      :crypted_password
    ])
  end
end
