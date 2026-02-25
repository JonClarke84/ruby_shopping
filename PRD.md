# Product Requirements Document: Shopping List App Modernization

**Date:** 2026-02-24
**Status:** Draft - Pending Implementation
**Target Platform:** Mobile only (390px viewport, never used on desktop)

---

## 1. Executive Summary

This PRD captures the findings from a comprehensive UI/UX review of the Ruby Shopping app. The app is a Rails 8.1 shopping list application with multi-tenancy via Groups, meal planning, and real-time item management using Hotwire (Turbo + Stimulus). It is used exclusively on mobile.

The current UI has a "retro pixel-art" aesthetic with a monospace font (DM Mono), teal accent color, and traditional web navigation patterns. While functional, it does not feel like a native mobile app. This document outlines the design changes and product features needed to modernize it into a polished, app-like experience.

---

## 2. Current State Assessment

### What Works
- Core shopping list CRUD is functional
- Drag-and-drop reorder via Sortable.js
- Inline quantity editing
- Dark mode support
- Group-based multi-tenancy with invitations
- Autocomplete for previously added items
- Turbo Streams for real-time item add/remove

### Key Problems
- **Navigation:** Top dropdown menu requires two taps to reach any secondary screen; no bottom tab bar
- **Item cards:** Each item is ~120px tall with always-visible Edit/Remove buttons, meaning only 3-4 items visible at once
- **Add item form:** Permanently occupies ~180px of prime screen space at the top of the list
- **Meals section:** Blocks list view with 7 stacked text inputs when expanded
- **Typography:** Monospace font hurts readability for list scanning in a store
- **Visual hierarchy:** Low-contrast card borders barely visible in daylight; items and actions compete for attention
- **No item categories:** Flat list with no aisle/category grouping
- **No live sync:** Group members can't see each other's changes in real-time
- **No recurring lists/templates:** Users recreate the same staples list every week

---

## 3. Design Changes

### 3.1 Bottom Tab Navigation

**Priority: P0 - Foundation (implement first)**

Replace the top dropdown menu with a fixed bottom tab bar:

```
[ List ]    [ Meals ]    [ Items ]    [ Account ]
 (home)      (fork)      (grid)      (person)
```

- `position: fixed; bottom: 0; left: 0; right: 0`
- `padding-bottom: env(safe-area-inset-bottom)` for iPhone notch
- Icon + label per tab, active tab highlighted in teal
- "List" = current shopping list (root path)
- "Meals" = meal planner (extracted from the main list view)
- "Items" = master item inventory
- "Account" = groups, invitations, settings, logout

Pending invitation count badge on the Account tab icon.

### 3.2 Redesigned Top Header

**Priority: P0 - Foundation**

Slim fixed header (56px) with three zones:

```
[ Group Name chip ]   [ Screen Title ]   [ + action ]
```

- Left: Current group name as a tappable chip that opens a group switcher bottom sheet
- Center: Current screen title
- Right: Context-sensitive primary action ("+  Add Item" on list, "+ New List" on lists screen)
- Content area gets `padding-top: 56px` and `padding-bottom: calc(64px + env(safe-area-inset-bottom))`

### 3.3 Item List Redesign (Row Layout)

**Priority: P0 - Highest visual impact**

Replace card grid with flat list rows (~52px each):

```
[checkbox]  Item name                  x2   [...]
[checkbox]  Item name                  x1   [...]
```

- Checkbox moves to the **left edge** (44x44px circular tap target)
- Custom circular checkbox: open circle unchecked, filled teal circle with white checkmark when checked
- Check animation: brief scale pulse (0.85 -> 1.0, 200ms)
- Item name + quantity inline in the center
- Three-dot kebab icon on the right reveals Edit/Remove in a contextual bottom sheet
- Remove the horizontal rule divider between name and buttons
- Remove outer card border for unticked items; use simple 1px separator lines
- Drag handles hidden by default (see 3.7)

### 3.4 Completed Items Section

**Priority: P1**

- Checked items animate down (slide + fade, 250ms) into a collapsible "Completed (N)" section at the bottom
- Collapsible section header: "Completed (3)" - tap to expand/collapse
- Completed items shown greyed out with strikethrough
- 2-second undo toast at bottom of screen: "Milk checked -- Undo" (pill-shaped snackbar)
- Replaces the current behavior where ticked items stay in-place with reduced opacity

