defmodule HoldUpWeb.StandBys.NoShowController do
  use HoldUpWeb, :controller

  alias HoldUp.Waitlists

  def create(conn, params) do
    Waitlists.mark_as_no_show(params["stand_by_id"])

    conn
      |> redirect(to: Routes.waitlist_path(conn, :index))
  end
end