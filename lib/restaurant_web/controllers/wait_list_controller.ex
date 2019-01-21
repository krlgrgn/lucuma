defmodule RestaurantWeb.WaitListController do
  use RestaurantWeb, :controller

  alias Restaurant.WaitLists
  alias Restaurant.WaitLists.WaitList

  def index(conn, _params) do
    wait_list = WaitLists.get_wait_list!(1)
    render(conn, "index.html", wait_list: wait_list)
  end
end