### 3.5 Floating Action Button (FAB) for Add Item

**Priority: P1**

- Remove the persistent add-item form from the top of the list
- Add a teal "+" circle FAB (56px), anchored bottom-right, above the tab bar
- Tapping opens a bottom sheet with:
  - Item name input (autofocused, keyboard appears immediately)
  - Stepper control for quantity (- / 1 / +) instead of a raw number input
  - "Add" button (submits and keeps sheet open for rapid multi-item entry)
  - "Done" button to dismiss
- Below the input: "From your last shop" section showing 5-10 most frequently purchased items as tappable chips for quick-add
- Autocomplete triggers from 2 characters (down from 3) with 200ms debounce (down from 500ms)

### 3.6 Meals Planner Redesign

**Priority: P1**

Move meals to its own tab (second tab in bottom bar). New layout:

- Horizontal day-picker strip at top: 7 circular day pills (Mon, Tue, Wed...) scrollable
- Tapping a day reveals a single input for that day's meal
- Previous day's meal shown dimly above for context
- Auto-save on blur (remove the "Update Meals" button)
- Brief "Saved" badge confirmation on save
- Collapsed summary in any list-view context: "Tue: Pasta, Wed: Curry, Thu: --"

### 3.7 Drag-to-Reorder Mode

**Priority: P2**

- Hide drag handles in normal view
- Add a "Reorder" button in the list header that enters reorder mode
- In reorder mode: drag handles appear, "Done" button replaces "Reorder"
- Alternative: long-press on a row to enter reorder mode
- Optional: right-swipe reveals "Move to top" quick action

### 3.8 Group Switcher Bottom Sheet

**Priority: P2**

Tapping the group name chip in the header opens a bottom sheet:

```
------ drag handle ------
My Groups

  [x] Alice Smith (current)
  [ ] Family Group
  [ ] Work Lunches

+ Create New Group
--------------------------
```

- `<dialog>` or similar, `position: fixed; bottom: 0; width: 100%`
- CSS slide-up animation (`translateY(100%)` -> `translateY(0)`)
- Selecting a group fires `PATCH /switch_group` and dismisses

### 3.9 New List as Modal

**Priority: P2**

- Instead of navigating to `/lists/new` for a single-field form, open a bottom sheet/modal with the date picker
- Submitting creates the list and navigates to it
- Reduces navigation depth for a trivial action

### 3.10 Empty States

**Priority: P2**

Replace plain text empty states with vertically centered cards:

```
    [relevant icon - large, teal]

    No shopping list yet

    Tap + to create your first list

    [ Create List ]
```

Same treatment for empty items list, empty meals, empty groups. Each uses a contextual icon, one-line explanation, and a single CTA button (48px minimum height).

### 3.11 Invitations Page Consistency

**Priority: P3**

- Move invitations into the Account tab
- Replace inline styles with proper CSS classes matching the design system
- Each invitation as a card with group name, inviter, time ago
- "Accept" = teal filled button, "Decline" = ghost/outline button

---

## 4. Typography & Color Changes

### 4.1 Two-Font System

**Priority: P1**

Replace the all-monospace approach:

- **Item names and UI labels:** Clean sans-serif -- **Inter** or **Plus Jakarta Sans** (free, screen-optimized)
- **Quantities, dates, numeric labels:** Keep DM Mono for scannable numbers and personality
- Rationale: Sans-serif is faster to read under store lighting on OLED screens; monospace makes long item names wrap unnecessarily on 390px width

### 4.2 Surface & Color Refinements

**Priority: P2**

- Remove card borders for list item rows; use spacing + 1px separator lines (like Apple Reminders, Todoist)
- Simplify to a single background color per mode
- Consider warming the teal slightly toward green (`#10b77e`) -- grocery apps conventionally use greens/warm tones
- Increase focus ring opacity from 10% to 20% for better visibility
- Subtle shadow (no border) for elevated surfaces like the add-item sheet

---

## 5. Micro-Interactions

**Priority: P2**

