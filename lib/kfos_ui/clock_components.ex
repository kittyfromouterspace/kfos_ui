defmodule KfosUi.ClockComponents do
  @moduledoc "Live client-side clock components."

  use Phoenix.Component

  attr :id, :string, required: true
  attr :label, :string, default: "LOCAL TIME"
  attr :timezone, :string, default: "Europe/Lisbon"
  attr :class, :string, default: nil

  def local_clock(assigns) do
    ~H"""
    <div
      id={@id}
      class={["overview-clock", @class]}
      data-timezone={@timezone}
      phx-hook=".LocalClock"
      phx-update="ignore"
    >
      <span>{@label}</span>
      <strong aria-live="off"><time datetime="">--:--</time></strong>
    </div>
    <script :type={Phoenix.LiveView.ColocatedHook} name=".LocalClock">
      export default {
        mounted() {
          this.formatter = new Intl.DateTimeFormat("en-GB", {
            hour: "2-digit",
            minute: "2-digit",
            hour12: false,
            timeZone: this.el.dataset.timezone
          })
          this.updateClock()
          this.timer = window.setInterval(() => this.updateClock(), 1000)
        },

        destroyed() {
          window.clearInterval(this.timer)
        },

        updateClock() {
          const now = new Date()
          const time = this.el.querySelector("time")
          time.textContent = this.formatter.format(now)
          time.dateTime = now.toISOString()
        }
      }
    </script>
    """
  end
end
