# Add User-Defined Events Feature

I will implement the "Event" feature to allow manual time tracking alongside automatic app tracking.

## 1. Data Model & Persistence

* **Create** **`Event`** **Model**:

  * File: `time/Models/Event/Event.swift`

  * Properties: `id`, `name` (String), `startTime`, `endTime` (optional), `projectId` (optional, String?).

  * Conforms to `@Model` for SwiftData persistence.

* **Update App Schema**: Add `Event.self` to `App.swift`'s `ModelContainer`.

* **Create** **`EventManager`**:

  * File: `time/Models/Event/EventManager.swift`

  * Manages the "Current Running Event" state.

  * Provides methods: `startEvent`, `stopCurrentEvent`, `updateEvent`.

## 2. Event Creation & Management (UI)

* **New** **`StartEventView`**:

  * A popover/sheet to enter Event Name and select a Project (optional).

  * Allows setting an optional specific Start/End time (defaulting to "Now").

* **Update** **`MainToolbarView`**:

  * Add a "Start Event" button.

  * When an event is running, display a button labeled **"Stop [Event Name]"** (showing the actual name of the running event) and a timer display for the event.

## 3. Timeline Visualization

* **Update** **`TimelineView`**:

  * Split the timeline into two tracks:

    1. **Activity Track** (Top row): Displays the existing automatic app usage.
    2. **Events Track** (Bottom row): Displays user-created events.

  * Pass `[Event]` data to `TimelineView`.

* **Event Rendering**:

  * Create logic to render `Event` objects as blocks.

  * Display the Event Name inside the block.

* **Interaction**:

  * Clicking an Event block opens an **Edit Event Popover** to modify name, times, or project.

## 4. Menu Bar Access

* **Add Menu Bar Extra**:

  * In `App.swift` (or a new file), add a `MenuBarExtra`.

  * **Status Item**:

    * Default: App Icon.

    * **When Event Running**: Display **"Event Name: [Duration]"** (or similar format) next to the icon (if space permits) or as the first menu item.

  * **Menu Items**:

    * "Start New Event" (if none running).

    * **"Stop [Event Name]"** (if running).

    * "Quit".

## 5. Settings & Automation

* **Update** **`TrackingSettingsView`**:

  * Add a toggle: "Stop current event when computer is idle".

* **Update** **`IdleMonitor`**:

  * Inject `EventManager`.

  * If the computer goes idle and the setting is enabled, automatically stop the current event.

## Verification Plan

* **Manual Testing**:

  * Create an event via Toolbar -> Verify it appears on Timeline (Bottom row).

  * Stop event via Toolbar -> Verify "Stop [Name]" button works and `endTime` is set.

  * Create event via Menu Bar -> Verify sync, label, and duration display.

  * Test Idle Stop -> Wait for idle (or simulate) and check if event stops.

  * Edit Event -> Change name/time on Timeline and verify persistence.
