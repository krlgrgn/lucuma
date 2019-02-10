defmodule HoldUpWeb.StandBys.AttendanceController do
  use HoldUpWeb, :controller

  alias HoldUp.WaitLists

  def create(conn, params) do
    WaitLists.mark_as_attended(params["stand_by_id"])

    conn
    |> redirect(to: Routes.wait_list_path(conn, :index))
  end
end