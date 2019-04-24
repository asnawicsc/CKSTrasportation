defmodule Transporter.Logistic do
  @moduledoc """
  The Logistic context.
  """
  require IEx
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

  def get_geolocation(considerIp) do
    url =
      "https://www.googleapis.com/geolocation/v1/geolocate?key=AIzaSyAw002sv9jlGumHGfjOGSqCUtAzJo-ypPg"

    HTTPoison.post!(url, Poison.encode!(%{considerIp: considerIp}), [
      {"Content-Type", "application/json"}
    ]).body
    |> Poison.decode!()
  end

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
  def list_activities(job_id \\ nil) do
    if job_id == nil do
      Repo.all(
        from(
          a in Activity,
          left_join: j in Job,
          on: a.job_id == j.id,
          select: %{
            id: a.id,
            job_id: j.id,
            job_no: j.job_no,
            created_by: a.created_by,
            message: a.message,
            location: a.location,
            fee: a.fee,
            inserted_at: a.inserted_at,
            container_name: a.container_name,
            trailer_no: a.trailer_no,
            delivery_type: a.delivery_type,
            delivery_mode: a.delivery_mode,
            activity_type: a.activity_type
          }
        )
      )
    else
      Repo.all(
        from(
          a in Activity,
          left_join: j in Job,
          on: a.job_id == j.id,
          where: a.job_id == ^job_id,
          select: %{
            id: a.id,
            job_id: j.id,
            job_no: j.job_no,
            created_by: a.created_by,
            message: a.message,
            location: a.location,
            fee: a.fee,
            inserted_at: a.inserted_at,
            container_name: a.container_name,
            trailer_no: a.trailer_no,
            delivery_type: a.delivery_type,
            delivery_mode: a.delivery_mode,
            activity_type: a.activity_type
          },
          order_by: [a.id]
        )
      )
    end
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
  def create_activity(attrs \\ %{}, job \\ nil, user \\ nil) do
    a =
      %Activity{}
      |> Activity.changeset(attrs)
      |> Repo.insert()

    if job != nil do
      name =
        if user != nil do
          user.username
        else
          b = Repo.all(Transporter.Settings.User) |> List.first()
          b.username
        end

      attrs =
        if Map.keys(attrs) |> List.first() |> is_atom() do
          attrs
        else
          for {key, val} <- attrs, into: %{}, do: {String.to_atom(key), val}
        end

      c = Job.changeset(job, %{last_activity: attrs.message, last_by: name}) |> Repo.update()
    end

    a
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
    path = File.cwd!() <> "/media/#{activity_id}"
    image_path = Application.app_dir(:transporter, "priv/static/images")

    if File.exists?(path) == false do
      File.mkdir(File.cwd!() <> "/media/#{activity_id}")
    end

    fl = param.filename |> String.replace(" ", "_")
    absolute_path = path <> "/#{fl}"
    absolute_path_bin = path <> "/bin_" <> "#{fl}"

    File.cp(param.path, absolute_path)
    File.rm(image_path <> "/uploads/#{activity_id}")
    File.ln_s(path, image_path <> "/uploads/#{activity_id}")

    resized =
      Mogrify.open(absolute_path)
      |> resize("600x600")
      |> save(path: absolute_path_bin)

    File.cp(resized.path, absolute_path)
    File.rm(image_path <> "/uploads/#{activity_id}")
    File.ln_s(path, image_path <> "/uploads/#{activity_id}")

    {:ok, bin} = File.read(resized.path)

    File.rm(resized.path)
    %{filename: "/#{activity_id}/#{fl}", bin: bin}
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

  def list_user_jobs(user_id) do
    a =
      Repo.all(
        from(
          u in UserJob,
          left_join: j in Job,
          on: j.id == u.job_id,
          where: u.user_id == ^user_id,
          select: %{
            status: u.status,
            last_activity: j.last_activity,
            last_updated: j.updated_at,
            description: j.description,
            job_no: j.job_no,
            id: j.id
          }
        )
      )

    IO.inspect(a)

    a
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

  alias Transporter.Logistic.Container

  @doc """
  Returns the list of containers.

  ## Examples

      iex> list_containers()
      [%Container{}, ...]

  """
  def list_containers do
    Repo.all(Container)
  end

  @doc """
  Gets a single container.

  Raises `Ecto.NoResultsError` if the Container does not exist.

  ## Examples

      iex> get_container!(123)
      %Container{}

      iex> get_container!(456)
      ** (Ecto.NoResultsError)

  """
  def get_container!(id), do: Repo.get!(Container, id)

  @doc """
  Creates a container.

  ## Examples

      iex> create_container(%{field: value})
      {:ok, %Container{}}

      iex> create_container(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_container(attrs \\ %{}) do
    %Container{}
    |> Container.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a container.

  ## Examples

      iex> update_container(container, %{field: new_value})
      {:ok, %Container{}}

      iex> update_container(container, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_container(%Container{} = container, attrs) do
    container
    |> Container.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a Container.

  ## Examples

      iex> delete_container(container)
      {:ok, %Container{}}

      iex> delete_container(container)
      {:error, %Ecto.Changeset{}}

  """
  def delete_container(%Container{} = container) do
    Repo.delete(container)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking container changes.

  ## Examples

      iex> change_container(container)
      %Ecto.Changeset{source: %Container{}}

  """
  def change_container(%Container{} = container) do
    Container.changeset(container, %{})
  end

  def delivery_summary() do
    data =
      Repo.all(
        from(
          a in Activity,
          left_join: j in Job,
          on: a.job_id == j.id,
          left_join: c in Container,
          on: c.job_id == j.id,
          where: not is_nil(a.container_name),
          select: %{
            vessel: j.vessel_name,
            voyage: j.voyage_no,
            customer: j.customer,
            job_no: j.job_no,
            container: a.container_name,
            message: a.message,
            dd: j.dd_date,
            type: a.activity_type,
            driver: a.created_by
          }
        )
      )

    j =
      data |> Enum.filter(fn x -> x.type == "lorrydriver_assigned" end)
      |> Enum.group_by(fn x -> x.vessel end)

    ga = data |> Enum.filter(fn x -> x.type == "out_lorrydriver_ack" end)
    gs = data |> Enum.filter(fn x -> x.type == "out_lorrydriver_start" end)
    ge = data |> Enum.filter(fn x -> x.type == "out_lorrydriver_start" end)

    %{jobs: j, ack: ga, start: gs, end: ge}
  end

  def outstanding_container() do
    data =
      Repo.all(
        from(
          a in Activity,
          left_join: j in Job,
          on: a.job_id == j.id,
          left_join: c in Container,
          on: c.job_id == j.id,
          select: %{
            vessel: j.vessel_name,
            voyage: j.voyage_no,
            customer: j.customer,
            job_no: j.job_no,
            container: c.name,
            message: a.message,
            dd: j.dd_date,
            type: a.activity_type
          }
        )
      )

    j =
      data |> Enum.filter(fn x -> x.type == "forwarder_assign" end)
      |> Enum.group_by(fn x -> x.vessel end)

    ga = data |> Enum.filter(fn x -> x.type == "gateman_ack" end)
    gc = data |> Enum.filter(fn x -> x.type == "gateman_clear" end)

    %{jobs: j, g_clear: gc, g_ack: ga}
  end

  def outstanding_forwarding() do
    data =
      Repo.all(
        from(
          a in Activity,
          left_join: j in Job,
          on: a.job_id == j.id,
          select: %{
            vessel: j.vessel_name,
            voyage: j.voyage_no,
            customer: j.customer,
            job_no: j.job_no,
            message: a.message,
            dd: j.dd_date,
            type: a.activity_type
          }
        )
      )

    j =
      data |> Enum.filter(fn x -> x.type == "forwarder_assign" end)
      |> Enum.group_by(fn x -> x.vessel end)

    a = data |> Enum.filter(fn x -> x.type == "forwarder_assigned" end)
    b = data |> Enum.filter(fn x -> x.type == "forwarder_ack" end)
    c = data |> Enum.filter(fn x -> x.type == "forwarder_clear" end)

    %{jobs: j, assigned: a, ack: b, clear: c}
  end

  alias Transporter.Logistic.ContainerRoute

  @doc """
  Returns the list of container_routes.

  ## Examples

      iex> list_container_routes()
      [%ContainerRoute{}, ...]

  """
  def list_container_routes do
    Repo.all(ContainerRoute)
  end

  @doc """
  Gets a single container_route.

  Raises `Ecto.NoResultsError` if the Container route does not exist.

  ## Examples

      iex> get_container_route!(123)
      %ContainerRoute{}

      iex> get_container_route!(456)
      ** (Ecto.NoResultsError)

  """
  def get_container_route!(id), do: Repo.get!(ContainerRoute, id)

  @doc """
  Creates a container_route.

  ## Examples

      iex> create_container_route(%{field: value})
      {:ok, %ContainerRoute{}}

      iex> create_container_route(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_container_route(attrs \\ %{}) do
    %ContainerRoute{}
    |> ContainerRoute.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a container_route.

  ## Examples

      iex> update_container_route(container_route, %{field: new_value})
      {:ok, %ContainerRoute{}}

      iex> update_container_route(container_route, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_container_route(%ContainerRoute{} = container_route, attrs) do
    container_route
    |> ContainerRoute.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a ContainerRoute.

  ## Examples

      iex> delete_container_route(container_route)
      {:ok, %ContainerRoute{}}

      iex> delete_container_route(container_route)
      {:error, %Ecto.Changeset{}}

  """
  def delete_container_route(%ContainerRoute{} = container_route) do
    Repo.delete(container_route)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking container_route changes.

  ## Examples

      iex> change_container_route(container_route)
      %Ecto.Changeset{source: %ContainerRoute{}}

  """
  def change_container_route(%ContainerRoute{} = container_route) do
    ContainerRoute.changeset(container_route, %{})
  end
end
