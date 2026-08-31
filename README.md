# KFOS UI

Shared Phoenix LiveView components and cyberdeck design tokens for ops_center, home, and kfos_agent.

KFOS UI provides reusable Phoenix components, cyberdeck visual tokens, application shell primitives, theme switching, and LiveView hooks. It is domain-neutral: data fetching, routes, events, and business logic remain in the consuming application.

## Design Direction

KFOS UI is an operational interface for people who scan, compare, and act repeatedly.

- Use dense but breathable layouts with clear hierarchy.
- Prefer full-width bands and unframed work areas over nested decorative cards.
- Use sharp tactical corners and restrained neon accents.
- Reserve green for healthy, active, and primary application identity.
- Use cyan for navigation, links, telemetry, and secondary signals.
- Use amber for attention and pending states.
- Use magenta sparingly for identity accents.
- Use Phoenix icons through <.icon>; do not draw SVGs in templates.
- Give important controls and containers stable, unique DOM IDs.
- Keep text readable in both dark and light themes.
- Do not introduce an app-local third palette.

The coordinated schemes are:

- dark or cyberdeck: deep green-black operational surfaces with luminous text
- light: warm, high-contrast cyberpunk surfaces with green, cyan, amber, and magenta accents

## Installation

Use the public GitHub repository from each Phoenix application:

~~~elixir
defp deps do
  [
    {:kfos_ui, github: "kittyfromouterspace/kfos_ui"}
  ]
end
~~~

Fetch the dependency with:

~~~sh
mix deps.get
mix deps.update kfos_ui
~~~

The current projects consume the main branch. A production project may pin a commit until release tags are adopted.

## Phoenix Wiring

Import the modules in the application's html_helpers block:

~~~elixir
defp html_helpers do
  quote do
    import Phoenix.HTML
    import KfosUi.CoreComponents
    import KfosUi.CyberComponents
    import KfosUi.ClockComponents
    import KfosUi.LayoutComponents

    alias MyAppWeb.Layouts
  end
end
~~~

Only import ClockComponents when using local_clock. If a local component has the same name as a shared component, use an explicit except import or rename it. Do not maintain a fork of a shared primitive.

Every LiveView template must begin with the application's layout wrapper:

~~~heex
<Layouts.app flash={@flash} current_scope={@current_scope} active_nav={:overview}>
  ...
</Layouts.app>
~~~

The layout owns the shell, navigation, theme controls, and flash group. A LiveView owns page content only.

## CSS Setup

Add the shared source and stylesheet to assets/css/app.css. Keep the shared import after Tailwind and before application-specific overrides:

~~~css
@import "tailwindcss" source(none);
@source "../../deps/kfos_ui/lib";
@source "../css";
@source "../js";
@source "../../lib/my_app_web";
@import "../../deps/kfos_ui/priv/css/kfos_ui.css";
~~~

Keep the consuming application's Tailwind, Heroicons, and daisyUI component plugin declarations. Configure daisyUI with `themes: false`; KFOS UI owns the complete dark, light, and system token sets, including daisyUI's `--color-*`, radius, border, depth, and noise variables. Do not declare a daisyUI theme plugin in a consuming application.

Use Tailwind utilities for local layout and shared CSS classes for shared visual behavior. Never use @apply in raw CSS.

## JavaScript Setup

Merge the shared hooks into the application's LiveSocket hooks and initialize the theme before connecting:

~~~javascript
import {hooks as kfosUiHooks} from "../../deps/kfos_ui/priv/js/hooks"
import {initTheme} from "../../deps/kfos_ui/priv/js/theme"

initTheme("system")

let liveSocket = new LiveSocket("/live", Socket, {
  hooks: {...kfosUiHooks},
})
~~~

Use initTheme("dark") when an application must start dark. Theme preference is stored in localStorage under phx:theme and is changed by theme_toggle.

KFOS UI owns the shared `--cyber-*` and daisyUI `--color-*` palettes, including surface, panel, border, text, control, status, radius, and depth tokens. Consuming applications should use those tokens for local components instead of redefining them. The `system` theme follows `prefers-color-scheme`; explicit light and dark choices override it.

Do not add inline script tags to HEEx. Shared hooks are external JavaScript. Colocated hooks must use Phoenix LiveView's .HookName convention.

## Component Reference

### KfosUi.CoreComponents

Core Phoenix building blocks and the default choices for forms and generic data display.

- flash: info and error notices that clear on click
- button: a button or Phoenix navigation link
- input: regular inputs, checkboxes, selects, textareas, hidden values, labels, and errors
- header: a conventional local section heading with subtitle and actions slots
- table: generic tables, including LiveView stream support
- list: key/value-like lists
- icon: bundled Heroicons
- metric: compact shared metric format

Example:

~~~heex
<.form for={@form} id="project-form" phx-submit="save">
  <.input field={@form[:name]} label="Project name" />
  <.input field={@form[:environment]} type="select" options={@environments} />
  <.input field={@form[:enabled]} type="checkbox" label="Enabled" />
  <.button variant="primary">Save</.button>
