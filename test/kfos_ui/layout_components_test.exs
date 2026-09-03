defmodule KfosUi.LayoutComponentsTest do
  use ExUnit.Case, async: true

  import Phoenix.LiveViewTest

  alias KfosUi.CyberComponents
  alias KfosUi.LayoutComponents

  test "app_shell renders stable shell, navigation, and main content ids" do
    html =
      render_component(&LayoutComponents.app_shell/1,
        id: "test-shell",
        main_id: "test-main",
        sidebar_id: "test-sidebar",
        mobile_title: "TEST//APP",
        sidebar_header: [%{inner_block: fn _, _ -> "Header" end}],
        sidebar_nav: [%{inner_block: fn _, _ -> "Navigation" end}],
        sidebar_footer: [%{inner_block: fn _, _ -> "Footer" end}],
        inner_block: [%{inner_block: fn _, _ -> "Content" end}]
      )

    assert html =~ ~s(id="test-shell")
    assert html =~ ~s(id="test-shell-nav-toggle")
    assert html =~ ~s(id="test-main")
    assert html =~ ~s(id="test-sidebar")
    assert html =~ "TEST//APP"
    assert html =~ "Navigation"
    assert html =~ "Content"
    assert html =~ ~s(aria-hidden="true" class="drawer-overlay")
    refute html =~ ~s(aria-label="Close navigation")
  end

  test "theme_toggle exposes system, light, and dark choices" do
    html = render_component(&LayoutComponents.theme_toggle/1, %{})

    assert html =~ ~s(data-phx-theme="system")
    assert html =~ ~s(data-phx-theme="light")
    assert html =~ ~s(data-phx-theme="dark")
  end

  test "account_menu renders identity and session action" do
    html =
      render_component(&LayoutComponents.account_menu/1,
        initials: "OP",
        label: "operator@kfos.nz",
        detail: "admin",
        action_href: "/logout",
        action_label: "Sign out",
        action_icon: "hero-arrow-right-start-on-rectangle",
        action_method: "delete"
      )

    assert html =~ "operator@kfos.nz"
    assert html =~ "admin"
    assert html =~ ~s(href="/logout")
    assert html =~ ~s(aria-label="Sign out")
    assert html =~ "kfos-account-menu"
  end

  test "summary_metric renders semantic metric content" do
    html =
      render_component(&CyberComponents.summary_metric/1,
        id: "queue-depth",
        icon: "hero-queue-list",
        tone: "amber",
        label: "Queue depth",
        value: 12,
        detail: "3 currently running"
      )

    assert html =~ ~s(id="queue-depth")
    assert html =~ "kfos-summary-metric"
    assert html =~ "is-amber"
    assert html =~ "Queue depth"
    assert html =~ "3 currently running"
  end
end
