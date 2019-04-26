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
Repo.delete_all(User)
alias Transporter.Repo
import Ecto.Query
alias Transporter.Settings
alias Transporter.Settings.User
alias Transporter.Logistic
alias Transporter.Logistic.{Activity, Job, UserJob, Container, ContainerRoute}

Repo.delete_all(UserJob)
Repo.delete_all(Job)
Repo.delete_all(Activity)
Repo.delete_all(Container)
Repo.delete_all(ContainerRoute)

Transporter.Settings.create_users(%{
  username: "peter",
  email: "p@1.com",
  user_type: "Staff",
  user_level: "Forwarder",
  pin: "1231",
  password: "1231"
})

Transporter.Settings.create_users(%{
  username: "damien",
  email: "d@1.com",
  user_type: "Staff",
  user_level: "Gateman",
  pin: "1232",
  password: "1232"
})

Transporter.Settings.create_users(%{
  username: "elis",
  email: "e@1.com",
  user_type: "Staff",
  user_level: "LorryDriver",
  pin: "1233",
  password: "1233"
})
