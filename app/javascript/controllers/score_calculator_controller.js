import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["output"]

  connect() {
    this.calculate()
  }

  calculate() {
    const inputs = this.element.querySelectorAll("input[type='number']")
    const values = Array.from(inputs).map(i => parseFloat(i.value) || 0)
    const total = values.reduce((sum, v) => sum + v, 0)
    if (this.hasOutputTarget) {
      this.outputTarget.textContent = total
    }
  }
}
