import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input", "display"]

  connect() {
    this.updateDisplay()
  }

  increment() {
    const current = parseInt(this.inputTarget.value) || 1
    this.inputTarget.value = current + 1
    this.updateDisplay()
  }

  decrement() {
    const current = parseInt(this.inputTarget.value) || 1
    if (current > 1) {
      this.inputTarget.value = current - 1
      this.updateDisplay()
    }
  }

  updateDisplay() {
    if (this.hasDisplayTarget) {
      this.displayTarget.textContent = this.inputTarget.value
    }
  }
}