</.form>

<.header>
  Resource allocation
  <:subtitle>Current capacity by host</:subtitle>
  <:actions><.button>Rebalance</.button></:actions>
</.header>
~~~

Use input for forms instead of raw inputs. When overriding class, provide complete input styling because custom classes replace defaults. Icon-only buttons need an aria-label and a tooltip or title when unfamiliar.

### KfosUi.CyberComponents

Cyberdeck primitives for operational pages.

#### page_header

page_header is the standard page-level header across all applications. It renders the green tactical title, // marker, subtitle, and HUD divider. Put page actions in the actions slot:

~~~heex
<.page_header
  id="mission-control-header"
  title="Mission Control"
  subtitle="Deployment posture and active operations"
>
  <:actions>
    <.button id="refresh-mission-control" phx-click="refresh">
      <.icon name="hero-arrow-path" class="size-4" />
      Refresh
    </.button>
  </:actions>
</.page_header>
~~~

Use this instead of a page-specific h1. Preserve the page ID for tests and browser tooling.

#### Status and data components

- status_badge status={@status}: semantic success, warning, error, info, or neutral badge
- metric_gauge label="CPU" value={@cpu_percent}: percentage gauge clamped to 0..100
- summary_metric: compact icon, value, and context for dashboard metric bands
- stat_card: compact summary value, not a whole page section
- dossier_card: repeated record with status, fields, actions, and optional inspection navigation
- log_viewer id="deployment-log" log={@deployment_log}: numbered, scrollable text
- health_grid checks={@checks}: compact check grid; each check has status and check_type
- action_button: simple event button; pushes %{id: value}
- tab_nav: peer views with active tab
- empty_state: missing data feed

Examples:

~~~heex
<.status_badge status={@server.status} />
<.metric_gauge label="CPU" value={@cpu_percent} />
<.stat_card title="Active runs" value={@active_runs} icon_name="hero-bolt" />
<.log_viewer id="deployment-log" log={@deployment_log} class="min-h-48" />

<.dossier_card
  title={@project.name}
  subtitle={@project.slug}
  status={@project.status}
  navigate={~p"/projects/#{@project.id}"}
>
  <:field label="Environment">{@project.environment}</:field>
  <:field label="Version">{@project.version}</:field>
</.dossier_card>

<.action_button
  label="Drain"
  event="drain_server"
  value={server.id}
  variant="warning"
  confirm="Drain this server?"
  icon_name="hero-pause"
/>
~~~

Use a regular button when an action payload differs from %{id: value}. Do not pass untrusted HTML to log_viewer.

### KfosUi.LayoutComponents

Shared application-shell primitives.

#### app_shell

Use `app_shell` as the responsive frame for every authenticated application. It owns the desktop drawer, mobile navigation trigger, sidebar placement, and main viewport while the application supplies domain-specific slots:

~~~heex
<.app_shell id="app-shell" main_id="app-main" mobile_title="OPS//CENTER">
  <:sidebar_header><.app_header title="OPS//CENTER" /></:sidebar_header>
  <:sidebar_nav><nav>...</nav></:sidebar_nav>
  <:sidebar_footer><.theme_toggle /></:sidebar_footer>
  <:mobile_actions><span class="cyber-status-dot online"></span></:mobile_actions>
  {render_slot(@inner_block)}
</.app_shell>
~~~

Keep navigation routes, authorization, counts, and application status data in the consuming layout. Do not fork the drawer or responsive header markup locally.

#### app_header

Use app_header in every application sidebar or compact mobile shell. It is the canonical HOME//CORE and MISSION CONTROL style header and uses the shared cyber-green identity color:

~~~heex
<.app_header
  href={~p"/"}
  mark="H"
  title="HOME//CORE"
  subtitle="Local command v0.1"
  aria-label="Home dashboard"
/>
~~~

Pass image_src for a product mark image. Omit href for a non-linked header. Use external={true} only for an external URL. Reserve accent for an intentional secondary identity fragment.

#### Navigation, account, theme, and flash

~~~heex
<.nav_label label="OPERATIONS" />
<.nav_item
  href={~p"/runs"}
  icon="hero-play"
  label="Runs"
  meta={@run_count}
  active={@active_nav == :runs}
/>
<.theme_toggle />
<.account_menu
  initials="OP"
  label="operator@kfos.nz"
  detail="admin"
  action_href="/logout"
  action_label="Sign out"
  action_icon="hero-arrow-right-start-on-rectangle"
  action_method="delete"
/>
<.flash_group flash={@flash} />
~~~

The active internal nav item receives aria-current="page". Every application sidebar must render one full-width shared theme toggle at the bottom of its navigation panel so theme behavior and presentation stay consistent across KFOS products. Place one flash group in the shell; do not call flash_group from individual LiveViews.

### KfosUi.ClockComponents

#### local_clock

local_clock is managed by the shared LocalClock hook and must have a unique ID. Its kfos-local-clock class provides the green/cyan cyberpunk readout. It uses phx-update="ignore" because the client owns the displayed time:

