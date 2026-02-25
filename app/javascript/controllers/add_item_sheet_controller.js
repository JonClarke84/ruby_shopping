import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["sheet", "backdrop", "dragHandle", "nameInput", "hiddenName", "quantityInput", "quantityDisplay"]

  connect() {
    this.isOpen = false
    this.isDragging = false
    this.dragStartY = 0
    this.currentDragY = 0

    this.handleEscape = this.handleEscape.bind(this)
    this._onPointerMove = this._onPointerMove.bind(this)
    this._onPointerUp = this._onPointerUp.bind(this)

    document.addEventListener('keydown', this.handleEscape)
  }

  disconnect() {
    document.removeEventListener('keydown', this.handleEscape)
    this._cleanupDrag()
  }

  open(event) {
    if (event) event.preventDefault()
    this.isOpen = true
    this.sheetTarget.style.transition = ''
    this.sheetTarget.classList.add('sheet-open')
    this.backdropTarget.classList.add('sheet-backdrop-visible')
    document.body.style.overflow = 'hidden'

    setTimeout(() => {
      if (this.hasNameInputTarget) {
        this.nameInputTarget.focus()
      }
    }, 300)
  }

  close(event) {
    if (event) event.preventDefault()
    this.isOpen = false
    this.sheetTarget.style.transition = ''
    this.sheetTarget.style.transform = ''
    this.backdropTarget.style.opacity = ''
    this.sheetTarget.classList.remove('sheet-open')
    this.backdropTarget.classList.remove('sheet-backdrop-visible')
    document.body.style.overflow = ''
  }

  backdropClick(event) {
    if (event.target === this.backdropTarget) {
      this.close()
    }
  }

  handleEscape(event) {
    if (event.key === 'Escape' && this.isOpen) {
      this.close()
    }
  }

  // --- Drag-to-dismiss ---

  dragStart(event) {
    if (!this.isOpen) return

    this.isDragging = true
    this.dragStartY = event.clientY ?? event.touches?.[0]?.clientY ?? 0
    this.currentDragY = 0

    // Disable CSS transitions while dragging for immediate feedback
    this.sheetTarget.style.transition = 'none'
    this.backdropTarget.style.transition = 'none'

    // Capture pointer for reliable tracking even if finger leaves the handle
    if (event.pointerId !== undefined) {
      this.dragHandleTarget.setPointerCapture(event.pointerId)
    }

    document.addEventListener('pointermove', this._onPointerMove)
    document.addEventListener('pointerup', this._onPointerUp)
    document.addEventListener('pointercancel', this._onPointerUp)
  }

  _onPointerMove(event) {
    if (!this.isDragging) return

    event.preventDefault()
    const clientY = event.clientY ?? 0
    const deltaY = clientY - this.dragStartY

    // Only allow dragging downward
    this.currentDragY = Math.max(0, deltaY)

    // Move the sheet with the finger
    this.sheetTarget.style.transform = `translateY(${this.currentDragY}px)`

    // Fade the backdrop proportionally
    const progress = Math.min(this.currentDragY / 300, 1)
    this.backdropTarget.style.opacity = `${1 - progress}`
  }

  _onPointerUp() {
    if (!this.isDragging) return

    this.isDragging = false
    this._cleanupDrag()

    // Re-enable transitions for the snap/dismiss animation
    this.sheetTarget.style.transition = 'transform 300ms cubic-bezier(0.32, 0.72, 0, 1)'
    this.backdropTarget.style.transition = 'opacity 300ms ease'

    if (this.currentDragY > 150) {
      // Dragged far enough — dismiss
      this.close()
    } else {
      // Snap back to open position
      this.sheetTarget.style.transform = 'translateY(0)'
      this.backdropTarget.style.opacity = '1'
    }
  }

  _cleanupDrag() {
    document.removeEventListener('pointermove', this._onPointerMove)
    document.removeEventListener('pointerup', this._onPointerUp)
    document.removeEventListener('pointercancel', this._onPointerUp)
  }

  // After successful form submission via Turbo Stream, clear and keep open
  resetForm(event) {
    if (event && event.detail && !event.detail.success) return

    requestAnimationFrame(() => {
      if (this.hasNameInputTarget) {
        this.nameInputTarget.value = ''
        this.nameInputTarget.focus()
      }
      if (this.hasHiddenNameTarget) {
        this.hiddenNameTarget.value = ''
      }
      if (this.hasQuantityInputTarget) {
        this.quantityInputTarget.value = 1
      }
      if (this.hasQuantityDisplayTarget) {
        this.quantityDisplayTarget.textContent = '1'
      }
    })
  }
}
