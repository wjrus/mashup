import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["progress"]
  static values = { duration: { type: Number, default: 10000 } }

  connect() {
    this.autoDismissEnabled = this.hasProgressTarget && !window.matchMedia("(prefers-reduced-motion: reduce)").matches
    if (!this.autoDismissEnabled) return

    this.remainingMs = this.durationValue
    this.start()
  }

  disconnect() {
    cancelAnimationFrame(this.animationFrame)
  }

  dismiss() {
    this.element.remove()
  }

  pause() {
    if (!this.animationFrame) return

    this.remainingMs = Math.max(0, this.remainingMs - (performance.now() - this.startedAt))
    cancelAnimationFrame(this.animationFrame)
    this.animationFrame = null
  }

  resume(event) {
    if (!this.autoDismissEnabled || this.animationFrame || this.remainingMs <= 0) return
    if (event?.type === "focusout" && this.element.contains(event.relatedTarget)) return

    this.start()
  }

  start() {
    this.startedAt = performance.now()
    this.animationFrame = requestAnimationFrame(this.tick.bind(this))
  }

  tick(now) {
    const elapsed = now - this.startedAt
    const remaining = Math.max(0, (this.remainingMs - elapsed) / this.durationValue)
    this.progressTarget.style.transform = `scaleX(${remaining})`

    if (remaining <= 0) {
      this.animationFrame = null
      this.dismiss()
      return
    }

    this.animationFrame = requestAnimationFrame(this.tick.bind(this))
  }
}
