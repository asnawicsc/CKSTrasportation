defmodule Transporter.LogisticTest do
  use Transporter.DataCase

  alias Transporter.Logistic

  describe "jobs" do
    alias Transporter.Logistic.Job

    @valid_attrs %{created_by: "some created_by", description: "some description", duration: 42, job_no: "some job_no", last_activity: "some last_activity", last_by: "some last_by"}
    @update_attrs %{created_by: "some updated created_by", description: "some updated description", duration: 43, job_no: "some updated job_no", last_activity: "some updated last_activity", last_by: "some updated last_by"}
    @invalid_attrs %{created_by: nil, description: nil, duration: nil, job_no: nil, last_activity: nil, last_by: nil}

    def job_fixture(attrs \\ %{}) do
      {:ok, job} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Logistic.create_job()

      job
    end

    test "list_jobs/0 returns all jobs" do
      job = job_fixture()
      assert Logistic.list_jobs() == [job]
    end

    test "get_job!/1 returns the job with given id" do
      job = job_fixture()
      assert Logistic.get_job!(job.id) == job
    end

    test "create_job/1 with valid data creates a job" do
      assert {:ok, %Job{} = job} = Logistic.create_job(@valid_attrs)
      assert job.created_by == "some created_by"
      assert job.description == "some description"
      assert job.duration == 42
      assert job.job_no == "some job_no"
      assert job.last_activity == "some last_activity"
      assert job.last_by == "some last_by"
    end

    test "create_job/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Logistic.create_job(@invalid_attrs)
    end

    test "update_job/2 with valid data updates the job" do
      job = job_fixture()
      assert {:ok, job} = Logistic.update_job(job, @update_attrs)
      assert %Job{} = job
      assert job.created_by == "some updated created_by"
      assert job.description == "some updated description"
      assert job.duration == 43
      assert job.job_no == "some updated job_no"
      assert job.last_activity == "some updated last_activity"
      assert job.last_by == "some updated last_by"
    end

    test "update_job/2 with invalid data returns error changeset" do
      job = job_fixture()
      assert {:error, %Ecto.Changeset{}} = Logistic.update_job(job, @invalid_attrs)
      assert job == Logistic.get_job!(job.id)
    end

    test "delete_job/1 deletes the job" do
      job = job_fixture()
      assert {:ok, %Job{}} = Logistic.delete_job(job)
      assert_raise Ecto.NoResultsError, fn -> Logistic.get_job!(job.id) end
    end

    test "change_job/1 returns a job changeset" do
      job = job_fixture()
      assert %Ecto.Changeset{} = Logistic.change_job(job)
    end
  end

  describe "activities" do
    alias Transporter.Logistic.Activity

    @valid_attrs %{created_by: "some created_by", created_id: 42, fee: "120.5", job_id: 42, location: "some location", message: "some message"}
    @update_attrs %{created_by: "some updated created_by", created_id: 43, fee: "456.7", job_id: 43, location: "some updated location", message: "some updated message"}
    @invalid_attrs %{created_by: nil, created_id: nil, fee: nil, job_id: nil, location: nil, message: nil}

    def activity_fixture(attrs \\ %{}) do
      {:ok, activity} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Logistic.create_activity()

      activity
    end

    test "list_activities/0 returns all activities" do
      activity = activity_fixture()
      assert Logistic.list_activities() == [activity]
    end

    test "get_activity!/1 returns the activity with given id" do
      activity = activity_fixture()
      assert Logistic.get_activity!(activity.id) == activity
    end

    test "create_activity/1 with valid data creates a activity" do
      assert {:ok, %Activity{} = activity} = Logistic.create_activity(@valid_attrs)
      assert activity.created_by == "some created_by"
      assert activity.created_id == 42
      assert activity.fee == Decimal.new("120.5")
      assert activity.job_id == 42
      assert activity.location == "some location"
      assert activity.message == "some message"
    end

    test "create_activity/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Logistic.create_activity(@invalid_attrs)
    end

    test "update_activity/2 with valid data updates the activity" do
      activity = activity_fixture()
      assert {:ok, activity} = Logistic.update_activity(activity, @update_attrs)
      assert %Activity{} = activity
      assert activity.created_by == "some updated created_by"
      assert activity.created_id == 43
      assert activity.fee == Decimal.new("456.7")
      assert activity.job_id == 43
      assert activity.location == "some updated location"
      assert activity.message == "some updated message"
    end

    test "update_activity/2 with invalid data returns error changeset" do
      activity = activity_fixture()
      assert {:error, %Ecto.Changeset{}} = Logistic.update_activity(activity, @invalid_attrs)
      assert activity == Logistic.get_activity!(activity.id)
    end

    test "delete_activity/1 deletes the activity" do
      activity = activity_fixture()
      assert {:ok, %Activity{}} = Logistic.delete_activity(activity)
      assert_raise Ecto.NoResultsError, fn -> Logistic.get_activity!(activity.id) end
    end

    test "change_activity/1 returns a activity changeset" do
      activity = activity_fixture()
      assert %Ecto.Changeset{} = Logistic.change_activity(activity)
    end
  end

  describe "images" do
    alias Transporter.Logistic.Image

    @valid_attrs %{activity_id: 42, filename: "some filename", thumbnail: "some thumbnail"}
    @update_attrs %{activity_id: 43, filename: "some updated filename", thumbnail: "some updated thumbnail"}
    @invalid_attrs %{activity_id: nil, filename: nil, thumbnail: nil}

    def image_fixture(attrs \\ %{}) do
      {:ok, image} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Logistic.create_image()

      image
    end

    test "list_images/0 returns all images" do
      image = image_fixture()
      assert Logistic.list_images() == [image]
    end

    test "get_image!/1 returns the image with given id" do
      image = image_fixture()
      assert Logistic.get_image!(image.id) == image
    end

    test "create_image/1 with valid data creates a image" do
      assert {:ok, %Image{} = image} = Logistic.create_image(@valid_attrs)
      assert image.activity_id == 42
      assert image.filename == "some filename"
      assert image.thumbnail == "some thumbnail"
    end

    test "create_image/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Logistic.create_image(@invalid_attrs)
    end

    test "update_image/2 with valid data updates the image" do
      image = image_fixture()
      assert {:ok, image} = Logistic.update_image(image, @update_attrs)
      assert %Image{} = image
      assert image.activity_id == 43
      assert image.filename == "some updated filename"
      assert image.thumbnail == "some updated thumbnail"
    end

    test "update_image/2 with invalid data returns error changeset" do
      image = image_fixture()
      assert {:error, %Ecto.Changeset{}} = Logistic.update_image(image, @invalid_attrs)
      assert image == Logistic.get_image!(image.id)
    end

    test "delete_image/1 deletes the image" do
      image = image_fixture()
      assert {:ok, %Image{}} = Logistic.delete_image(image)
      assert_raise Ecto.NoResultsError, fn -> Logistic.get_image!(image.id) end
    end

    test "change_image/1 returns a image changeset" do
      image = image_fixture()
      assert %Ecto.Changeset{} = Logistic.change_image(image)
    end
  end

  describe "user_jobs" do
    alias Transporter.Logistic.UserJob

    @valid_attrs %{job_id: 42, status: "some status", user_id: 42}
    @update_attrs %{job_id: 43, status: "some updated status", user_id: 43}
    @invalid_attrs %{job_id: nil, status: nil, user_id: nil}

    def user_job_fixture(attrs \\ %{}) do
      {:ok, user_job} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Logistic.create_user_job()

      user_job
    end

    test "list_user_jobs/0 returns all user_jobs" do
      user_job = user_job_fixture()
      assert Logistic.list_user_jobs() == [user_job]
    end

    test "get_user_job!/1 returns the user_job with given id" do
      user_job = user_job_fixture()
      assert Logistic.get_user_job!(user_job.id) == user_job
    end

    test "create_user_job/1 with valid data creates a user_job" do
      assert {:ok, %UserJob{} = user_job} = Logistic.create_user_job(@valid_attrs)
      assert user_job.job_id == 42
      assert user_job.status == "some status"
      assert user_job.user_id == 42
    end

    test "create_user_job/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Logistic.create_user_job(@invalid_attrs)
    end

    test "update_user_job/2 with valid data updates the user_job" do
      user_job = user_job_fixture()
      assert {:ok, user_job} = Logistic.update_user_job(user_job, @update_attrs)
      assert %UserJob{} = user_job
      assert user_job.job_id == 43
      assert user_job.status == "some updated status"
      assert user_job.user_id == 43
    end

    test "update_user_job/2 with invalid data returns error changeset" do
      user_job = user_job_fixture()
      assert {:error, %Ecto.Changeset{}} = Logistic.update_user_job(user_job, @invalid_attrs)
      assert user_job == Logistic.get_user_job!(user_job.id)
    end

    test "delete_user_job/1 deletes the user_job" do
      user_job = user_job_fixture()
      assert {:ok, %UserJob{}} = Logistic.delete_user_job(user_job)
      assert_raise Ecto.NoResultsError, fn -> Logistic.get_user_job!(user_job.id) end
    end

    test "change_user_job/1 returns a user_job changeset" do
      user_job = user_job_fixture()
      assert %Ecto.Changeset{} = Logistic.change_user_job(user_job)
    end
  end

  describe "containers" do
    alias Transporter.Logistic.Container

    @valid_attrs %{job_id: 42, job_no: "some job_no", name: "some name", status: "some status"}
    @update_attrs %{job_id: 43, job_no: "some updated job_no", name: "some updated name", status: "some updated status"}
    @invalid_attrs %{job_id: nil, job_no: nil, name: nil, status: nil}

    def container_fixture(attrs \\ %{}) do
      {:ok, container} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Logistic.create_container()

      container
    end

    test "list_containers/0 returns all containers" do
      container = container_fixture()
      assert Logistic.list_containers() == [container]
    end

    test "get_container!/1 returns the container with given id" do
      container = container_fixture()
      assert Logistic.get_container!(container.id) == container
    end

    test "create_container/1 with valid data creates a container" do
      assert {:ok, %Container{} = container} = Logistic.create_container(@valid_attrs)
      assert container.job_id == 42
      assert container.job_no == "some job_no"
      assert container.name == "some name"
      assert container.status == "some status"
    end

    test "create_container/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Logistic.create_container(@invalid_attrs)
    end

    test "update_container/2 with valid data updates the container" do
      container = container_fixture()
      assert {:ok, container} = Logistic.update_container(container, @update_attrs)
      assert %Container{} = container
      assert container.job_id == 43
      assert container.job_no == "some updated job_no"
      assert container.name == "some updated name"
      assert container.status == "some updated status"
    end

    test "update_container/2 with invalid data returns error changeset" do
      container = container_fixture()
      assert {:error, %Ecto.Changeset{}} = Logistic.update_container(container, @invalid_attrs)
      assert container == Logistic.get_container!(container.id)
    end

    test "delete_container/1 deletes the container" do
      container = container_fixture()
      assert {:ok, %Container{}} = Logistic.delete_container(container)
      assert_raise Ecto.NoResultsError, fn -> Logistic.get_container!(container.id) end
    end

    test "change_container/1 returns a container changeset" do
      container = container_fixture()
      assert %Ecto.Changeset{} = Logistic.change_container(container)
    end
  end
end
