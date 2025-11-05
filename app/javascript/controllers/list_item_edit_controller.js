import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["display", "form", "input", "editButton"]

  connect() {
    this.listId = this.element.closest('[data-controller="list-items"]').dataset.listId ||
                  window.location.pathname.split('/')[2] // Fallback to get list ID from URL
    this.listItemId = this.element.dataset.listItemId
    this.originalValue = this.inputTarget.value
  }

  edit() {
    this.displayTarget.style.display = 'none'
    this.formTarget.style.display = 'inline'
    this.editButtonTarget.textContent = 'Save'
    this.editButtonTarget.dataset.action = 'click->list-item-edit#save'
    this.inputTarget.focus()
    this.inputTarget.select()
  }

  handleKeydown(event) {
    if (event.key === 'Enter') {
      event.preventDefault()
      this.save()
    } else if (event.key === 'Escape') {
      event.preventDefault()
      this.cancel()
    }
  }

  save() {
    const newQuantity = parseInt(this.inputTarget.value)

    if (newQuantity < 1 || isNaN(newQuantity)) {
      alert('Quantity must be at least 1')
      this.inputTarget.value = this.originalValue
      return
    }

    // Update the display
    this.displayTarget.textContent = `× ${newQuantity}`
    this.originalValue = newQuantity

    // Send to server
    fetch(`/lists/${this.getListId()}/list_items/${this.listItemId}`, {
      method: 'PATCH',
      headers: {
        'Content-Type': 'application/json',
        'X-CSRF-Token': document.querySelector('[name="csrf-token"]').content
      },
      body: JSON.stringify({ quantity: newQuantity })
    })
    .then(response => response.json())
    .then(data => {
      console.log('Quantity updated:', data)
    })
    .catch(error => {
      console.error('Error updating quantity:', error)
      alert('Failed to update quantity')
    })

    this.hideForm()
  }

  cancel() {
    this.inputTarget.value = this.originalValue
    this.hideForm()
  }

  hideForm() {
    this.formTarget.style.display = 'none'
    this.displayTarget.style.display = 'inline'
    this.editButtonTarget.textContent = 'Edit'
    this.editButtonTarget.dataset.action = 'click->list-item-edit#edit'
  }

  getListId() {
    // Try to get from data attribute first
    const listItems = this.element.closest('[data-controller="list-items"]')
    if (listItems && listItems.dataset.listId) {
      return listItems.dataset.listId
    }
    // Fallback: extract from URL (assuming we're on /lists/:id)
    const pathParts = window.location.pathname.split('/')
    const listsIndex = pathParts.indexOf('lists')
    if (listsIndex !== -1 && pathParts[listsIndex + 1]) {
      return pathParts[listsIndex + 1]
    }
    // Last resort: we're probably on root, need to get from somewhere else
    return document.querySelector('[data-list-id]')?.dataset.listId || '1'
  }
}
