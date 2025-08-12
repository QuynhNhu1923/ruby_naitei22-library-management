import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    "statusSelect",
    "adminNoteField",
    "actualReturnDateField",
    "errorMessage"
  ]

  connect() {
    this.toggleFields()
  }

  toggleFields() {
    const status = this.statusSelectTarget.value

    this.hideAll()

    if (status === "rejected") {
      this.show(this.adminNoteFieldTarget)
    } else if (status === "returned") {
      this.show(this.actualReturnDateFieldTarget)
    }
  }

  validateForm(event) {
    const status = this.statusSelectTarget.value

    // Trường hợp rejected -> bắt buộc admin_note
    if (status === "rejected") {
      const noteField = this.adminNoteFieldTarget.querySelector("textarea, input")
      if (!noteField || noteField.value.trim() === "") {
        this.showError("Please provide an admin note when rejecting")
        event.preventDefault()
        return
      }
    }

    // Trường hợp returned -> bắt buộc validate date
    if (status === "returned") {
      const dateField = this.actualReturnDateFieldTarget.querySelector("input")
      if (!dateField) return

      const selectedDate = new Date(dateField.value)
      const today = new Date()
      today.setHours(0, 0, 0, 0)

      if (isNaN(selectedDate.getTime())) {
        this.showError("Please select a valid date")
        event.preventDefault()
        return
      }

      if (selectedDate > today) {
        this.showError("Actual return date cannot be in the future")
        event.preventDefault()
        return
      }
    }

    this.clearError()
  }

  hideAll() {
    this.adminNoteFieldTarget.classList.add("d-none")
    this.actualReturnDateFieldTarget.classList.add("d-none")
    this.clearError()
  }

  show(element) {
    element.classList.remove("d-none")
  }

  showError(message) {
    this.errorMessageTarget.textContent = message
    this.errorMessageTarget.classList.remove("d-none")
  }

  clearError() {
    this.errorMessageTarget.textContent = ""
    this.errorMessageTarget.classList.add("d-none")
  }
}
