defmodule Transporter.Settings.Company do
  use Ecto.Schema
  import Ecto.Changeset


  schema "companies" do
    field :address, :string
    field :contact, :string
    field :fax, :string
    field :gst, :string
    field :mobile, :string
    field :name, :string
    field :person, :string
    field :phone, :string

    timestamps()
  end

  @doc false
  def changeset(company, attrs) do
    company
    |> cast(attrs, [:name, :address, :gst, :phone, :mobile, :fax, :contact, :person])
    |> validate_required([:name, :address, :gst, :phone, :mobile, :fax, :contact, :person])
  end
end