| Interaction | Current | Target |
|---|---|---|
| Checking an item | Instant class toggle | 200ms scale pulse on checkbox + 300ms slide-fade to completed section |
| Adding an item | Turbo Stream replace | Slide-in from top, 250ms |
| Removing an item | Confirm dialog + remove | Slide-out left + collapse height 200ms, undo toast |
| Drag reorder | Ghost + fallback clone | Ghost with subtle shadow lift, smooth spring settle |
| Autocomplete open | Instant display:block | Fade-in + slide down 150ms |
| Bottom sheet open | N/A | Slide up from bottom with backdrop fade |

---

## 6. New Product Features

### 6.1 Item Categories / Aisle Groups

**Priority: P0 | Complexity: Low**

**Problem:** Flat list with 30+ items requires hunting. Users mentally group by aisle but the app doesn't.

**Solution:** Add optional `category` string to `items` table (e.g. "Produce", "Dairy", "Frozen", "Meat", "Bakery", "Pantry", "Household"). On the list view, items render grouped under collapsible sticky section headers. Users assign a category once on the item -- it persists across all future lists.

**Schema change:** `add_column :items, :category, :string`

**UI:** Small tag pill on item row, tappable to assign/change. List view groups items with sticky headers like "Produce (3)".

### 6.2 Quick Re-Add from Purchase History

**Priority: P0 | Complexity: Low**

**Problem:** Users re-type the same items they buy every week. The data already exists in `list_items` history.

**Solution:** In the add-item bottom sheet, show "From your last shop" section with the 10 most frequently purchased items as tappable chips. One tap adds them to the current list.

**Schema change:** None -- query existing `list_items` joined across `lists` with COUNT.

**UI:** Chip pills in the add-item sheet, below the text input. Each chip shows item name; tapping adds it with default quantity.

### 6.3 Inline List Search / Filter

**Priority: P0 | Complexity: Low**

**Problem:** Lists with 15+ items are hard to scan on a small mobile screen.

**Solution:** Search icon in list header expands a filter input. Typing filters visible items in real-time via Stimulus controller (no server round-trip). A "Hide completed" toggle collapses ticked items to a count summary.

**Schema change:** None -- pure client-side filtering.

**UI:** Collapsible search bar below the list header. "Hide completed" toggle next to it.

### 6.4 List Templates / Recurring Lists

**Priority: P1 | Complexity: Medium**

**Problem:** Most households buy the same 20-30 staples weekly. Recreating the list from scratch is tedious.

**Solution:** Save a list (or subset of items) as a template. When creating a new list, choose "Start from template" to auto-populate with saved items and quantities. Templates are group-scoped.

**Schema change:** `add_column :lists, :is_template, :boolean, default: false` or new `ListTemplate` / `ListTemplateItem` models.

**UI:** "Save as template" in list action menu. "Start from template" toggle on new list form.

### 6.5 Live Sync via Turbo Streams + ActionCable

**Priority: P1 | Complexity: Medium**

**Problem:** Group members can't see each other's changes in real-time. Shopping together feels disconnected.

**Solution:** Broadcast list-item updates (tick, add, remove) to all users on the same list channel via ActionCable + Turbo Streams. Show a "2 people shopping" presence indicator. Changes from others get a brief highlight animation.

**Schema change:** None -- uses existing ActionCable infrastructure.

**UI:** Small presence pill in list header. Remote changes highlighted briefly on arrival.

### 6.6 Item Notes

**Priority: P1 | Complexity: Low**

**Problem:** "Chicken breast - skinless, from the deli not the fridge section." Quantity alone isn't enough context for shared lists.

**Solution:** Optional short note (max 100 chars) per `ListItem`. Shown as muted second line below item name. Tap to add/edit inline.

**Schema change:** `add_column :list_items, :note, :string`

**UI:** Second line in muted text on item row. Pencil icon or tap-target for inline editing.

### 6.7 Bulk Actions

**Priority: P2 | Complexity: Medium**

**Problem:** Resetting or clearing a list of 25+ items one by one is impractical.

**Solution:** "Select" button activates bulk mode with select-all checkbox. Floating action bar at bottom with "Tick All", "Untick All", "Remove Ticked".

**Schema change:** None -- new controller actions accepting array of `list_item_ids`.

**UI:** "Select" in header, floating action bar at bottom in bulk mode.

### 6.8 Meal-to-Items Link

**Priority: P2 | Complexity: Medium-High**

