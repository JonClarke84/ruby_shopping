import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
  }

  toggle(event) {
    const checkbox = event.target
    const listItemId = checkbox.dataset.listItemId
    const listId = checkbox.dataset.listId
    const ticked = checkbox.checked

    fetch(`/lists/${listId}/list_items/${listItemId}/toggle`, {
      method: 'PATCH',
      headers: {
        'Content-Type': 'application/json',
        'X-CSRF-Token': document.querySelector('[name="csrf-token"]').content
      },
      body: JSON.stringify({ ticked: ticked })
    })
    .then(response => response.json())
    .then(data => {
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
      alert('Unable to update item. Please try again.')
    })
  }
}
