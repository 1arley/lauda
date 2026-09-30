import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["container", "template"]

  add() {
    const fields = this.templateTarget.content.cloneNode(true)
    const index = this.containerTarget.querySelectorAll("[data-report-template-section]").length

    fields.querySelectorAll("[id]").forEach((element) => {
      element.id = element.id.replace("new", index)
    })
    fields.querySelectorAll("label[for]").forEach((label) => {
      label.htmlFor = label.htmlFor.replace("new", index)
    })

    this.containerTarget.append(fields)
  }
}