**Problem:** Meals and items are disconnected. Planning "Spaghetti Bolognese" doesn't auto-add mince, pasta, passata.

**Solution:** Meals can have associated ingredient Items. When a meal is added to the planner, prompt: "Add ingredients to your list?" with pre-checked items.

**Schema change:** New `meal_items` join table (`meal_id`, `item_id`, `quantity`).

**UI:** Ingredient count badge on meal. "Add to list" from planner opens bottom sheet with pre-checked ingredients.

### 6.9 List Archive / History with Restore

**Priority: P2 | Complexity: Low**

**Problem:** Old lists are read-only archaeology. Users want to re-use items from past trips.

**Solution:** Enhanced `/lists/all` view with card-per-list showing date, item count, meal summary. "Copy to current list" action bulk-adds items, skipping duplicates.

**Schema change:** None -- data already exists.

**UI:** History cards with "View" and "Copy to current list" actions.

### 6.10 PWA Install with Offline Support

**Priority: P3 | Complexity: Medium**

**Problem:** Mobile browser access lacks home screen icon, offline viewing, and app-like chrome. PWA scaffolding already partially exists in the codebase.

**Solution:** Enable existing PWA routes, add Web App Manifest, implement Service Worker with cache-first for assets and network-first for list data. Current list readable offline.

**Schema change:** None.

**UI:** One-time "Install app" prompt. Full-screen app experience once installed.

### 6.11 Budget Tracker (Running Total)

**Priority: P3 | Complexity: Medium**

**Problem:** No price awareness until checkout.

**Solution:** Optional `estimated_price` on items. List view shows running total in a sticky footer: "Est. total: $47.50 | Ticked: $12.00 | Remaining: $35.50".

**Schema change:** `add_column :items, :estimated_price, :decimal, precision: 8, scale: 2`

**UI:** Sticky footer on list view. Price editing on master items page.

### 6.12 Sort Presets

**Priority: P3 | Complexity: Low**

**Problem:** Manual drag reorder of 25 items per week is tedious. No quick way to view by category or recency.

**Solution:** Sort control in list header: "My Order" (saved sort_order), "By Category", "Recently Added". Client-side sorting via Stimulus using data attributes. Preference saved to localStorage.

**Schema change:** None.

**UI:** Small sort button/segmented control in list header.

---

## 7. Implementation Phases

### Phase 1: Foundation (Structural)
1. Bottom tab navigation + fixed header
2. Item row layout redesign (replace card grid with flat rows)
3. FAB + bottom sheet for add item
4. Two-font system (Inter + DM Mono)

### Phase 2: Core Features
5. Item categories / aisle groups
6. Completed items section with undo toast
7. Move meals to its own tab with day-picker redesign
8. Quick re-add from purchase history
9. Inline list search / filter

### Phase 3: Collaboration & Templates
10. Live sync via ActionCable + Turbo Streams
11. List templates / recurring lists
12. Item notes
13. Group switcher bottom sheet

### Phase 4: Polish & Advanced
14. Micro-interactions (animations, transitions)
15. Bulk actions
16. Drag-to-reorder mode
17. Empty states redesign
18. Surface & color refinements
19. Meal-to-items link
20. List archive with restore

### Phase 5: Future
21. PWA with offline support
22. Budget tracker
23. Sort presets
24. Invitations page consistency

---

## 8. Design References

Apps to reference for patterns and inspiration:
- **Apple Reminders** - row layout, completed section, bottom sheet patterns
- **Bring!** - grocery-specific UX, category grouping, warm color palette
- **AnyList** - shared lists, meal planning integration, clean typography
- **Todoist** - FAB pattern, undo toast, micro-interactions
- **OurGroceries** - real-time sync, category management
- **Google Keep** - card layout, color coding, quick add

---

## 9. Technical Constraints

- **Stack:** Rails 8.1, Hotwire (Turbo + Stimulus), Sortable.js, importmap (no bundler)
- **No external CSS framework** - all custom CSS (~984 lines in application.css)
- **Turbo Streams** for real-time updates (no Turbo Frames currently in use)
- **ActionCable** available but not currently used (needed for live sync)
- **SQLite3** database - sufficient for current scale
- **PWA scaffolding** partially in place (routes exist, service worker stubbed)
