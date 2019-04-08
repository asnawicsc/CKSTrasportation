defmodule Transporter.Logistic.Image do
  use Ecto.Schema
  import Ecto.Changeset


  schema "images" do
    field :activity_id, :integer
    field :filename, :string
    field :thumbnail, :binary

    timestamps()
  end

  @doc false
  def changeset(image, attrs) do
    image
    |> cast(attrs, [:filename, :activity_id, :thumbnail])
    |> validate_required([:filename, :activity_id, :thumbnail])
  end
end
