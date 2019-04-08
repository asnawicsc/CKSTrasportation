# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# General application configuration
config :transporter,
  ecto_repos: [Transporter.Repo]

# Configures the endpoint
config :transporter, TransporterWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "t7y/LhPH0qmuVCVU9xx+A9TwlJnQh7eEu5tR6CO1EYS+Jl/Dd4Kfl8u2XbsrbPOW",
  render_errors: [view: TransporterWeb.ErrorView, accepts: ~w(html json)],
  pubsub: [name: Transporter.PubSub,
           adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env}.exs"
