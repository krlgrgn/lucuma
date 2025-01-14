defmodule LucumaWeb.Settings.BillingView do
  use LucumaWeb, :view

  def render("sub_navigation.html", assigns) do
    render(
      LucumaWeb.LayoutView,
      "sub_navigation.html",
      Map.put(assigns, :sub_nav_links, sub_nav_links(assigns))
    )
  end

  def sub_nav_links(assigns) do
    links = [
      %{
        path: Routes.settings_profile_path(assigns.conn, :show),
        text: gettext("Profile")
      }
    ]

    links =
      if LucumaWeb.Permissions.permitted_to?(
           assigns.conn,
           LucumaWeb.Settings.BillingController,
           :show
         ) do
        links ++
          [
            %{
              path: Routes.settings_billing_path(assigns.conn, :show),
              text: gettext("Billing")
            }
          ]
      else
        links
      end

    if LucumaWeb.Permissions.permitted_to?(
         assigns.conn,
         LucumaWeb.Settings.StaffController,
         :show
       ) do
      links ++
        [
          %{
            path: Routes.settings_staff_path(assigns.conn, :show),
            text: gettext("Staff")
          }
        ]
    else
      links
    end
  end

  def payment_plan_links(conn, nil) do
    %{
      pay_as_you_go: pay_as_you_go_link(conn),
      standard: standard_link(conn),
      unlimited: unlimited_link(conn)
    }
  end

  def payment_plan_links(conn, %Stripe.Subscription{} = subscription) do
    %{
      pay_as_you_go: pay_as_you_go_link(conn, subscription),
      standard: standard_link(conn, subscription),
      unlimited: unlimited_link(conn, subscription)
    }
  end

  def pay_as_you_go_link(conn) do
    generate_new_sub_link(conn, "plan_Eyp0J9dUxi2tWW")
  end

  def standard_link(conn) do
    generate_new_sub_link(conn, "plan_Eyox8DhvcBMAaS")
  end

  def unlimited_link(conn) do
    generate_new_sub_link(conn, "plan_F7YntQ0ELRD33U")
  end

  def generate_new_sub_link(conn, plan_id) do
    link(gettext("Choose plan"),
      to: Routes.billing_payment_plan_path(LucumaWeb.Endpoint, :edit, plan_id),
      class: "btn btn-primary pricing-action"
    )
  end

  def pay_as_you_go_link(conn, %Stripe.Subscription{} = subscription) do
    if conn.assigns.current_company.stripe_payment_plan_id == "plan_Eyp0J9dUxi2tWW" do
      generate_cancel_link(conn, "plan_Eyp0J9dUxi2tWW")
    else
      generate_upgrade_link(conn, "plan_Eyp0J9dUxi2tWW")
    end
  end

  def standard_link(conn, %Stripe.Subscription{} = subscription) do
    if conn.assigns.current_company.stripe_payment_plan_id == "plan_Eyox8DhvcBMAaS" do
      generate_cancel_link(conn, "plan_Eyox8DhvcBMAaS")
    else
      generate_upgrade_link(conn, "plan_Eyox8DhvcBMAaS")
    end
  end

  def unlimited_link(conn, %Stripe.Subscription{} = subscription) do
    if conn.assigns.current_company.stripe_payment_plan_id == "plan_F7YntQ0ELRD33U" do
      generate_cancel_link(conn, "plan_F7YntQ0ELRD33U")
    else
      generate_upgrade_link(conn, "plan_F7YntQ0ELRD33U")
    end
  end

  def generate_cancel_link(conn, plan_id) do
    link(gettext("Cancel"),
      to: Routes.billing_subscription_path(conn, :delete, plan_id),
      method: :delete,
      class: "btn btn-outline-dark pricing-action"
    )
  end

  def generate_upgrade_link(conn, plan_id) do
    link(gettext("Upgrade"),
      to: Routes.billing_subscription_path(LucumaWeb.Endpoint, :update, plan_id),
      class: "btn btn-primary pricing-action",
      method: :put,
      data: [confirm: "Are you sure?"]
    )
  end

  def format_due_date(unix_stamp) do
    {:ok, date_time} = DateTime.from_unix(unix_stamp)
    "#{date_time.day}-#{date_time.month}-#{date_time.year}"
  end
end
