import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["dialog", "title", "message", "confirmButton"]

  connect() {
    this.approved = new WeakSet()
    this.interceptClick = this.interceptClick.bind(this)
    this.interceptSubmit = this.interceptSubmit.bind(this)
    this.element.addEventListener("click", this.interceptClick, true)
    this.element.addEventListener("submit", this.interceptSubmit, true)
  }

  disconnect() {
    this.element.removeEventListener("click", this.interceptClick, true)
    this.element.removeEventListener("submit", this.interceptSubmit, true)
  }

  interceptClick(event) {
    if (this.dialogTarget.contains(event.target)) return

    const action = event.target.closest("a, button, input[type='submit']")
    if (!action || this.approved.has(action)) {
      if (action) this.approved.delete(action)
      return
    }

    const confirmation = action.closest("[data-confirm-message]")
    if (!confirmation) return
    if (confirmation.matches("form") && !this.submitsForm(action)) return
    if (!this.shouldConfirm(confirmation)) return

    event.preventDefault()
    event.stopImmediatePropagation()
    this.open(confirmation, action)
  }

  interceptSubmit(event) {
    const form = event.target
    if (this.approved.has(form)) {
      this.approved.delete(form)
      return
    }

    const confirmation = form.matches("[data-confirm-message]") ? form : event.submitter?.closest("[data-confirm-message]")
    if (!confirmation || !this.shouldConfirm(confirmation)) return

    event.preventDefault()
    event.stopImmediatePropagation()
    this.open(confirmation, event.submitter || form)
  }

  open(confirmation, action) {
    this.pendingAction = action
    this.pendingConfirmation = confirmation
    this.titleTarget.textContent = confirmation.dataset.confirmTitle || "Please confirm"
    this.messageTarget.textContent = confirmation.dataset.confirmMessage
    this.confirmButtonTarget.textContent = confirmation.dataset.confirmLabel || "Confirm"
    this.dialogTarget.showModal()
    this.confirmButtonTarget.focus()
  }

  confirm() {
    const action = this.pendingAction
    const confirmation = this.pendingConfirmation
    this.close()

    if (action.matches("form")) {
      this.approved.add(action)
      action.requestSubmit()
    } else if (this.submitsForm(action)) {
      this.approved.add(action.form)
      action.form.requestSubmit(action)
    } else {
      this.approved.add(action)
      action.click()
    }

    this.pendingAction = null
    this.pendingConfirmation = null
    confirmation?.focus?.()
  }

  cancel(event) {
    event?.preventDefault()
    this.close()
  }

  close() {
    if (this.dialogTarget.open) this.dialogTarget.close()
    this.pendingAction?.focus?.()
  }

  closeFromBackdrop(event) {
    if (event.target === this.dialogTarget) this.cancel(event)
  }

  shouldConfirm(element) {
    const fieldName = element.dataset.confirmWhenField
    if (!fieldName) return true

    const form = element.matches("form") ? element : element.form
    const field = form?.elements.namedItem(fieldName)
    return field?.value === element.dataset.confirmWhenValue
  }

  submitsForm(action) {
    return action.matches("button:not([type]), button[type='submit'], input[type='submit']") && action.form
  }
}
