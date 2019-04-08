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
end
