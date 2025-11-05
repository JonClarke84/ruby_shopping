import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["item"]

  connect() {
    this.draggedItem = null
    this.touchStartY = 0
    this.touchCurrentY = 0
    this.longPressTimer = null
    this.isDraggingTouch = false
    this.touchStartTime = 0
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

  dragStart(event) {
    this.draggedItem = event.currentTarget
    this.draggedItem.classList.add('dragging')
    event.dataTransfer.effectAllowed = 'move'
    event.dataTransfer.setData('text/html', this.draggedItem.innerHTML)
  }

  dragOver(event) {
    event.preventDefault()
    event.dataTransfer.dropEffect = 'move'

    const afterElement = this.getDragAfterElement(event.clientY)
    const draggable = this.draggedItem
    const container = this.element

    if (afterElement == null) {
      container.appendChild(draggable)
    } else {
      container.insertBefore(draggable, afterElement)
    }
  }

  drop(event) {
    event.preventDefault()
    event.stopPropagation()

    // Calculate the new position
    const listItemId = this.draggedItem.dataset.listItemId
    const listId = this.draggedItem.dataset.listId
    const allItems = Array.from(this.itemTargets)
    const currentIndex = allItems.indexOf(this.draggedItem)

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

  dragEnd(event) {
    if (this.draggedItem) {
      this.draggedItem.classList.remove('dragging')
    }
    this.draggedItem = null
  }

  getDragAfterElement(y) {
    const draggableElements = [...this.itemTargets].filter(item =>
      item !== this.draggedItem
    )

    return draggableElements.reduce((closest, child) => {
      const box = child.getBoundingClientRect()
      const offset = y - box.top - box.height / 2

      if (offset < 0 && offset > closest.offset) {
        return { offset: offset, element: child }
      } else {
        return closest
      }
    }, { offset: Number.NEGATIVE_INFINITY }).element
  }

  // Touch event handlers for mobile drag-and-drop
  touchStart(event) {
    // Don't trigger on buttons, checkboxes, or inputs
    if (event.target.closest('button, input, a')) {
      return
    }

    const touch = event.touches[0]
    this.touchStartY = touch.clientY
    this.touchStartTime = Date.now()
    const item = event.currentTarget

    // Start a timer for long press (500ms)
    this.longPressTimer = setTimeout(() => {
      this.isDraggingTouch = true
      this.draggedItem = item
      item.classList.add('dragging', 'touch-dragging')

      // Prevent scrolling while dragging
      document.body.style.overflow = 'hidden'

      // Add haptic feedback if available
      if (navigator.vibrate) {
        navigator.vibrate(50)
      }
    }, 500)
  }

  touchMove(event) {
    if (!this.isDraggingTouch || !this.draggedItem) {
      // If moved significantly before long press completes, cancel it
      const touch = event.touches[0]
      if (Math.abs(touch.clientY - this.touchStartY) > 10) {
        this.cancelTouch()
      }
      return
    }

    event.preventDefault() // Prevent scrolling
    const touch = event.touches[0]
    this.touchCurrentY = touch.clientY

    // Move the item visually
    const afterElement = this.getDragAfterElement(this.touchCurrentY)
    const container = this.element

    if (afterElement == null) {
      container.appendChild(this.draggedItem)
    } else {
      container.insertBefore(this.draggedItem, afterElement)
    }
  }

  touchEnd(event) {
    if (this.isDraggingTouch && this.draggedItem) {
      // Complete the reorder
      const listItemId = this.draggedItem.dataset.listItemId
      const listId = this.draggedItem.dataset.listId
      const allItems = Array.from(this.itemTargets)
      const currentIndex = allItems.indexOf(this.draggedItem)

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

    this.cancelTouch()
  }

  touchCancel(event) {
    this.cancelTouch()
  }

  cancelTouch() {
    if (this.longPressTimer) {
      clearTimeout(this.longPressTimer)
      this.longPressTimer = null
    }

    if (this.draggedItem) {
      this.draggedItem.classList.remove('dragging', 'touch-dragging')
    }

    this.isDraggingTouch = false
    this.draggedItem = null
    document.body.style.overflow = ''
  }
}
