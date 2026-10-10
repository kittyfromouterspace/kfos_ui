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

  test "summary_metric with navigate is a link tile, flagged when it needs attention" do
    html =
      render_component(&CyberComponents.summary_metric/1,
        id: "approvals",
        icon: "hero-hand-raised",
        tone: "amber",
        label: "Approvals",
        value: 2,
        detail: "2 ops actions",
        navigate: "/approvals",
        attention: true
      )

    assert html =~ ~s(<a)
    assert html =~ ~s(href="/approvals")
    assert html =~ "kfos-summary-metric is-link"
    assert html =~ "is-attention"
    assert html =~ ~s(aria-label="Approvals: 2 — 2 ops actions")
  end

  test "activity_feed renders kind chips, linked titles, details and times; empty state" do
    html =
      render_component(&CyberComponents.activity_feed/1,
        id: "feed",
        items: [
          %{
            kind: :code,
            title: "Fix pushed",
            href: "/runs/job_1",
            detail: "branch agent/1",
            time: "08:19"
          },
          %{kind: :sre, kind_label: "watch", title: "22 passes", time: "24h"}
        ]
      )

    assert html =~ "kfos-activity-item is-code"
    assert html =~ ~s(href="/runs/job_1")
    assert html =~ "branch agent/1"
    assert html =~ "watch"
    assert html =~ "08:19"

    empty = render_component(&CyberComponents.activity_feed/1, items: [], empty: "Quiet day.")
    assert empty =~ "Quiet day."
  end
end
