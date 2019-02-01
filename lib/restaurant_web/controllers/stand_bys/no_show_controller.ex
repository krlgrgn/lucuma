defmodule RestaurantWeb.StandBys.NoShowController do
  use RestaurantWeb, :controller

  alias Restaurant.WaitLists

  def create(conn, params) do
    WaitLists.mark_as_no_show(params["stand_by_id"])

    conn
      |> redirect(to: Routes.wait_list_path(conn, :index))
  end
end