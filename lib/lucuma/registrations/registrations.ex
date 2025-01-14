defmodule Lucuma.Registrations do
  @moduledoc """
  The Registrations context.
  """

  import Ecto.Query, warn: false
  require Logger

  alias Lucuma.Repo
  alias Lucuma.Registrations.RegistrationForm
  alias Lucuma.Registrations.Registration
  alias Lucuma.Accounts
  alias Lucuma.Waitlists
  alias Ecto.Multi

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking registration_form changes.

  ## Examples

      iex> change_registration_form(registration_form)
      %Ecto.Changeset{source: %RegistrationForm{}}

  """

  @doc """
  Creates a registration_form.

  ## Examples

      iex> create_registration_form(%{field: value})
      {:ok, %RegistrationForm{}}

      iex> create_registration_form(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_registration_form(attrs \\ %{}) do
    changeset = RegistrationForm.changeset(%RegistrationForm{}, attrs)

    if changeset.valid? do
      registration_form = Ecto.Changeset.apply_changes(changeset)

      multi_result =
        Multi.new()
        |> Multi.insert(:company, company_changeset(registration_form))
        |> Ecto.Multi.insert(:user, fn %{company: company} ->
          user_attrs = %{
            email: registration_form.email,
            full_name: registration_form.full_name,
            password: registration_form.password,
            password_confirmation: registration_form.password_confirmation,
            company_id: company.id,
            roles: ["company_admin"]
          }

          changeset =
            company
            |> Ecto.build_assoc(:users)
            |> Accounts.User.changeset(user_attrs)

          changeset
        end)
        |> Ecto.Multi.insert(:business, fn previous_steps ->
          business_attrs = %{
            name: previous_steps.company.name,
            time_zone: registration_form.time_zone
          }

          changeset =
            previous_steps.company
            |> Ecto.build_assoc(:businesses)
            |> Accounts.Business.changeset(business_attrs)

          changeset
        end)
        |> Ecto.Multi.insert(:user_business, fn previous_steps ->
          changeset =
            Accounts.UserBusiness.changeset(%Accounts.UserBusiness{}, %{
              user_id: previous_steps.user.id,
              business_id: previous_steps.business.id
            })

          changeset
        end)
        |> Ecto.Multi.insert(:waitlist, fn previous_steps ->
          waitlist_attrs = %{
            name: "Waitlist 1"
          }

          changeset =
            previous_steps.business
            |> Ecto.build_assoc(:waitlist)
            |> Waitlists.Waitlist.changeset(waitlist_attrs)

          changeset
        end)
        |> Ecto.Multi.insert(:confirmation_sms_setting, fn previous_steps ->
          changeset =
            previous_steps.waitlist
            |> Ecto.build_assoc(:confirmation_sms_setting)
            |> Waitlists.new_confirmation_sms_setting_changeset()

          changeset
        end)
        |> Ecto.Multi.insert(:attendance_sms_setting, fn previous_steps ->
          changeset =
            previous_steps.waitlist
            |> Ecto.build_assoc(:attendance_sms_setting)
            |> Waitlists.new_attendance_sms_setting_changeset()

          changeset
        end)
        |> Repo.transaction()

      case multi_result do
        {:ok, steps} ->
          {:ok, steps}

        {:error, failed_operation, failed_value, changes_so_far} ->
          Logger.info(inspect(failed_operation))
          Logger.info(inspect(failed_value))
          Logger.info(inspect(changes_so_far))
          {:error, %{changeset | action: :registration}}
      end
    else
      {:error, %{changeset | action: :registration}}
    end
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking registration_form changes.

  ## Examples

      iex> change_registration_form(registration_form)
      %Ecto.Changeset{source: %RegistrationForm{}}

  """
  def change_registration_form(%RegistrationForm{} = registration_form) do
    RegistrationForm.changeset(registration_form, %{})
  end

  def validate_registration_form(attrs \\ %{}) do
    changeset = RegistrationForm.changeset(%RegistrationForm{}, attrs)

    case changeset.valid? do
      true ->
        {:ok, changeset}

      false ->
        {:error, changeset}
    end
  end

  def complete_registration(account_attrs, billing_attrs) do
    # create_registration_form(account_attrs)
    # Billing.create_subscription(user, company,)
  end

  defp company_changeset(registration_form) do
    Accounts.Company.changeset(%Accounts.Company{}, %{
      name: registration_form.company_name,
      contact_email: registration_form.email
    })
  end
end