~~~heex
<.local_clock id="overview-local-clock" timezone="Europe/Lisbon" />
~~~

Do not update the clock's inner time element from a LiveView render.

## Shared CSS Classes and Tokens

The shared stylesheet is priv/css/kfos_ui.css.

| Class | Use |
| --- | --- |
| .cyber-card | Repeated framed operational item with corner brackets |
| .cyber-panel | Framed panel without repeated-item treatment |
| .cyber-grid-bg | Subtle tactical grid background |
| .hud-header | Inline heading with a shared // marker |
| .hud-divider | Horizontal HUD divider |
| .glow-cyan | Cyan text glow for telemetry and navigation |
| .box-glow-cyan | Cyan panel glow |
| .health-cell | Health grid cell base styling |
| .router-metric | Compact metric layout |
| .kfos-app-header | Shared application header container |
| .kfos-nav-item | Shared navigation item base |
| .kfos-page-header-title | Canonical green page title |

Main semantic tokens:

~~~css
var(--cyber-green)
var(--cyber-cyan)
var(--cyber-amber)
var(--cyber-magenta)
var(--cyber-red)
var(--cyber-bg)
var(--cyber-surface)
var(--cyber-text)
var(--cyber-muted)
~~~

Use cyber-green for application identity and healthy or active states. Use text-primary only when you explicitly want the consuming application's DaisyUI semantic color. Do not use text-primary for shared page headers because its hue differs between applications.

## Layout Rules

A normal operational screen looks like this:

~~~heex
<Layouts.app flash={@flash} current_scope={@current_scope} active_nav={:overview}>
  <.page_header id="page-header" title="Overview" subtitle="Current system posture" />

  <section id="overview-content" class="grid gap-4 lg:grid-cols-[minmax(0,1fr)_20rem]">
    <div class="cyber-panel p-4">...</div>
    <aside class="cyber-panel p-4">...</aside>
  </section>
</Layouts.app>
~~~

Rules for new pages:

1. Start with Layouts.app.
2. Use one page_header for the page title.
3. Put page-level actions in the actions slot.
4. Use semantic section, article, nav, and aside elements.
5. Give forms, tables, major sections, and action buttons unique IDs.
6. Keep repeated items in one grid or list; do not put cards inside cards.
7. Use LiveView streams for growing collections.
8. Prefix application-specific classes with the application name.

## Accessibility and Testing

- Every phx-hook element needs a unique ID and phx-update="ignore" when the hook owns its DOM.
- Every icon-only button needs an accessible name.
- Keep visible focus states.
- Do not communicate status by color alone; pair indicators with text or accessible metadata.
- Use aria-live only for content that should be announced.
- Keep controls usable on touch screens.

Test stable behavior through DOM IDs and semantic selectors rather than raw HTML snapshots:

~~~elixir
assert has_element?(view, "#overview-header")
assert has_element?(view, "#refresh-mission-control")
assert has_element?(view, "#deployment-log")
~~~

When changing a shared component, test required attributes, slots, emitted IDs, and focused LiveViews in consuming applications. Run:

~~~sh
mix format --check-formatted
mix compile --warnings-as-errors
mix test
mix assets.build
~~~

For an application integration pass, also run its mix precommit alias. For dependency changes in ops_center, run mix deps.audit.

## Adding or Changing Components

Add a component only when at least two applications need the same markup and behavior:

1. Search all three applications for existing implementations and naming.
2. Keep the API domain-neutral and document assigns and slots.
3. Add stable IDs to key interactive elements.
4. Put reusable visual rules in priv/css/kfos_ui.css.
5. Keep JavaScript in priv/js/ and export hooks through hooks.js.
6. Update this README with an example and migration guidance.
7. Update all consuming applications to the new GitHub revision.
8. Run formatting, compilation, tests, asset builds, and dependency audit.

Do not add Ash, Ecto, application contexts, product routes, or business logic. A shared component may accept data and emit events, but it must not know which application owns those events.

## Repository Workflow

~~~sh
mix format
mix compile --warnings-as-errors
git add lib priv README.md
git commit -m "Describe the design-system change"
git push
~~~

Then, in each consuming application:

~~~sh
mix deps.update kfos_ui
mix compile --warnings-as-errors
mix assets.build
mix test
~~~

The pinned decimal advisory is an ecosystem constraint documented by ops_center; do not remove its suppression until Ecto and Ash support decimal ~> 3.0.

## Source Map

| Path | Responsibility |
| --- | --- |
| lib/kfos_ui/core_components.ex | Forms, links, tables, lists, icons, metrics, flash |
| lib/kfos_ui/cyber_components.ex | Cyberdeck status, gauges, cards, headers, tabs |
| lib/kfos_ui/layout_components.ex | App header, navigation, themes, flash group |
| lib/kfos_ui/clock_components.ex | Client-side local clock |
| priv/css/kfos_ui.css | Shared tokens and visual primitives |
| priv/js/theme.js | Theme persistence and switching |
| priv/js/hooks.js | Shared LiveView hooks |
