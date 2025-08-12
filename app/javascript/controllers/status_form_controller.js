// app/javascript/controllers/status_form_controller.js
import { Controller } from "@hotwired/stimulus"
export default class extends Controller {
  static targets = [
    "statusSelect",
    "adminNoteField",
    "actualReturnDateField",
    "errorMessage"
  ]

  connect() {
    this.tForm = I18n.t("admin.borrow_requests.status_form_js")
    this.toggleFields()
  }

  toggleFields() {
    const status = this.statusSelectTarget.value
    this.hideAll()

    if (status === this.tForm.status.rejected) {
      this.show(this.adminNoteFieldTarget)
    } else if (status === this.tForm.status.returned) {
      this.show(this.actualReturnDateFieldTarget)
    }
  }

  validateForm(event) {
    const status = this.statusSelectTarget.value
    const currentStatus = this.statusSelectTarget.dataset.currentStatus

    console.log("Status", status)
    console.log("currentStatus",currentStatus)
    if (status === currentStatus) {
      this.showError(this.tForm.error.no_change_status) 
      event.preventDefault()
      return
    }

    // Trường hợp rejected -> bắt buộc admin_note
    if (status === this.tForm.status.rejected) {
      const noteField = this.adminNoteFieldTarget.querySelector("textarea, input")
      if (!noteField || noteField.value.trim() === "") {
        this.showError(this.tForm.error.admin_note_required)
        event.preventDefault()
        return
      }
    }

    // Trường hợp returned -> bắt buộc validate date
    if (status === this.tForm.status.returned) {
      const dateField = this.actualReturnDateFieldTarget.querySelector("input")
      if (!dateField) return

      const selectedDate = new Date(dateField.value)
      const today = new Date()
      today.setHours(0, 0, 0, 0)

      if (isNaN(selectedDate.getTime())) {
        this.showError(this.tForm.error.invalid_date)
        event.preventDefault()
        return
      }

      if (selectedDate > today) {
        this.showError(this.tForm.error.date_not_in_future)
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
