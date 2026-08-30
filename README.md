# KFOS UI

Shared Phoenix LiveView components and cyberdeck design tokens for KFOS apps.

## Install

```elixir
{:kfos_ui, path: "../kfos_ui"}
```

In `assets/css/app.css`:

```css
@source "../../deps/kfos_ui/lib";
@import "../../deps/kfos_ui/priv/css/kfos_ui.css";
```

Keep the application-local daisyUI plugin paths in each app. The shared CSS owns
the reusable HUD classes and token behavior; each app owns its resolved
`@plugin ...daisyui-theme` declarations.
