defmodule Transporter.Logistic.Job do
  use Ecto.Schema
  import Ecto.Changeset

  schema "jobs" do
    field(:created_by, :string)
    field(:description, :string)
    field(:duration, :integer)
    field(:job_no, :string)
    field(:last_activity, :string)
    field(:last_by, :string)
    field(:containers, :binary)
    field(:vessel_name, :string)
    field(:voyage_no, :string)
    field(:shipping_liner, :binary)
    field(:eta, :naive_datetime)
    field(:ata, :naive_datetime)
    field(:atb, :naive_datetime)
    field(:declared_by, :string)
    field(:shipper, :string)
    field(:customer, :string)
    field(:contact_no, :string)
    field(:dd_date, :naive_datetime)
    field(:from, :string)
    field(:delivery_mode, :string)
    field(:delivery_type, :string)
    field(:to, :string)
    timestamps()
  end

  @doc false
  def changeset(job, attrs) do
    job
    |> cast(attrs, [
      :containers,
      :job_no,
      :description,
      :created_by,
      :last_activity,
      :last_by,
      :duration,
      :vessel_name,
      :voyage_no,
      :shipping_liner,
      :eta,
      :ata,
      :atb,
      :declared_by,
      :shipper,
      :customer,
      :contact_no,
      :dd_date,
      :from,
      :delivery_mode,
      :delivery_type,
      :to
    ])
    |> validate_required([:job_no, :created_by])
  end
end
