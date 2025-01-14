defmodule LucumaWeb.Features.StandByTest do
  use Lucuma.FeatureCase, async: false

  import Lucuma.Factory
  import Wallaby.Query

  describe "notifying a stand by" do
    test "redirects to the waitlist in the business", %{session: session} do
      company = insert(:company)
      business = insert(:business, company: company)
      user = insert(:user, company: company)
      user_business = insert(:user_business, user_id: user.id, business_id: business.id)
      waitlist = insert(:waitlist, business: business)
      insert(:confirmation_sms_setting, waitlist: waitlist)
      insert(:attendance_sms_setting, waitlist: waitlist)
      stand_by = insert(:stand_by, waitlist: waitlist)

      page =
        session
        |> visit("/")
        |> click(link("Sign In"))
        |> fill_in(text_field("Email"), with: user.email)
        |> fill_in(text_field("Password"), with: "123123123")
        |> find(button("Sign In"), &assert(has_text?(&1, "Sign In")))
        |> click(button("Sign In"))
        |> click(link("Waitlisting"))
        |> click(link(waitlist.name))

      assert_has(page, link("Notify"))
      assert_has(page, link("No Show"))
      assert_has(page, link("Arrive"))
      assert_text(page, stand_by.name)

      page
      |> click(link("Notify"))
      |> assert_has(link("Notify Again"))
    end
  end

  describe "marking a stand by as arrived" do
    test "redirects to the waitlist in the business", %{session: session} do
      company = insert(:company)
      business = insert(:business, company: company)
      user = insert(:user, company: company)
      user_business = insert(:user_business, user_id: user.id, business_id: business.id)
      waitlist = insert(:waitlist, business: business)
      insert(:confirmation_sms_setting, waitlist: waitlist)
      insert(:attendance_sms_setting, waitlist: waitlist)
      stand_by = insert(:stand_by, waitlist: waitlist)

      page =
        session
        |> visit("/")
        |> click(link("Sign In"))
        |> fill_in(text_field("Email"), with: user.email)
        |> fill_in(text_field("Password"), with: "123123123")
        |> find(button("Sign In"), &assert(has_text?(&1, "Sign In")))
        |> click(button("Sign In"))
        |> click(link("Waitlisting"))
        |> click(link(waitlist.name))

      assert_has(page, link("Notify"))
      assert_has(page, link("No Show"))
      assert_has(page, link("Arrive"))
      assert_text(page, stand_by.name)

      refute(
        page
        |> click(link("Arrive"))
        |> has_text?(stand_by.name)
      )
    end
  end

  describe "marking a stand by as no show" do
    test "redirects to the waitlist in the business", %{session: session} do
      company = insert(:company)
      business = insert(:business, company: company)
      user = insert(:user, company: company)
      user_business = insert(:user_business, user_id: user.id, business_id: business.id)
      waitlist = insert(:waitlist, business: business)
      insert(:confirmation_sms_setting, waitlist: waitlist)
      insert(:attendance_sms_setting, waitlist: waitlist)
      stand_by = insert(:stand_by, waitlist: waitlist)

      page =
        session
        |> visit("/")
        |> click(link("Sign In"))
        |> fill_in(text_field("Email"), with: user.email)
        |> fill_in(text_field("Password"), with: "123123123")
        |> find(button("Sign In"), &assert(has_text?(&1, "Sign In")))
        |> click(button("Sign In"))
        |> click(link("Waitlisting"))
        |> click(link(waitlist.name))

      assert_has(page, link("Notify"))
      assert_has(page, link("No Show"))
      assert_has(page, link("Arrive"))
      assert_text(page, stand_by.name)

      refute(
        page
        |> click(link("No Show"))
        |> has_text?(stand_by.name)
      )
    end
  end

  describe "adding a stand by to a waitlist" do
    test "redirects to the waitlist view successfully", %{session: session} do
      company = insert(:company)
      business = insert(:business, company: company)
      user = insert(:user, company: company)
      user_business = insert(:user_business, user_id: user.id, business_id: business.id)
      waitlist = insert(:waitlist, business: business)
      insert(:confirmation_sms_setting, waitlist: waitlist)
      insert(:attendance_sms_setting, waitlist: waitlist)

      page =
        session
        |> visit("/")
        |> click(link("Sign In"))
        |> fill_in(text_field("Email"), with: user.email)
        |> fill_in(text_field("Password"), with: "123123123")
        |> find(button("Sign In"), &assert(has_text?(&1, "Sign In")))
        |> click(button("Sign In"))

      assert_text(page, "Today")

      page =
        page
        |> click(link("Waitlisting"))
        |> click(link(waitlist.name))
        |> find(button("Add Person"), &assert(has_text?(&1, "Add Person")))
        |> click(button("Add Person"))
        |> fill_in(text_field("Name"), with: "name")
        |> fill_in(text_field("Contact phone number"), with: "+353851761516")
        |> fill_in(text_field("Party size"), with: "2")
        |> fill_in(text_field("Estimated wait time"), with: "12")
        |> fill_in(text_field("Notes"), with: "a note")
        |> click(css(".btn.btn-primary", text: "Add"))

      assert_text(page, "+353851761516")
      assert_has(page, link("Notify"))
      assert_has(page, link("No Show"))
      assert_has(page, link("Arrive"))

      # 2 because of the main navbar and the sub nav bar
      [nav_link, sub_nav_link] = find(page, css(".nav-link.active", count: 2))

      assert_text(nav_link, "Waitlist")
      assert_text(sub_nav_link, "Waitlist")
    end
  end
end
