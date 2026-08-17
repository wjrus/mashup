import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["container", "template"]

  add() {
    const key = `${Date.now()}-${Math.random().toString(36).slice(2)}`
    const fields = this.templateTarget.innerHTML.replaceAll("NEW_RECORD", key)
    this.containerTarget.insertAdjacentHTML("beforeend", fields)
  }

  remove(event) {
    const row = event.target.closest("[data-nested-form-row]")

    if (row.dataset.newRecord === "true") {
      row.remove()
    } else {
      row.querySelector("[data-destroy-field]").value = "1"
      row.hidden = true
    }
  }
}
