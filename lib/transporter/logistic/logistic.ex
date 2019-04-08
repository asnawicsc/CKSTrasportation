defmodule Transporter.Logistic do
  @moduledoc """
  The Logistic context.
  """
  import Mogrify
  import Ecto.Query, warn: false
  alias Transporter.Repo

  alias Transporter.Logistic.Job

  @doc """
  Returns the list of jobs.

  ## Examples

      iex> list_jobs()
      [%Job{}, ...]

  """
  def list_jobs do
    Repo.all(Job)
  end

  @doc """
  Gets a single job.

  Raises `Ecto.NoResultsError` if the Job does not exist.

  ## Examples

      iex> get_job!(123)
      %Job{}

      iex> get_job!(456)
      ** (Ecto.NoResultsError)

  """
  def get_job!(id), do: Repo.get!(Job, id)

  @doc """
  Creates a job.

  ## Examples

      iex> create_job(%{field: value})
      {:ok, %Job{}}

      iex> create_job(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_job(attrs \\ %{}) do
    %Job{}
    |> Job.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a job.

  ## Examples

      iex> update_job(job, %{field: new_value})
      {:ok, %Job{}}

      iex> update_job(job, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_job(%Job{} = job, attrs) do
    job
    |> Job.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a Job.

  ## Examples

      iex> delete_job(job)
      {:ok, %Job{}}

      iex> delete_job(job)
      {:error, %Ecto.Changeset{}}

  """
  def delete_job(%Job{} = job) do
    Repo.delete(job)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking job changes.

  ## Examples

      iex> change_job(job)
      %Ecto.Changeset{source: %Job{}}

  """
  def change_job(%Job{} = job) do
    Job.changeset(job, %{})
  end

  alias Transporter.Logistic.Activity

  @doc """
  Returns the list of activities.

  ## Examples

      iex> list_activities()
      [%Activity{}, ...]

  """
  def list_activities do
    Repo.all(Activity)
  end

  @doc """
  Gets a single activity.

  Raises `Ecto.NoResultsError` if the Activity does not exist.

  ## Examples

      iex> get_activity!(123)
      %Activity{}

      iex> get_activity!(456)
      ** (Ecto.NoResultsError)

  """
  def get_activity!(id), do: Repo.get!(Activity, id)

  @doc """
  Creates a activity.

  ## Examples

      iex> create_activity(%{field: value})
      {:ok, %Activity{}}

      iex> create_activity(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_activity(attrs \\ %{}) do
    %Activity{}
    |> Activity.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a activity.

  ## Examples

      iex> update_activity(activity, %{field: new_value})
      {:ok, %Activity{}}

      iex> update_activity(activity, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_activity(%Activity{} = activity, attrs) do
    activity
    |> Activity.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a Activity.

  ## Examples

      iex> delete_activity(activity)
      {:ok, %Activity{}}

      iex> delete_activity(activity)
      {:error, %Ecto.Changeset{}}

  """
  def delete_activity(%Activity{} = activity) do
    Repo.delete(activity)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking activity changes.

  ## Examples

      iex> change_activity(activity)
      %Ecto.Changeset{source: %Activity{}}

  """
  def change_activity(%Activity{} = activity) do
    Activity.changeset(activity, %{})
  end

  alias Transporter.Logistic.Image

  @doc """
  Returns the list of images.

  ## Examples

      iex> list_images()
      [%Image{}, ...]

  """
  def list_images do
    Repo.all(Image)
  end

  @doc """
  Gets a single image.

  Raises `Ecto.NoResultsError` if the Image does not exist.

  ## Examples

      iex> get_image!(123)
      %Image{}

      iex> get_image!(456)
      ** (Ecto.NoResultsError)

  """
  def get_image!(id), do: Repo.get!(Image, id)

  @doc """
  Creates a image.

  ## Examples

      iex> create_image(%{field: value})
      {:ok, %Image{}}

      iex> create_image(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_image(attrs \\ %{}) do
    %Image{}
    |> Image.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a image.

  ## Examples

      iex> update_image(image, %{field: new_value})
      {:ok, %Image{}}

      iex> update_image(image, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_image(%Image{} = image, attrs) do
    image
    |> Image.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a Image.

  ## Examples

      iex> delete_image(image)
      {:ok, %Image{}}

      iex> delete_image(image)
      {:error, %Ecto.Changeset{}}

  """
  def delete_image(%Image{} = image) do
    Repo.delete(image)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking image changes.

  ## Examples

      iex> change_image(image)
      %Ecto.Changeset{source: %Image{}}

  """
  def change_image(%Image{} = image) do
    Image.changeset(image, %{})
  end

  def image_upload(param, activity_id) do
    path = File.cwd!() <> "/media"
    image_path = Application.app_dir(:webpos, "priv/static/images")

    if File.exists?(path) == false do
      File.mkdir(File.cwd!() <> "/media")
    end

    fl = param.filename |> String.replace(" ", "_")
    absolute_path = path <> "/#{activity_id}/#{fl}"
    absolute_path_bin = path <> "/bin_" <> "#{activity_id}/#{fl}"
    File.cp(param.path, absolute_path)
    File.rm(image_path <> "/uploads")
    File.ln_s(path, image_path <> "/uploads")

    resized =
      Mogrify.open(absolute_path)
      |> resize("200x200")
      |> save(path: absolute_path_bin)

    File.cp(resized.path, absolute_path)
    File.rm(image_path <> "/uploads")
    File.ln_s(path, image_path <> "/uploads")

    {:ok, bin} = File.read(resized.path)

    File.rm(resized.path)
    %{filename: "#{activity_id}/#{fl}", bin: bin}
  end

  alias Transporter.Logistic.UserJob

  @doc """
  Returns the list of user_jobs.

  ## Examples

      iex> list_user_jobs()
      [%UserJob{}, ...]

  """
  def list_user_jobs do
    Repo.all(UserJob)
  end

  @doc """
  Gets a single user_job.

  Raises `Ecto.NoResultsError` if the User job does not exist.

  ## Examples

      iex> get_user_job!(123)
      %UserJob{}

      iex> get_user_job!(456)
      ** (Ecto.NoResultsError)

  """
  def get_user_job!(id), do: Repo.get!(UserJob, id)

  @doc """
  Creates a user_job.

  ## Examples

      iex> create_user_job(%{field: value})
      {:ok, %UserJob{}}

      iex> create_user_job(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_user_job(attrs \\ %{}) do
    %UserJob{}
    |> UserJob.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a user_job.

  ## Examples

      iex> update_user_job(user_job, %{field: new_value})
      {:ok, %UserJob{}}

      iex> update_user_job(user_job, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_user_job(%UserJob{} = user_job, attrs) do
    user_job
    |> UserJob.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a UserJob.

  ## Examples

      iex> delete_user_job(user_job)
      {:ok, %UserJob{}}

      iex> delete_user_job(user_job)
      {:error, %Ecto.Changeset{}}

  """
  def delete_user_job(%UserJob{} = user_job) do
    Repo.delete(user_job)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking user_job changes.

  ## Examples

      iex> change_user_job(user_job)
      %Ecto.Changeset{source: %UserJob{}}

  """
  def change_user_job(%UserJob{} = user_job) do
    UserJob.changeset(user_job, %{})
  end
end