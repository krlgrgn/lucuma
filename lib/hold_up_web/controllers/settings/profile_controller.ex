defmodule HoldUpWeb.Settings.ProfileController do
  use HoldUpWeb, :controller

  plug :put_layout, :settings

  def show(conn, params) do
    render(conn, "show.html")
  end
end
