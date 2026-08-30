defmodule KfosUi.LayoutComponentsTest do
  use ExUnit.Case, async: true

  import Phoenix.LiveViewTest

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
  end

  test "theme_toggle exposes system, light, and dark choices" do
    html = render_component(&LayoutComponents.theme_toggle/1, %{})

    assert html =~ ~s(data-phx-theme="system")
    assert html =~ ~s(data-phx-theme="light")
    assert html =~ ~s(data-phx-theme="dark")
  end
end
