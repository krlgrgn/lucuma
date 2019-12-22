defmodule Lucuma.Waitlists.Analytics do
  @moduledoc """
  Enum.map((1..400), fn (n) -> x = :rand.uniform(60); insert(:stand_by, waitlist_id: 1, cancelled_at: DateTime.utc_now |> DateTime.add(-(3600 * (24 * x)), :second) |> DateTime.add((3600 * (1 * :rand.uniform(10))), :second), inserted_at: DateTime.utc_now |> DateTime.add(-(3600 * (24 * x)), :second))end)
  """
  import Ecto.Query

  alias Lucuma.Repo
  alias Lucuma.Waitlists.StandBy

  def total_waitlisted(waitlist_id) do
    Repo.one(from s in StandBy, where: s.waitlist_id == ^waitlist_id, select: count(s.id))
  end

  def unique_customer_count(waitlist_id) do
    Repo.one(
      from s in StandBy,
        where: s.waitlist_id == ^waitlist_id,
        select: count(s.contact_phone_number, :distinct)
    )
  end

  def served_customer_count(waitlist_id) do
    Repo.one(
      from s in StandBy,
        where: s.waitlist_id == ^waitlist_id and not is_nil(s.attended_at),
        select: count(s.id)
    )
  end

  def served_percentage(waitlist_id) do
    count =
      Repo.one(
        from s in StandBy,
          where:
            s.waitlist_id == ^waitlist_id and
              not is_nil(s.attended_at),
          select: count(s.id)
      )

    total_count =
      Repo.one(
        from s in StandBy,
          where: s.waitlist_id == ^waitlist_id,
          select: count(s.id)
      )

    if total_count == 0 do
      0
    else
      count / total_count * (100 / 1)
    end
  end

  def no_show_percentage(waitlist_id) do
    count =
      Repo.one(
        from s in StandBy,
          where:
            s.waitlist_id == ^waitlist_id and
              not is_nil(s.no_show_at),
          select: count(s.id)
      )

    total_count =
      Repo.one(
        from s in StandBy,
          where: s.waitlist_id == ^waitlist_id,
          select: count(s.id)
      )

    if total_count == 0 do
      0
    else
      count / total_count * (100 / 1)
    end
  end

  def cancellation_percentage(waitlist_id) do
    count =
      Repo.one(
        from s in StandBy,
          where:
            s.waitlist_id == ^waitlist_id and
              not is_nil(s.cancelled_at),
          select: count(s.id)
      )

    total_count =
      Repo.one(
        from s in StandBy,
          where: s.waitlist_id == ^waitlist_id,
          select: count(s.id)
      )

    if total_count == 0 do
      0
    else
      count / total_count * (100 / 1)
    end
  end

  def waitlisted_per_date(waitlist_id) do
    Repo.all(
      from s in StandBy,
        where: s.waitlist_id == ^waitlist_id,
        # Use a fragment to write some raw sql to convert timestamp to date.
        group_by: fragment("?::date::timestamp", s.inserted_at),
        select: [fragment("?::date::timestamp", s.inserted_at), count(s.id)]
    )
  end

  def served_per_date(waitlist_id) do
    Repo.all(
      from s in StandBy,
        where:
          s.waitlist_id == ^waitlist_id and
            not is_nil(s.attended_at),
        # Use a fragment to write some raw sql to convert timestamp to date.
        group_by: fragment("?::date::timestamp", s.inserted_at),
        select: [fragment("?::date::timestamp", s.inserted_at), count(s.id)]
    )
  end

  def no_show_per_date(waitlist_id) do
    Repo.all(
      from s in StandBy,
        where:
          s.waitlist_id == ^waitlist_id and
            not is_nil(s.no_show_at),
        # Use a fragment to write some raw sql to convert timestamp to date.
        group_by: fragment("?::date::timestamp", s.inserted_at),
        select: [fragment("?::date::timestamp", s.inserted_at), count(s.id)]
    )
  end

  def cancellation_per_date(waitlist_id) do
    Repo.all(
      from s in StandBy,
        where:
          s.waitlist_id == ^waitlist_id and
            not is_nil(s.cancelled_at),
        # Use a fragment to write some raw sql to convert timestamp to date.
        group_by: fragment("?::date::timestamp", s.inserted_at),
        select: [fragment("?::date::timestamp", s.inserted_at), count(s.id)]
    )
  end

  @moduledoc """
  returns the average amount of people served grouped by day (Mon, tues... sun)
  """
  def average_served_per_day(waitlist_id) do
    grouped_by_day_date_query =
      from s in StandBy,
        where:
          s.waitlist_id == ^waitlist_id and
            not is_nil(s.attended_at),
        # Use a fragment to write some raw sql to convert timestamp to date.
        group_by: [
          fragment("EXTRACT(ISODOW FROM ?)", s.inserted_at),
          fragment("?::date::timestamp", s.inserted_at)
        ],

        # https://stackoverflow.com/questions/42045295/ecto-queryerror-on-a-subquery
        # Write explanation.
        select: %{
          day: fragment("EXTRACT(ISODOW FROM ?)", s.inserted_at),
          date: fragment("?::date::timestamp", s.inserted_at),
          day_date_count: fragment("?::float", count(s.id))
        }

    Repo.all(
      from s in subquery(grouped_by_day_date_query),
        group_by: s.day,
        order_by: s.day,
        select: [s.day, avg(s.day_date_count)]
    )
  end

  @moduledoc """
  returns the average amount of people served grouped by hour
  """
  def average_served_per_hour(waitlist_id) do
    grouped_by_hour_date_query =
      from s in StandBy,
        where:
          s.waitlist_id == ^waitlist_id and
            not is_nil(s.attended_at),
        # Use a fragment to write some raw sql to convert timestamp to date.
        group_by: [
          fragment("EXTRACT(HOUR FROM ?)", s.inserted_at),
          fragment("?::date::timestamp", s.inserted_at)
        ],

        # https://stackoverflow.com/questions/42045295/ecto-queryerror-on-a-subquery
        # Write explanation.
        select: %{
          hour: fragment("EXTRACT(HOUR FROM ?)", s.inserted_at),
          date: fragment("?::date::timestamp", s.inserted_at),
          hour_date_count: fragment("?::float", count(s.id))
        }

    Repo.all(
      from s in subquery(grouped_by_hour_date_query),
        group_by: s.hour,
        order_by: s.hour,
        select: [s.hour, avg(s.hour_date_count)]
    )
  end

  @moduledoc """
  Returns the average amount of people served grouped by hour per day of the week.
  The average amount of people served per hour every Monday, Tuesday, etc..
  """
  def average_served_per_hour_per_day(waitlist_id) do
    grouped_by_day_hour_date_query =
      from s in StandBy,
        where:
          s.waitlist_id == ^waitlist_id and
            not is_nil(s.attended_at),
        # Use a fragment to write some raw sql to convert timestamp to date.
        group_by: [
          fragment("EXTRACT(ISODOW FROM ?)", s.inserted_at),
          fragment("EXTRACT(HOUR FROM ?)", s.inserted_at),
          fragment("?::date::timestamp", s.inserted_at)
        ],

        # https://stackoverflow.com/questions/42045295/ecto-queryerror-on-a-subquery
        # Write explanation.
        select: %{
          day: fragment("EXTRACT(ISODOW FROM ?)", s.inserted_at),
          hour: fragment("EXTRACT(HOUR FROM ?)", s.inserted_at),
          date: fragment("?::date::timestamp", s.inserted_at),
          day_hour_date_count: fragment("?::float", count(s.id))
        }

    Repo.all(
      from s in subquery(grouped_by_day_hour_date_query),
        group_by: [s.day, s.hour],
        order_by: [s.day, s.hour],
        select: [s.day, s.hour, avg(s.day_hour_date_count)]
    )
  end

  def average_wait_time_per_date(waitlist_id) do
    db_result =
      Repo.all(
        from s in StandBy,
          where:
            not is_nil(s.notified_at) and
              s.waitlist_id == ^waitlist_id,
          # Use a fragment to write some raw sql to convert timestamp to date.
          group_by: fragment("?::date::timestamp", s.inserted_at),
          select: [
            fragment("?::date::timestamp", s.inserted_at),
            avg(s.notified_at - s.inserted_at)
          ]
      )

    handle_average = fn db_result ->
      case db_result do
        %Postgrex.Interval{days: _d, months: _m, secs: seconds} -> round(seconds / 60)
        _ -> 0
      end
    end

    Enum.map(db_result, fn [date, average] -> [date, handle_average.(average)] end)
  end
end