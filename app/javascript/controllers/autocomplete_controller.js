import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input", "results"]
  static values = { url: String }

  connect() {
    this.debounceTimeout = null
    this.isLoading = false
    this.hiddenField = document.getElementById('item_name_hidden')
  }

  disconnect() {
    if (this.debounceTimeout) {
      clearTimeout(this.debounceTimeout)
    }
  }

  search(event) {
    const query = this.inputTarget.value.trim()

    // Sync value to hidden field for form submission
    if (this.hiddenField) {
      this.hiddenField.value = this.inputTarget.value
    }

    // Clear any pending debounce
    if (this.debounceTimeout) {
      clearTimeout(this.debounceTimeout)
    }

    // Hide results if less than 3 characters
    if (query.length < 3) {
      this.hideResults()
      return
    }

    // Show loading state
    this.showLoading()

    // Debounce by 500ms
    this.debounceTimeout = setTimeout(() => {
      this.performSearch(query)
    }, 500)
  }

  async performSearch(query) {
    try {
      const url = `${this.urlValue}?q=${encodeURIComponent(query)}`
      const response = await fetch(url, {
        headers: {
          'Accept': 'application/json'
        }
      })

      if (!response.ok) {
        throw new Error('Search request failed')
      }

      const items = await response.json()
      this.displayResults(items)
    } catch (error) {
      console.error('Error fetching autocomplete results:', error)
      this.hideResults()
    }
  }

  showLoading() {
    this.resultsTarget.innerHTML = '<div class="autocomplete-loading">Searching...</div>'
    this.resultsTarget.classList.add('autocomplete-results-visible')
    this.isLoading = true
  }

  displayResults(items) {
    this.isLoading = false

    if (items.length === 0) {
      this.hideResults()
      return
    }

    const html = items.map(item =>
      `<div class="autocomplete-item" data-action="click->autocomplete#select" data-name="${this.escapeHtml(item.name)}">
        ${this.escapeHtml(item.name)}
      </div>`
    ).join('')

    this.resultsTarget.innerHTML = html
    this.resultsTarget.classList.add('autocomplete-results-visible')
  }

  hideResults() {
    this.resultsTarget.innerHTML = ''
    this.resultsTarget.classList.remove('autocomplete-results-visible')
    this.isLoading = false
  }

  select(event) {
    const name = event.currentTarget.dataset.name
    this.inputTarget.value = name

    // Sync to hidden field
    if (this.hiddenField) {
      this.hiddenField.value = name
    }

    this.hideResults()
    this.inputTarget.focus()
  }

  clickOutside(event) {
    if (!this.element.contains(event.target)) {
      this.hideResults()
    }
  }

  keydown(event) {
    // Close on Escape key
    if (event.key === 'Escape') {
      this.hideResults()
      event.preventDefault()
    }
  }

  escapeHtml(text) {
    const div = document.createElement('div')
    div.textContent = text
    return div.innerHTML
  }
}
