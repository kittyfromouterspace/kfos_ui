defmodule KfosUi.ClockComponents do
  @moduledoc "Live client-side clock components."

  use Phoenix.Component

  attr(:id, :string, required: true)
  attr(:label, :string, default: "LOCAL TIME")
  attr(:timezone, :string, default: "Europe/Lisbon")
  attr(:class, :string, default: nil)

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
    """
  end
end
