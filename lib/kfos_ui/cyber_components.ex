defmodule KfosUi.CyberComponents do
  @moduledoc """
  Shared cyberdeck HUD components for the KFOS Phoenix applications.

  These are domain-neutral primitives extracted from ops_center, home, and
  kfos_agent. Pairs with `priv/css/kfos_ui.css`.

  Plain `Phoenix.Component` + daisyUI + heroicons — no Ash, no external coupling.
  """

  use Phoenix.Component

  import KfosUi.CoreComponents, only: [icon: 1]

  alias Phoenix.LiveView.JS

  # ── Status Badge ──────────────────────────────────────────────────────

  attr(:status, :atom, required: true)
  attr(:class, :string, default: nil)

  def status_badge(assigns) do
    ~H"""
    <span class={[
      "badge badge-sm font-medium",
      status_color(@status),
      @class
    ]}>
      <span class={[
        "inline-block w-1.5 h-1.5 rounded-full mr-1",
        status_dot_color(@status)
      ]} />
      {format_status(@status)}
    </span>
    """
  end

  defp status_color(status) do
    case status do
      s when s in [:online, :running, :passing, :completed, :ready, :deployed, :succeeded] ->
        "badge-success"

      s
      when s in [
             :warning,
             :deploying,
             :building,
             :starting,
             :replicating,
             :in_progress,
             :scheduled,
             :queued
           ] ->
        "badge-warning"

      s
      when s in [:offline, :stopped, :stopping, :error, :errored, :failed, :critical, :cancelled] ->
        "badge-error"

      s when s in [:draining, :maintenance, :pending, :archived, :rolled_back] ->
        "badge-info"

      _ ->
        "badge-ghost"
    end
  end

  defp status_dot_color(status) do
    case status do
      s when s in [:online, :running, :passing, :completed, :ready, :deployed, :succeeded] ->
        "bg-success animate-cyber-pulse"

      s
      when s in [
             :warning,
             :deploying,
             :building,
             :starting,
             :replicating,
             :in_progress,
             :scheduled,
             :queued
           ] ->
        "bg-warning animate-cyber-pulse"

      s
      when s in [:offline, :stopped, :stopping, :error, :errored, :failed, :critical, :cancelled] ->
        "bg-error"

      _ ->
        "bg-info"
    end
  end

  defp format_status(status) do
    status
    |> Atom.to_string()
    |> String.replace("_", " ")
    |> String.upcase()
  end

  # ── Metric Gauge ──────────────────────────────────────────────────────

  attr(:label, :string, required: true)
  attr(:value, :float, required: true)
  attr(:unit, :string, default: "%")

  def metric_gauge(assigns) do
    assigns = assign(assigns, :clamped, min(100, max(0, assigns.value)))
    assigns = assign(assigns, :color_class, gauge_color(assigns.clamped))

    ~H"""
    <div class="flex flex-col items-center gap-1">
      <div
        class={"radial-progress text-#{@color_class}"}
        style={"--value:#{round(@clamped)};--size:3.5rem;--thickness:3px"}
        role="progressbar"
      >
        <span class="text-xs font-bold">{round(@clamped)}{@unit}</span>
      </div>
      <span class="text-[0.65rem] tracking-wider text-base-content/60 uppercase">{@label}</span>
    </div>
    """
  end

  defp gauge_color(value) when value >= 90, do: "error"
  defp gauge_color(value) when value >= 70, do: "warning"
  defp gauge_color(_value), do: "success"

  # ── Log Viewer ────────────────────────────────────────────────────────

  attr(:id, :string, required: true)
  attr(:log, :string, default: "")
  attr(:class, :string, default: nil)

  def log_viewer(assigns) do
    ~H"""
    <div
      id={@id}
      class={[
        "overflow-auto max-h-96 p-4 text-xs",
        "border border-primary/15 bg-base-300/80",
        @class
      ]}
      style="border-radius: 2px;"
    >
      <pre :for={{line, idx} <- Enum.with_index(String.split(@log, "\n"))} class="leading-relaxed"><span class="text-primary/30 mr-3 select-none">{String.pad_leading("#{idx + 1}", 3, "0")}</span><code class="text-success/80">{line}</code></pre>
    </div>
    """
  end

  # ── Health Grid ───────────────────────────────────────────────────────

  attr(:checks, :list, required: true)
  attr(:class, :string, default: nil)

  def health_grid(assigns) do
    ~H"""
    <div class={["grid grid-cols-4 sm:grid-cols-6 md:grid-cols-8 gap-1", @class]}>
      <div
        :for={check <- @checks}
        class={[
          "health-cell tooltip cursor-pointer",
          health_color(check.status)
        ]}
        data-tip={check_tooltip(check)}
      />
    </div>
    """
  end

  defp health_color(:passing), do: "passing"
  defp health_color(:warning), do: "warning"
  defp health_color(:critical), do: "critical"
  defp health_color(_), do: ""

  defp check_tooltip(check) do
    "#{check.check_type |> to_string() |> String.upcase()} :: #{check.status |> to_string() |> String.upcase()}"
  end

  # ── Action Button ─────────────────────────────────────────────────────

  attr(:label, :string, required: true)
  attr(:event, :string, default: nil)
  attr(:value, :any, default: nil)
  attr(:size, :string, default: "sm")
  attr(:variant, :string, default: "soft")
  attr(:confirm, :string, default: nil)
  attr(:icon_name, :string, default: nil)
  attr(:class, :string, default: nil)

  def action_button(assigns) do
    ~H"""
    <button
      class={[
        "btn",
        "btn-#{@size}",
        variant_class(@variant),
        @class
      ]}
      phx-click={@event && action_click(@event, @value)}
      data-confirm={@confirm}
      disabled={is_nil(@event)}
    >
      <span :if={@icon_name} class={[@icon_name, "size-4"]} />
      {@label}
    </button>
    """
  end

  defp variant_class("primary"), do: "btn-primary"
  defp variant_class("ghost"), do: "btn-ghost"
  defp variant_class("warning"), do: "btn-warning"
  defp variant_class("error"), do: "btn-error"
  defp variant_class(_), do: "btn-primary btn-soft"

  defp action_click(event, value) do
    JS.push(event, value: %{id: value})
  end

  # ── Stat Card ─────────────────────────────────────────────────────────

  attr(:title, :string, required: true)
  attr(:value, :any, required: true)
  attr(:description, :string, default: nil)
  attr(:icon_name, :string, default: nil)

  def stat_card(assigns) do
    ~H"""
    <div class="stat">
      <div :if={@icon_name} class="stat-figure text-primary">
        <span class={[@icon_name, "size-8 opacity-60"]} />
      </div>
      <div class="stat-title">{@title}</div>
      <div class="stat-value text-primary">{@value}</div>
      <div :if={@description} class="stat-desc text-base-content/50">{@description}</div>
    </div>
    """
  end

  # ── Summary Metric ────────────────────────────────────────────────────

  attr(:id, :string, default: nil)
  attr(:icon, :string, required: true)
  attr(:tone, :string, required: true, values: ~w(cyan green amber magenta red))
  attr(:label, :string, required: true)
  attr(:value, :any, required: true)
  attr(:detail, :string, required: true)
  attr(:class, :any, default: nil)

  def summary_metric(assigns) do
    ~H"""
    <article id={@id} class={["kfos-summary-metric", @class]}>
      <span class={["kfos-summary-metric-icon", "is-#{@tone}"]}>
        <.icon name={@icon} class="size-5" />
      </span>
      <div>
        <small>{@label}</small>
        <strong>{@value}</strong>
        <span>{@detail}</span>
      </div>
    </article>
    """
  end

  # ── Empty State ───────────────────────────────────────────────────────

  attr(:message, :string, default: "NO DATA FEED")
  attr(:icon_name, :string, default: "hero-inbox")

  def empty_state(assigns) do
    ~H"""
    <div class="flex flex-col items-center justify-center py-12 text-base-content/30">
      <span class={[@icon_name, "size-12 mb-4"]} />
      <p class="text-sm tracking-widest uppercase">{@message}</p>
      <div class="hud-divider w-32 mt-4"></div>
    </div>
    """
  end

  # ── Page Header ───────────────────────────────────────────────────────

  attr(:title, :string, required: true)
  attr(:subtitle, :string, default: nil)
  attr(:id, :string, default: nil)
  attr(:rest, :global)
  slot(:actions)

  def page_header(assigns) do
    ~H"""
    <div id={@id} class="flex items-center justify-between mb-6" {@rest}>
      <div>
        <div class="flex items-center gap-2">
          <span class="kfos-page-header-marker text-sm font-bold">//</span>
          <h1 class="kfos-page-header-title text-xl font-bold tracking-wider">
            {String.upcase(@title)}
          </h1>
        </div>
        <p :if={@subtitle} class="text-xs tracking-wider text-base-content/40 uppercase mt-1 ml-6">
          {@subtitle}
        </p>
      </div>
      <div :if={@actions != []} class="flex gap-2">
        {render_slot(@actions)}
      </div>
    </div>
    <div class="kfos-page-header-divider hud-divider mb-6"></div>
    """
  end

  # ── Dossier Card (Mission Report Card) ─────────────────────────────────

  attr(:title, :string, required: true)
  attr(:subtitle, :string, default: nil)
  attr(:status, :atom, default: nil)
  attr(:navigate, :string, default: nil)
  attr(:class, :string, default: nil)

  slot :field do
    attr(:label, :string, required: true)
  end

  slot(:actions)

  def dossier_card(assigns) do
    ~H"""
    <div class={["cyber-card group", @class]}>
      <%!-- Header strip --%>
      <div class="flex items-center justify-between px-4 py-2 border-b border-primary/10 bg-primary/[0.03]">
        <.status_badge :if={@status} status={@status} />
        <div :if={@actions != []} class="flex gap-1">
          {render_slot(@actions)}
        </div>
        <span
          :if={@actions == [] && is_nil(@status)}
          class="text-[0.55rem] text-primary/20 tracking-widest"
        >
          DOSSIER
        </span>
      </div>

      <%!-- Title block --%>
      <div class="px-4 pt-3 pb-2">
        <h3 class="text-sm font-bold tracking-wider text-primary">{@title}</h3>
        <p :if={@subtitle} class="text-[0.6rem] tracking-wider text-base-content/40 uppercase mt-0.5">
          {@subtitle}
        </p>
      </div>

      <div class="hud-divider mx-4"></div>

      <%!-- Field grid --%>
      <div class="px-4 py-2 grid grid-cols-2 gap-x-4 gap-y-1.5">
        <div :for={field <- @field} class="flex flex-col">
          <span class="text-[0.55rem] tracking-widest text-secondary/60 uppercase">
            {field.label}
          </span>
          <span class="text-xs font-mono text-base-content/70 truncate">{render_slot(field)}</span>
        </div>
      </div>

      <%!-- Footer --%>
      <div :if={@navigate} class="px-4 py-2 border-t border-primary/8 flex justify-end">
        <.link
          navigate={@navigate}
          class="btn btn-xs btn-ghost text-primary/60 hover:text-primary tracking-widest text-[0.6rem] group-hover:text-primary"
        >
          INSPECT >>
        </.link>
      </div>
    </div>
    """
  end

  # ── Tab Navigation ────────────────────────────────────────────────────

  attr(:tabs, :list, required: true)
  attr(:active_tab, :atom, required: true)
  attr(:target, :any, default: nil)

  def tab_nav(assigns) do
    ~H"""
    <div role="tablist" class="tabs tabs-border mb-6">
      <button
        :for={{label, tab_id} <- @tabs}
        role="tab"
        class={["tab", @active_tab == tab_id && "tab-active"]}
        phx-click="change_tab"
        phx-value-tab={tab_id}
        phx-target={@target}
      >
        {label}
      </button>
    </div>
    """
  end
end
