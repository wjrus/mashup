import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["addButton", "container", "status", "template"]
  static values = { itemName: String }

  add() {
    const key = `${Date.now()}-${Math.random().toString(36).slice(2)}`
    const fields = this.templateTarget.innerHTML.replaceAll("NEW_RECORD", key)
    this.containerTarget.insertAdjacentHTML("beforeend", fields)
    const row = this.containerTarget.lastElementChild

    this.announce(`${this.itemLabel} added.`)
    row?.querySelector("input:not([type='hidden']), select, textarea, button")?.focus()
  }

  remove(event) {
    const row = event.target.closest("[data-nested-form-row]")
    const rows = this.containerTarget.querySelectorAll("[data-nested-form-row]:not([hidden])")
    const index = Array.from(rows).indexOf(row)
    const focusTarget = rows[index + 1]?.querySelector("button[data-action~='nested-form#remove']") ||
      rows[index - 1]?.querySelector("button[data-action~='nested-form#remove']") ||
      this.addButtonTarget

    if (row.dataset.newRecord === "true") {
      row.remove()
    } else {
      row.querySelector("[data-destroy-field]").value = "1"
      row.hidden = true
    }

    this.announce(`${this.itemLabel} removed.`)
    focusTarget.focus()
  }

  announce(message) {
    this.statusTarget.textContent = ""
    requestAnimationFrame(() => {
      this.statusTarget.textContent = message
    })
  }

  get itemLabel() {
    return this.itemNameValue || "Item"
  }
}
