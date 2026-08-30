const storageKey = "phx:theme"

const applyTheme = (theme) => {
  if (theme === "system") {
    window.localStorage.removeItem(storageKey)
    document.documentElement.removeAttribute("data-theme")
    document.documentElement.setAttribute("data-theme-source", "system")
    return
  }

  window.localStorage.setItem(storageKey, theme)
  document.documentElement.setAttribute("data-theme", theme)
  document.documentElement.setAttribute("data-theme-source", theme)
}

export const initTheme = (defaultTheme = "system") => {
  if (!document.documentElement.hasAttribute("data-theme")) {
    applyTheme(window.localStorage.getItem(storageKey) || defaultTheme)
  } else {
    document.documentElement.setAttribute(
      "data-theme-source",
      document.documentElement.getAttribute("data-theme")
    )
  }

  window.addEventListener("storage", (event) => {
    if (event.key === storageKey) applyTheme(event.newValue || defaultTheme)
  })

  window.addEventListener("phx:set-theme", (event) => {
    applyTheme(event.target.dataset.phxTheme)
  })
}
