import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["content", "preview"]

  insertVariable(e) {
    const variable = e.currentTarget.dataset.variable
    const textarea = this.contentTarget
    const pos = textarea.selectionStart
    const text = textarea.value
    textarea.value = text.slice(0, pos) + variable + text.slice(pos)
    textarea.focus()
    textarea.selectionStart = textarea.selectionEnd = pos + variable.length
    this.updatePreview()
  }

  insertSnippet(e) {
    const content = e.currentTarget.dataset.content
    const textarea = this.contentTarget
    const pos = textarea.selectionStart
    const text = textarea.value
    textarea.value = text.slice(0, pos) + content + text.slice(pos)
    textarea.focus()
    this.updatePreview()
  }

  updatePreview() {
    if (!this.hasPreviewTarget) return
    let text = this.contentTarget.value
    const assessment = this.element.dataset
    const vars = {
      "{{nome_paciente}}": assessment.patientName || "[Paciente]",
      "{{idade}}": assessment.patientAge || "[Idade]",
      "{{data_nascimento}}": assessment.patientBirthDate || "[Data]",
      "{{titulo_avaliacao}}": assessment.title || "[Título]"
    }
    Object.entries(vars).forEach(([key, val]) => {
      text = text.replaceAll(key, val)
    })
    this.previewTarget.innerHTML = text.replace(/\n/g, "<br>")
  }
}
