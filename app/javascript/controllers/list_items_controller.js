import { Controller } from "@hotwired/stimulus"
import Sortable from "sortablejs"

export default class extends Controller {
  static targets = ["item"]

  connect() {
    // Initialize Sortable.js on the container element
    this.sortable = Sortable.create(this.element, {
      animation: 150,
      easing: "cubic-bezier(0.25, 0.46, 0.45, 0.94)",

      // Touch delay to prevent accidental drag while scrolling
      delay: 200,
      delayOnTouchOnly: true,
      touchStartThreshold: 3,

      // Disable scroll during drag to prevent direction change issues
      scroll: true,
      scrollSensitivity: 30,
      scrollSpeed: 10,
      bubbleScroll: true,

      // Improve swap behavior for direction changes
      swapThreshold: 0.65,
      invertSwap: false,
      direction: 'vertical',

      // Element configuration
      handle: '.list-item-card',
      draggable: '.list-item-card',
      filter: 'button, input, a',
      preventOnFilter: false,

      // CSS classes
      ghostClass: 'sortable-ghost',
      chosenClass: 'sortable-chosen',
      dragClass: 'sortable-drag',

      onStart: this.handleDragStart.bind(this),
      onEnd: this.handleReorder.bind(this)
    })
  }

  disconnect() {
    // Clean up Sortable instance when controller disconnects
    if (this.sortable) {
      this.sortable.destroy()
    }
  }

  handleDragStart(event) {
    // Enable touch-action blocking when drag starts
    this.element.dataset.dragging = 'true'
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

  handleReorder(event) {
    // Disable touch-action blocking when drag ends
    this.element.dataset.dragging = 'false'


    const item = event.item
    const listItemId = item.dataset.listItemId
    const listId = item.dataset.listId
    const allItems = Array.from(this.itemTargets)
    const currentIndex = allItems.indexOf(item)

    const previousItem = allItems[currentIndex - 1]
    const nextItem = allItems[currentIndex + 1]

    const previousId = previousItem ? previousItem.dataset.listItemId : null
    const nextId = nextItem ? nextItem.dataset.listItemId : null

    // Send reorder request
    fetch(`/lists/${listId}/list_items/${listItemId}/reorder`, {
      method: 'PATCH',
      headers: {
        'Content-Type': 'application/json',
        'X-CSRF-Token': document.querySelector('[name="csrf-token"]').content
      },
      body: JSON.stringify({
        previous_id: previousId,
        next_id: nextId
      })
    })
    .then(response => response.json())
    .then(data => {
      console.log('Item reordered successfully:', data)
    })
    .catch(error => {
      console.error('Error reordering item:', error)
      alert('Unable to reorder item. Please refresh the page.')
    })
  }
}
