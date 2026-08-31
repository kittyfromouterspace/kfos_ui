defmodule KfosUi.LayoutComponents do
  @moduledoc "Shared layout primitives for KFOS Phoenix shells."

  use Phoenix.Component

  import KfosUi.CoreComponents, only: [flash: 1, hide: 1, icon: 1, show: 1]

  alias Phoenix.LiveView.JS

  attr(:id, :string, required: true)
  attr(:main_id, :string, required: true)
  attr(:sidebar_id, :string, default: nil)
  attr(:mobile_title, :string, required: true)
  attr(:main_class, :any, default: "kfos-shell-main flex-1 p-4 lg:p-6 overflow-auto")

  attr(:sidebar_class, :any,
    default: "kfos-shell-sidebar cyber-sidebar min-h-full w-64 flex flex-col"
  )

  slot(:sidebar_header, required: true)
  slot(:sidebar_nav, required: true)
  slot(:sidebar_footer, required: true)
  slot(:mobile_actions)
  slot(:inner_block, required: true)

  def app_shell(assigns) do
    assigns = assign(assigns, :toggle_id, "#{assigns.id}-nav-toggle")

    ~H"""
    <div id={@id} class="kfos-shell drawer lg:drawer-open">
      <input id={@toggle_id} type="checkbox" class="drawer-toggle" />
      <div class="kfos-shell-content drawer-content flex flex-col">
        <header class="kfos-mobile-header navbar lg:hidden">
          <div class="flex-none">
            <label
              for={@toggle_id}
              class="btn btn-square btn-ghost text-primary"
              aria-label="Open navigation"
            >
              <.icon name="hero-bars-3" class="size-5" />
            </label>
          </div>
          <div class="min-w-0 flex-1">
            <span class="block truncate text-sm font-bold uppercase glow-cyan">{@mobile_title}</span>
          </div>
          <div :if={@mobile_actions != []} class="flex-none">
            {render_slot(@mobile_actions)}
          </div>
        </header>

        <main id={@main_id} class={@main_class}>{render_slot(@inner_block)}</main>
      </div>

      <div class="drawer-side z-40">
        <label for={@toggle_id} aria-label="Close navigation" class="drawer-overlay"></label>
        <aside id={@sidebar_id} class={@sidebar_class}>
          {render_slot(@sidebar_header)}
          {render_slot(@sidebar_nav)}
          {render_slot(@sidebar_footer)}
        </aside>
      </div>
    </div>
    """
  end

  attr(:href, :any, default: nil)
  attr(:external, :boolean, default: false)
  attr(:icon, :string, default: "hero-shield-check-solid")
  attr(:image_src, :string, default: nil)
  attr(:mark, :string, default: nil)
  attr(:title, :string, required: true)
  attr(:accent, :string, default: nil)
  attr(:subtitle, :string, default: nil)
  attr(:status, :boolean, default: true)
  attr(:class, :any, default: "kfos-app-header")
  attr(:body_class, :any, default: "kfos-app-header-body")
  attr(:rest, :global)

  def app_header(assigns) do
    ~H"""
    <%= cond do %>
      <% @href && @external -> %>
        <a href={@href} class={@class} {@rest}>
          <.app_header_body
            icon={@icon}
            image_src={@image_src}
            mark={@mark}
            title={@title}
            accent={@accent}
            subtitle={@subtitle}
            status={@status}
            class={@body_class}
          />
        </a>
      <% @href -> %>
        <.link navigate={@href} class={@class} {@rest}>
          <.app_header_body
            icon={@icon}
            image_src={@image_src}
            mark={@mark}
            title={@title}
            accent={@accent}
            subtitle={@subtitle}
            status={@status}
            class={@body_class}
          />
        </.link>
      <% true -> %>
        <div class={@class} {@rest}>
          <.app_header_body
            icon={@icon}
            image_src={@image_src}
            mark={@mark}
            title={@title}
            accent={@accent}
            subtitle={@subtitle}
            status={@status}
            class={@body_class}
          />
        </div>
    <% end %>
    """
  end

  attr(:icon, :string, required: true)
  attr(:image_src, :string, default: nil)
  attr(:mark, :string, default: nil)
  attr(:title, :string, required: true)
  attr(:accent, :string, default: nil)
  attr(:subtitle, :string, default: nil)
  attr(:status, :boolean, default: true)
  attr(:class, :any, required: true)

  defp app_header_body(assigns) do
    ~H"""
    <div class={@class}>
      <div class="kfos-app-header-mark-wrap">
        <span class="kfos-app-header-mark">
          <img :if={@image_src} src={@image_src} alt="" />
          <span :if={!@image_src && @mark}>{@mark}</span>
          <.icon :if={!@image_src && !@mark} name={@icon} class="size-7" />
        </span>
        <span :if={@status} class="cyber-status-dot online kfos-app-header-status"></span>
      </div>
      <div class="kfos-app-header-copy">
        <div class="kfos-app-header-title glow-cyan">
          {@title}<span :if={@accent}>{@accent}</span>
        </div>
        <div :if={@subtitle} class="kfos-app-header-subtitle">
          {@subtitle}
        </div>
      </div>
    </div>
    """
  end

  attr(:href, :string, required: true)
  attr(:icon, :string, required: true)
  attr(:label, :string, required: true)
  attr(:active, :boolean, default: false)
  attr(:meta, :string, default: nil)
  attr(:external, :boolean, default: false)
  attr(:class, :any, default: "kfos-nav-item")
  attr(:rest, :global)

  def nav_item(assigns) do
    ~H"""
    <%= if @external do %>
      <a href={@href} class={[@class, @active && "is-active"]} aria-current={@active && "page"} {@rest}>
        <.icon name={@icon} class="size-4" />
        <span>{@label}</span>
        <small :if={@meta}>{@meta}</small>
      </a>
    <% else %>
      <.link navigate={@href} class={[@class, @active && "is-active"]} aria-current={@active && "page"} {@rest}>
        <.icon name={@icon} class="size-4" />
        <span>{@label}</span>
        <small :if={@meta}>{@meta}</small>
      </.link>
    <% end %>
    """
  end

  attr(:label, :string, required: true)
  attr(:class, :any, default: "kfos-nav-label")

  def nav_label(assigns) do
    ~H"""
    <div class={@class}>
      <span>{@label}</span>
    </div>
    """
  end

  attr(:class, :any, default: "kfos-theme-toggle")

  def theme_toggle(assigns) do
    ~H"""
    <div class={@class} role="group" aria-label="Color theme">
      <div class="kfos-theme-readout" aria-hidden="true">
        <span><i></i>DISPLAY MATRIX</span>
        <span class="kfos-theme-current">
          <span class="kfos-theme-mode-system">SYS</span>
          <span class="kfos-theme-mode-light">LUX</span>
          <span class="kfos-theme-mode-dark">NITE</span>
        </span>
      </div>

      <div class="kfos-theme-track">
        <div class="kfos-theme-indicator" aria-hidden="true" />

        <button
          class="kfos-theme-button"
          phx-click={JS.dispatch("phx:set-theme")}
          data-phx-theme="system"
          title="Use system theme"
          aria-label="Use system theme"
        >
          <.icon name="hero-computer-desktop-micro" class="size-4" />
          <span>SYS</span>
        </button>

        <button
          class="kfos-theme-button"
          phx-click={JS.dispatch("phx:set-theme")}
          data-phx-theme="light"
          title="Use light theme"
          aria-label="Use light theme"
        >
          <.icon name="hero-sun-micro" class="size-4" />
          <span>LUX</span>
        </button>

        <button
          class="kfos-theme-button"
          phx-click={JS.dispatch("phx:set-theme")}
          data-phx-theme="dark"
          title="Use dark theme"
          aria-label="Use dark theme"
        >
          <.icon name="hero-moon-micro" class="size-4" />
          <span>NITE</span>
        </button>
      </div>
    </div>
    """
  end

  attr(:initials, :string, required: true)
  attr(:label, :string, required: true)
  attr(:detail, :string, required: true)
  attr(:action_href, :string, required: true)
  attr(:action_label, :string, required: true)
  attr(:action_icon, :string, required: true)
  attr(:action_method, :string, default: nil)
  attr(:class, :any, default: nil)

  def account_menu(assigns) do
    ~H"""
    <div class={["kfos-account-menu", @class]}>
      <span class="kfos-account-avatar" title={@label}>{@initials}</span>
      <div class="kfos-account-copy">
        <strong>{@label}</strong>
        <small>{@detail}</small>
      </div>
      <.link
        href={@action_href}
        method={@action_method}
        class="kfos-account-action"
        title={@action_label}
        aria-label={@action_label}
      >
        <.icon name={@action_icon} class="size-4" />
      </.link>
    </div>
    """
  end

  attr(:flash, :map, required: true, doc: "the map of flash messages")
  attr(:id, :string, default: "flash-group", doc: "the optional id of flash container")
  attr(:client_title, :string, default: "SIGNAL LOST")
  attr(:server_title, :string, default: "SYSTEM MALFUNCTION")
  attr(:reconnect_text, :string, default: "Reestablishing uplink...")

  def flash_group(assigns) do
    ~H"""
    <div id={@id} aria-live="polite">
      <.flash kind={:info} flash={@flash} />
      <.flash kind={:error} flash={@flash} />

      <.flash
        id="client-error"
        kind={:error}
        title={@client_title}
        phx-disconnected={show(".phx-client-error #client-error") |> JS.remove_attribute("hidden")}
        phx-connected={hide("#client-error") |> JS.set_attribute({"hidden", ""})}
        hidden
      >
        {@reconnect_text}
        <.icon name="hero-arrow-path" class="ml-1 size-3 motion-safe:animate-spin" />
      </.flash>

      <.flash
        id="server-error"
        kind={:error}
        title={@server_title}
        phx-disconnected={show(".phx-server-error #server-error") |> JS.remove_attribute("hidden")}
        phx-connected={hide("#server-error") |> JS.set_attribute({"hidden", ""})}
        hidden
      >
        {@reconnect_text}
        <.icon name="hero-arrow-path" class="ml-1 size-3 motion-safe:animate-spin" />
      </.flash>
    </div>
    """
  end
end
