import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["patron", "contact"]

  connect() {
    this.filterContacts()
  }

  filterContacts() {
    const patronId = this.patronTarget.value

    for (const option of this.contactTarget.options) {
      if (!option.value) continue

      const matches = option.dataset.patronId === patronId
      option.hidden = !matches
      option.disabled = !matches

      if (option.selected && !matches) this.contactTarget.value = ""
    }
  }
}
