import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    console.log("List items controller connected")
  }

  toggle(event) {
    const checkbox = event.target
    const listItemId = checkbox.dataset.listItemId
    const listId = checkbox.dataset.listId
    const ticked = checkbox.checked

    console.log("Toggling list item", { listItemId, listId, ticked })

    fetch(`/lists/${listId}/list_items/${listItemId}/toggle`, {
      method: 'PATCH',
      headers: {
        'Content-Type': 'application/json',
        'X-CSRF-Token': document.querySelector('[name="csrf-token"]').content
      },
      body: JSON.stringify({ ticked: ticked })
    })
    .then(response => {
      console.log("Response status:", response.status)
      return response.json()
    })
    .then(data => {
      console.log("Response data:", data)
      const card = checkbox.closest('.list-item-card')
      if (ticked) {
        card.classList.add('list-item-ticked')
      } else {
        card.classList.remove('list-item-ticked')
      }
    })
    .catch(error => {
      console.error('Error toggling item:', error)
      checkbox.checked = !ticked // Revert on error
    })
  }
}
