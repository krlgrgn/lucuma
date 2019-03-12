defmodule HoldUp.Waitlists.Waitlist do
  use Ecto.Schema
  import Ecto.Changeset

  schema "waitlists" do
    field :name, :string
    field :notification_sms_body, :string

    timestamps()

    belongs_to :business, HoldUp.Accounts.Business
    has_many :stand_bys, HoldUp.Waitlists.StandBy
  end

  @doc false
  def changeset(waitlist, attrs) do
    waitlist
    |> cast(attrs, [:name, :business_id, :notification_sms_body])
    |> validate_required([:name, :business_id])
  end
end
