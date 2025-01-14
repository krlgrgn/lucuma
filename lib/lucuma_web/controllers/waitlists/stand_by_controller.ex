defmodule LucumaWeb.Waitlists.StandByController do
  use LucumaWeb, :controller

  alias Lucuma.Waitlists
  alias Lucuma.Waitlists.StandBy

  plug :put_layout, false when action in [:new]

  def new(conn, _params) do
    waitlist = Waitlists.get_waitlist!(conn.params["waitlist_id"])
    changeset = Waitlists.change_stand_by(%StandBy{})
    render(conn, "new.html", changeset: changeset, waitlist: waitlist)
  end

  def create(conn, %{"stand_by" => stand_by_params}) do
    waitlist = Waitlists.get_waitlist!(conn.params["waitlist_id"])

    case Waitlists.create_stand_by(
           Map.put(stand_by_params, "waitlist_id", waitlist.id),
           conn.assigns.current_business,
           conn.assigns.current_company
         ) do
      {:ok, stand_by} ->
        conn
        |> put_flash(:info, "Stand by created successfully.")
        |> redirect(to: Routes.waitlists_waitlist_path(conn, :show, waitlist))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset, waitlist: waitlist)
    end
  end

  def show(conn, %{"id" => id}) do
    waitlist = Waitlists.get_waitlist!(conn.params["waitlist_id"])
    stand_by = Waitlists.get_stand_by!(id)

    render(conn, "show.html", stand_by: stand_by, waitlist: waitlist)
  end

  def edit(conn, %{"id" => id}) do
    waitlist = Waitlists.get_waitlist!(conn.params["waitlist_id"])
    stand_by = Waitlists.get_stand_by!(id)
    changeset = Waitlists.change_stand_by(stand_by)

    render(conn, "edit.html", stand_by: stand_by, changeset: changeset, waitlist: waitlist)
  end

  def update(conn, %{"id" => id, "stand_by" => stand_by_params}) do
    waitlist = Waitlists.get_waitlist!(conn.params["waitlist_id"])
    stand_by = Waitlists.get_stand_by!(id)

    case Waitlists.update_stand_by(stand_by, stand_by_params) do
      {:ok, stand_by} ->
        conn
        |> put_flash(:info, "Stand by updated successfully.")
        |> redirect(to: Routes.waitlists_waitlist_path(conn, :show, waitlist))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", stand_by: stand_by, changeset: changeset)
    end
  end
end
