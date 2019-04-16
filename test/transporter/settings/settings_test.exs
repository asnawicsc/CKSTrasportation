defmodule Transporter.SettingsTest do
  use Transporter.DataCase

  alias Transporter.Settings

  describe "users" do
    alias Transporter.Settings.User

    @valid_attrs %{crypted_password: "some crypted_password", email: "some email", password: "some password", pin: "some pin", user_level: "some user_level", user_type: "some user_type", username: "some username"}
    @update_attrs %{crypted_password: "some updated crypted_password", email: "some updated email", password: "some updated password", pin: "some updated pin", user_level: "some updated user_level", user_type: "some updated user_type", username: "some updated username"}
    @invalid_attrs %{crypted_password: nil, email: nil, password: nil, pin: nil, user_level: nil, user_type: nil, username: nil}

    def user_fixture(attrs \\ %{}) do
      {:ok, user} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Settings.create_user()

      user
    end

    test "list_users/0 returns all users" do
      user = user_fixture()
      assert Settings.list_users() == [user]
    end

    test "get_user!/1 returns the user with given id" do
      user = user_fixture()
      assert Settings.get_user!(user.id) == user
    end

    test "create_user/1 with valid data creates a user" do
      assert {:ok, %User{} = user} = Settings.create_user(@valid_attrs)
      assert user.crypted_password == "some crypted_password"
      assert user.email == "some email"
      assert user.password == "some password"
      assert user.pin == "some pin"
      assert user.user_level == "some user_level"
      assert user.user_type == "some user_type"
      assert user.username == "some username"
    end

    test "create_user/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Settings.create_user(@invalid_attrs)
    end

    test "update_user/2 with valid data updates the user" do
      user = user_fixture()
      assert {:ok, user} = Settings.update_user(user, @update_attrs)
      assert %User{} = user
      assert user.crypted_password == "some updated crypted_password"
      assert user.email == "some updated email"
      assert user.password == "some updated password"
      assert user.pin == "some updated pin"
      assert user.user_level == "some updated user_level"
      assert user.user_type == "some updated user_type"
      assert user.username == "some updated username"
    end

    test "update_user/2 with invalid data returns error changeset" do
      user = user_fixture()
      assert {:error, %Ecto.Changeset{}} = Settings.update_user(user, @invalid_attrs)
      assert user == Settings.get_user!(user.id)
    end

    test "delete_user/1 deletes the user" do
      user = user_fixture()
      assert {:ok, %User{}} = Settings.delete_user(user)
      assert_raise Ecto.NoResultsError, fn -> Settings.get_user!(user.id) end
    end

    test "change_user/1 returns a user changeset" do
      user = user_fixture()
      assert %Ecto.Changeset{} = Settings.change_user(user)
    end
  end

  describe "companies" do
    alias Transporter.Settings.Company

    @valid_attrs %{address: "some address", contact: "some contact", fax: "some fax", gst: "some gst", mobile: "some mobile", name: "some name", person: "some person", phone: "some phone"}
    @update_attrs %{address: "some updated address", contact: "some updated contact", fax: "some updated fax", gst: "some updated gst", mobile: "some updated mobile", name: "some updated name", person: "some updated person", phone: "some updated phone"}
    @invalid_attrs %{address: nil, contact: nil, fax: nil, gst: nil, mobile: nil, name: nil, person: nil, phone: nil}

    def company_fixture(attrs \\ %{}) do
      {:ok, company} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Settings.create_company()

      company
    end

    test "list_companies/0 returns all companies" do
      company = company_fixture()
      assert Settings.list_companies() == [company]
    end

    test "get_company!/1 returns the company with given id" do
      company = company_fixture()
      assert Settings.get_company!(company.id) == company
    end

    test "create_company/1 with valid data creates a company" do
      assert {:ok, %Company{} = company} = Settings.create_company(@valid_attrs)
      assert company.address == "some address"
      assert company.contact == "some contact"
      assert company.fax == "some fax"
      assert company.gst == "some gst"
      assert company.mobile == "some mobile"
      assert company.name == "some name"
      assert company.person == "some person"
      assert company.phone == "some phone"
    end

    test "create_company/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Settings.create_company(@invalid_attrs)
    end

    test "update_company/2 with valid data updates the company" do
      company = company_fixture()
      assert {:ok, company} = Settings.update_company(company, @update_attrs)
      assert %Company{} = company
      assert company.address == "some updated address"
      assert company.contact == "some updated contact"
      assert company.fax == "some updated fax"
      assert company.gst == "some updated gst"
      assert company.mobile == "some updated mobile"
      assert company.name == "some updated name"
      assert company.person == "some updated person"
      assert company.phone == "some updated phone"
    end

    test "update_company/2 with invalid data returns error changeset" do
      company = company_fixture()
      assert {:error, %Ecto.Changeset{}} = Settings.update_company(company, @invalid_attrs)
      assert company == Settings.get_company!(company.id)
    end

    test "delete_company/1 deletes the company" do
      company = company_fixture()
      assert {:ok, %Company{}} = Settings.delete_company(company)
      assert_raise Ecto.NoResultsError, fn -> Settings.get_company!(company.id) end
    end

    test "change_company/1 returns a company changeset" do
      company = company_fixture()
      assert %Ecto.Changeset{} = Settings.change_company(company)
    end
  end

  describe "delivery_location" do
    alias Transporter.Settings.DeliveryLocation

    @valid_attrs %{name: "some name", zone: "some zone"}
    @update_attrs %{name: "some updated name", zone: "some updated zone"}
    @invalid_attrs %{name: nil, zone: nil}

    def delivery_location_fixture(attrs \\ %{}) do
      {:ok, delivery_location} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Settings.create_delivery_location()

      delivery_location
    end

    test "list_delivery_location/0 returns all delivery_location" do
      delivery_location = delivery_location_fixture()
      assert Settings.list_delivery_location() == [delivery_location]
    end

    test "get_delivery_location!/1 returns the delivery_location with given id" do
      delivery_location = delivery_location_fixture()
      assert Settings.get_delivery_location!(delivery_location.id) == delivery_location
    end

    test "create_delivery_location/1 with valid data creates a delivery_location" do
      assert {:ok, %DeliveryLocation{} = delivery_location} = Settings.create_delivery_location(@valid_attrs)
      assert delivery_location.name == "some name"
      assert delivery_location.zone == "some zone"
    end

    test "create_delivery_location/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Settings.create_delivery_location(@invalid_attrs)
    end

    test "update_delivery_location/2 with valid data updates the delivery_location" do
      delivery_location = delivery_location_fixture()
      assert {:ok, delivery_location} = Settings.update_delivery_location(delivery_location, @update_attrs)
      assert %DeliveryLocation{} = delivery_location
      assert delivery_location.name == "some updated name"
      assert delivery_location.zone == "some updated zone"
    end

    test "update_delivery_location/2 with invalid data returns error changeset" do
      delivery_location = delivery_location_fixture()
      assert {:error, %Ecto.Changeset{}} = Settings.update_delivery_location(delivery_location, @invalid_attrs)
      assert delivery_location == Settings.get_delivery_location!(delivery_location.id)
    end

    test "delete_delivery_location/1 deletes the delivery_location" do
      delivery_location = delivery_location_fixture()
      assert {:ok, %DeliveryLocation{}} = Settings.delete_delivery_location(delivery_location)
      assert_raise Ecto.NoResultsError, fn -> Settings.get_delivery_location!(delivery_location.id) end
    end

    test "change_delivery_location/1 returns a delivery_location changeset" do
      delivery_location = delivery_location_fixture()
      assert %Ecto.Changeset{} = Settings.change_delivery_location(delivery_location)
    end
  end
end
