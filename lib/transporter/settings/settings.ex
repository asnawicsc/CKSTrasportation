defmodule Transporter.Settings do
  @moduledoc """
  The Settings context.
  """

  import Ecto.Query, warn: false
  alias Transporter.Repo

  alias Transporter.Settings.User

  @doc """
  Returns the list of users.

  ## Examples

      iex> list_users()
      [%User{}, ...]

  """

  def list_users do
    Repo.all(User)
  end

  def list_users(level) do
    Repo.all(from(u in User, where: u.user_level == ^level))
  end

  @doc """
  Gets a single user.

  Raises `Ecto.NoResultsError` if the User does not exist.

  ## Examples

      iex> get_user!(123)
      %User{}

      iex> get_user!(456)
      ** (Ecto.NoResultsError)

  """
  def get_user!(id), do: Repo.get!(User, id)

  @doc """
  Creates a user.

  ## Examples

      iex> create_user(%{field: value})
      {:ok, %User{}}

      iex> create_user(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_user(attrs \\ %{}) do
    %User{}
    |> User.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a user.

  ## Examples

      iex> update_user(user, %{field: new_value})
      {:ok, %User{}}

      iex> update_user(user, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_user(%User{} = user, attrs) do
    user
    |> User.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a User.

  ## Examples

      iex> delete_user(user)
      {:ok, %User{}}

      iex> delete_user(user)
      {:error, %Ecto.Changeset{}}

  """
  def delete_user(%User{} = user) do
    Repo.delete(user)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking user changes.

  ## Examples

      iex> change_user(user)
      %Ecto.Changeset{source: %User{}}

  """
  def change_user(%User{} = user) do
    User.changeset(user, %{})
  end

  alias Transporter.Settings.Company

  @doc """
  Returns the list of companies.

  ## Examples

      iex> list_companies()
      [%Company{}, ...]

  """
  def list_companies do
    Repo.all(Company)
  end

  @doc """
  Gets a single company.

  Raises `Ecto.NoResultsError` if the Company does not exist.

  ## Examples

      iex> get_company!(123)
      %Company{}

      iex> get_company!(456)
      ** (Ecto.NoResultsError)

  """
  def get_company!(id), do: Repo.get!(Company, id)

  @doc """
  Creates a company.

  ## Examples

      iex> create_company(%{field: value})
      {:ok, %Company{}}

      iex> create_company(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_company(attrs \\ %{}) do
    %Company{}
    |> Company.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a company.

  ## Examples

      iex> update_company(company, %{field: new_value})
      {:ok, %Company{}}

      iex> update_company(company, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_company(%Company{} = company, attrs) do
    company
    |> Company.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a Company.

  ## Examples

      iex> delete_company(company)
      {:ok, %Company{}}

      iex> delete_company(company)
      {:error, %Ecto.Changeset{}}

  """
  def delete_company(%Company{} = company) do
    Repo.delete(company)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking company changes.

  ## Examples

      iex> change_company(company)
      %Ecto.Changeset{source: %Company{}}

  """
  def change_company(%Company{} = company) do
    Company.changeset(company, %{})
  end

  alias Transporter.Settings.DeliveryLocation

  @doc """
  Returns the list of delivery_location.

  ## Examples

      iex> list_delivery_location()
      [%DeliveryLocation{}, ...]

  """
  def list_delivery_location do
    Repo.all(DeliveryLocation)
  end

  @doc """
  Gets a single delivery_location.

  Raises `Ecto.NoResultsError` if the Delivery location does not exist.

  ## Examples

      iex> get_delivery_location!(123)
      %DeliveryLocation{}

      iex> get_delivery_location!(456)
      ** (Ecto.NoResultsError)

  """
  def get_delivery_location!(id), do: Repo.get!(DeliveryLocation, id)

  @doc """
  Creates a delivery_location.

  ## Examples

      iex> create_delivery_location(%{field: value})
      {:ok, %DeliveryLocation{}}

      iex> create_delivery_location(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_delivery_location(attrs \\ %{}) do
    %DeliveryLocation{}
    |> DeliveryLocation.changeset(attrs)
    |> Repo.insert()
  end

  def bulk_create() do
    a = "Twu < 10KM or Batu 6
      Twu < 10KM < 16KM Batu 10
      Twu < Airport, Apas Parit, Wakuba
      Twu < Balung
      Twu < QL 1, TSH 1, Taiko M1
      Kunak 1
      Kunak 2
      Semporna 1
      Semporna 2
      Lahad Datu, POIC
      Lahad Datu, Zenova
      Sahabat, Cenderawasih
      Jeroco
      Dumpas
      Rajang
      Umas
      Kapilit
      Kalabakan
      Keningau
      Ranau
      KKIP, Telipok
      Tuaran
      Menggatal
      Inanam
      Kolombong
      Likas
      Kepayan, Petagas
      Bundusan, Penampang Baru
      IB
      KK Bandar, Sembulan 
      Kota Belub
      Kota Marudu
      Kudat
      Lokkawi
      Kinarut
      Papar, Beaufort, Kuala Penyu
      Sipitang
      Sandakan
      "

    res =
      String.split(a, "\n") |> Enum.map(fn x -> String.trim(x) end)
      |> Enum.reject(fn x -> x == "" end)

    b =
      for re <- res do
        create_delivery_location(%{name: re})
      end

    b
  end

  @doc """
  Updates a delivery_location.

  ## Examples

      iex> update_delivery_location(delivery_location, %{field: new_value})
      {:ok, %DeliveryLocation{}}

      iex> update_delivery_location(delivery_location, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_delivery_location(%DeliveryLocation{} = delivery_location, attrs) do
    delivery_location
    |> DeliveryLocation.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a DeliveryLocation.

  ## Examples

      iex> delete_delivery_location(delivery_location)
      {:ok, %DeliveryLocation{}}

      iex> delete_delivery_location(delivery_location)
      {:error, %Ecto.Changeset{}}

  """
  def delete_delivery_location(%DeliveryLocation{} = delivery_location) do
    Repo.delete(delivery_location)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking delivery_location changes.

  ## Examples

      iex> change_delivery_location(delivery_location)
      %Ecto.Changeset{source: %DeliveryLocation{}}

  """
  def change_delivery_location(%DeliveryLocation{} = delivery_location) do
    DeliveryLocation.changeset(delivery_location, %{})
  end

  def create_users(user_params \\ nil) do
    user_params =
      if user_params == nil do
        user_params = %{
          username: "cks_admin",
          email: "admin@1.com",
          user_type: "Staff",
          user_level: "Admin",
          pin: "1234",
          password: "1234"
        }
      else
        user_params
      end

    user_params =
      Map.put(
        user_params,
        :crypted_password,
        Comeonin.Bcrypt.hashpwsalt(user_params.password)
      )
      |> Map.put(:password, nil)

    create_user(user_params)
  end
end
