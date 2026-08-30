const LocalClock = {
  mounted() {
    this.formatter = new Intl.DateTimeFormat("en-GB", {
      hour: "2-digit",
      minute: "2-digit",
      hour12: false,
      timeZone: this.el.dataset.timezone,
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
  },
}

export const hooks = {
  LocalClock,
}
