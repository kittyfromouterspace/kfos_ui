defmodule KfosUi.LayoutComponents do
  @moduledoc "Shared layout primitives for KFOS Phoenix shells."

  use Phoenix.Component

  import KfosUi.CoreComponents, only: [flash: 1, hide: 1, icon: 1, show: 1]

  alias Phoenix.LiveView.JS

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
    <div class={@class} aria-label="Color theme">
      <div class="kfos-theme-indicator" />

      <button
        class="kfos-theme-button"
        phx-click={JS.dispatch("phx:set-theme")}
        data-phx-theme="system"
        title="Use system theme"
        aria-label="Use system theme"
      >
        <.icon name="hero-computer-desktop-micro" class="size-4 opacity-75 hover:opacity-100" />
      </button>

      <button
        class="kfos-theme-button"
        phx-click={JS.dispatch("phx:set-theme")}
        data-phx-theme="light"
        title="Use light theme"
        aria-label="Use light theme"
      >
        <.icon name="hero-sun-micro" class="size-4 opacity-75 hover:opacity-100" />
      </button>

      <button
        class="kfos-theme-button"
        phx-click={JS.dispatch("phx:set-theme")}
        data-phx-theme="dark"
        title="Use dark theme"
        aria-label="Use dark theme"
      >
        <.icon name="hero-moon-micro" class="size-4 opacity-75 hover:opacity-100" />
      </button>
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
