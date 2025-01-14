defmodule Lucuma.Notifications.SmsNotification do
  use Ecto.Schema
  import Ecto.Changeset

  schema "sms_notifications" do
    field :message_content, :string
    field :recipient_phone_number, :string
    field :status, :string, default: "for_delivery"
    field :retries, :integer, default: 0

    belongs_to :stand_by, Lucuma.Waitlists.StandBy
    belongs_to :business, Lucuma.Accounts.Business

    timestamps()
  end

  @doc false
  def changeset(sms_setting, attrs) do
    sms_setting
    |> cast(attrs, [:business_id, :message_content, :recipient_phone_number, :stand_by_id, :status, :retries])
    |> validate_required([
      :message_content,
      :recipient_phone_number,
      :stand_by_id,
      :business_id,
      :status,
      :retries
    ])
    |> validate_inclusion(:status, [
      "for_delivery",
      "queued_for_delivery",
      "delivering",
      "delivered",
      "cannot_deliver"
    ])
  end
end
