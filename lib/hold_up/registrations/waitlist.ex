defmodule HoldUp.Registrations.Waitlist do
  use Ecto.Schema
  import Ecto.Changeset


  schema "waitlists" do
    field :name, :string
    field :business_id, :id, null: false

    timestamps()
  end

  @doc false
  def changeset(waitlist, attrs) do
    waitlist
    |> cast(attrs, [:name, :business_id])
    |> validate_required([:name, :business_id])
  end
end