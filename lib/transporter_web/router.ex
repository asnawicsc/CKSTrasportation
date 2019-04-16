defmodule TransporterWeb.Router do
  use TransporterWeb, :router

  pipeline :browser do
    plug(:accepts, ["html"])
    plug(:fetch_session)
    plug(:fetch_flash)
    plug(:protect_from_forgery)
    plug(:put_secure_browser_headers)
  end

  pipeline :api do
    plug(:accepts, ["json"])
  end

  scope "/", TransporterWeb do
    # Use the default browser stack
    pipe_through(:browser)

    get("/", PageController, :index)
    get("/login", UserController, :login)
    post("/authenticate_login", UserController, :authenticate_login)
    get("/logout", UserController, :logout)
    resources("/users", UserController)

    resources("/jobs", JobController)
    resources("/activities", ActivityController)
    # resources("/images", ImageController)
    resources("/user_jobs", UserJobController)
    post("/user_jobs/save_assignment", UserJobController, :save_assignment)
    resources("/containers", ContainerController)
    resources("/companies", CompanyController)
    resources("/delivery_location", DeliveryLocationController)
  end

  # Other scopes may use custom stacks.
  scope "/api", TransporterWeb do
    pipe_through(:api)

    get("/webhook", PageController, :webhook_get)
    post("/webhook", PageController, :webhook_post)
  end
end
