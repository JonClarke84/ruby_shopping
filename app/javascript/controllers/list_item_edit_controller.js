import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["display", "form", "input", "editButton", "swipeContainer", "swipeContent"]

  connect() {
    this.listItemId = this.element.dataset.listItemId
    this.originalValue = this.inputTarget.value
    this.swipeOffset = 0
    this.isOpen = false
    this.startX = 0
    this.startY = 0
    this.currentX = 0
    this.isSwiping = false
    this.actionsWidth = 140 // width of the revealed actions area

    // Close swipe when tapping elsewhere
    this.outsideClickHandler = (e) => {
      if (this.isOpen && !this.element.contains(e.target)) {
        this.closeSwipe()
      }
    }
    document.addEventListener("touchstart", this.outsideClickHandler, { passive: true })
  }

  disconnect() {
    document.removeEventListener("touchstart", this.outsideClickHandler)
  }

  // ---- Swipe gesture handling ----

  onTouchStart(event) {
    // Don't initiate swipe on drag handle or checkbox
    const target = event.target
    if (target.closest(".drag-handle") || target.closest(".custom-checkbox")) return

    this.startX = event.touches[0].clientX
    this.startY = event.touches[0].clientY
    this.isSwiping = false
    this.startOffset = this.swipeOffset
    this.swipeContentTarget.style.transition = "none"
  }

  onTouchMove(event) {
    if (this.startX === null) return

    const currentX = event.touches[0].clientX
    const currentY = event.touches[0].clientY
    const deltaX = currentX - this.startX
    const deltaY = currentY - this.startY

    // Determine if this is a horizontal swipe (only on first significant movement)
    if (!this.isSwiping && (Math.abs(deltaX) > 8 || Math.abs(deltaY) > 8)) {
      if (Math.abs(deltaX) > Math.abs(deltaY)) {
        this.isSwiping = true
      } else {
        // Vertical scroll, bail out
        this.startX = null
        this.swipeContentTarget.style.transition = ""
        return
      }
    }

    if (!this.isSwiping) return

    event.preventDefault()

    let newOffset = this.startOffset + deltaX

    // Clamp: no swiping right past origin, and limit left swipe with rubber-band
    if (newOffset > 0) {
      newOffset = newOffset * 0.2 // rubber band right
    } else if (newOffset < -this.actionsWidth) {
      const over = newOffset + this.actionsWidth
      newOffset = -this.actionsWidth + over * 0.3 // rubber band past actions
    }

    this.swipeOffset = newOffset
    this.swipeContentTarget.style.transform = `translateX(${newOffset}px)`
  }

  onTouchEnd() {
    if (this.startX === null) return
    this.startX = null

    this.swipeContentTarget.style.transition = "transform 300ms cubic-bezier(0.32, 0.72, 0, 1)"

    // Decide whether to snap open or closed
    const threshold = this.actionsWidth * 0.35
    if (this.swipeOffset < -threshold) {
      this.openSwipe()
    } else {
      this.closeSwipe()
    }
  }

  openSwipe() {
    this.swipeOffset = -this.actionsWidth
    this.isOpen = true
    this.swipeContentTarget.style.transform = `translateX(${-this.actionsWidth}px)`
    this.swipeContainerTarget.classList.add("swipe-open")
  }

  closeSwipe() {
    this.swipeOffset = 0
    this.isOpen = false
    this.swipeContentTarget.style.transform = "translateX(0)"
    this.swipeContainerTarget.classList.remove("swipe-open")
  }

  // ---- Quantity editing ----

  edit() {
    // Close swipe if open
    if (this.isOpen) {
      this.closeSwipe()
    }

    this.displayTarget.style.display = "none"
    this.formTarget.style.display = "inline-flex"
    this.inputTarget.focus()
    this.inputTarget.select()
  }

  handleKeydown(event) {
    if (event.key === "Enter") {
      event.preventDefault()
      this.save()
    } else if (event.key === "Escape") {
      event.preventDefault()
      this.cancel()
    }
  }

  save() {
    const newQuantity = parseInt(this.inputTarget.value)

    if (newQuantity < 1 || isNaN(newQuantity)) {
      alert("Quantity must be at least 1")
      this.inputTarget.value = this.originalValue
      return
    }

    // Update the display
    this.displayTarget.textContent = `\u00d7${newQuantity}`
    this.originalValue = newQuantity

    // Send to server
    fetch(`/lists/${this.getListId()}/list_items/${this.listItemId}`, {
      method: "PATCH",
      headers: {
        "Content-Type": "application/json",
        "X-CSRF-Token": document.querySelector('[name="csrf-token"]').content
      },
      body: JSON.stringify({ quantity: newQuantity })
    })
    .then(response => response.json())
    .catch(error => {
      console.error("Error updating quantity:", error)
      alert("Unable to update quantity. Please try again.")
      // Revert the display
      this.displayTarget.textContent = `\u00d7${this.originalValue}`
      this.inputTarget.value = this.originalValue
    })

    this.hideForm()
  }

  cancel() {
    this.inputTarget.value = this.originalValue
    this.hideForm()
  }

  hideForm() {
    this.formTarget.style.display = "none"
    this.displayTarget.style.display = "inline-flex"
  }

  getListId() {
    return this.element.dataset.listId
  }
}
