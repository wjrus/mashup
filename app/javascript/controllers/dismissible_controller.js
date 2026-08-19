import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["progress"]
  static values = { duration: { type: Number, default: 10000 } }

  connect() {
    this.startedAt = performance.now()
    this.animationFrame = requestAnimationFrame(this.tick.bind(this))
  }

  disconnect() {
    cancelAnimationFrame(this.animationFrame)
  }

  dismiss() {
    this.element.remove()
  }

  tick(now) {
    const remaining = Math.max(0, 1 - (now - this.startedAt) / this.durationValue)
    this.progressTarget.style.transform = `scaleX(${remaining})`

    if (remaining <= 0) {
      this.dismiss()
      return
    }

    this.animationFrame = requestAnimationFrame(this.tick.bind(this))
  }
}
