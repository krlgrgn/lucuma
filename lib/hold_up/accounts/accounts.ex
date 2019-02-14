defmodule HoldUp.Accounts do
  @moduledoc """
  The Accounts context.
  """

  import Ecto.Query, warn: false
  alias HoldUp.Repo

  alias HoldUp.Accounts.User
  alias HoldUp.Accounts.Company
  alias HoldUp.Accounts.Business


  def list_users do
    Repo.all(User)
  end

  def get_user!(id), do: Repo.get!(User, id)

  def get_user(id), do: Repo.get(User, id)

  def get_current_company(user), do: Repo.get(Company, user.company_id)

  @doc """
  Creates a user.

  ## Examples

      iex> create_user(%{field: value})
      {:ok, %User{}}

      iex> create_user(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_user(attrs \\ %{}) do
    %User{}
    |> User.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a user.

  ## Examples

      iex> update_user(user, %{field: new_value})
      {:ok, %User{}}

      iex> update_user(user, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_user(%User{} = user, attrs) do
    user
    |> User.changeset(attrs)
    |> Repo.update()
  end

  def delete_user(%User{} = user) do
    Repo.delete(user)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking user changes.

  ## Examples

      iex> change_user(user)
      %Ecto.Changeset{source: %User{}}

  """
  def change_user(%User{} = user) do
    User.changeset(user, %{})
  end

  def get_user_by(email) do
    query = from user in HoldUp.Accounts.User,
            join: company in HoldUp.Accounts.Company,
            where: company.id == user.company_id,
            join: businesses in HoldUp.Accounts.Business,
            where: businesses.company_id == company.id,
            where: user.email == ^email,
            preload: [company: {company, businesses: businesses}]


    Repo.one(query)
  end

  def get_current_business_for_user(user) do
    query = from businesses in HoldUp.Accounts.Business,
            where: businesses.company_id == ^user.company_id


    Repo.one(query)
  end
end
