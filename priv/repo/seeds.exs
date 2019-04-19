# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     Transporter.Repo.insert!(%Transporter.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.

alias Transporter.Repo
import Ecto.Query
alias Transporter.Settings
alias Transporter.Settings.User
alias Transporter.Logistic
alias Transporter.Logistic.{Activity, Job, UserJob, Container}

Repo.delete_all(UserJob)
Repo.delete_all(Job)
Repo.delete_all(Activity)
Repo.delete_all(Container)
