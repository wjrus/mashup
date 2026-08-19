import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  skip(event) {
    const target = document.querySelector(this.element.hash)
    if (!target) return

    event.preventDefault()
    target.focus()
    window.history.replaceState(null, "", this.element.hash)
  }
}
