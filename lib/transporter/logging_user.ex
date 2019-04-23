defmodule Transporter.LoggingUser do
  import Plug.Conn
  import Phoenix.Controller
  require IEx

  def init(opts) do
    opts
  end

  def call(conn, opts) do
    cond do
      conn.private.plug_session["user_id"] == nil ->
        if conn.request_path == "/login" or conn.request_path == "/authenticate_login" do
          conn
        else
          conn
          |> put_flash(:error, "Please login")
          |> redirect(to: "/login")
          |> halt
        end

      true ->
        conn
    end
  end
end
