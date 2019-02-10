defmodule HoldUpWeb.StandBys.NotificationController do
  use HoldUpWeb, :controller

  alias HoldUp.WaitLists

  def create(conn, params) do
    WaitLists.notify_stand_by(params["stand_by_id"])

    conn
      |> redirect(to: Routes.wait_list_path(conn, :index))
  end
end