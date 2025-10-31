# Timing App UI/UX Specification - Screenshots Reference

## Overview
This document provides a guide to the screenshots included with the Timing App UI/UX Interaction Specification.

## Screenshot Directory
All screenshots are located in: `./screenshots/`

### Available Screenshots

#### Figure 1: Activities View
**File**: `01-activities-view.png`
**Location in Spec**: Section 3.1 (Main Views / Screen Layouts)
**Size**: 356 KB

**What it shows**:
- Left sidebar with project navigation (260px fixed width)
  - "Projects" header
  - "All Activities", "Unassigned", "My Projects" sections
  - Project list with disclosure triangles for expansion
  - Color-coded project icons
  
- Top toolbar (52px height)
  - Navigation tabs: Activities, Stats, Reports
  - Date range controls with arrows
  - Search field on the right
  
- Main content area (fluid width)
  - Activity summary showing total time
  - Two-column activity table
    - Left column: Duration values (7m, 4m, 2m, etc.)
    - Right column: Activity names, project icons, disclosure triangles
  - Activity rows with interactive disclosure triangles

**Key UI Elements Visible**:
- Split-view layout architecture
- Table header styling
- Row hover states
- Duration column right-alignment
- Activity grouping with disclosure triangles

---

#### Figure 2: Stats View
**File**: `02-stats-view.png`
**Location in Spec**: Section 3.2 (Main Views / Screen Layouts)
**Size**: 435 KB

**What it shows**:
- Same sidebar and toolbar as Activities view
- Main content area displaying analytics dashboard
  - Stat cards section (top):
    - "Total time" card with large duration display
    - "Productivity score" card with percentage
  
- Multiple chart sections:
  - "Most active hours" - bar chart showing time distribution by hour
  - "Most productive hours" - bar chart showing productive time by hour
  - "Most active weekdays" - bar chart showing daily distribution
  - "Most productive weekdays" - bar chart showing productive days
  
- Data tables section (bottom):
  - Applications list with durations
  - Projects & Time Entries list with durations

**Key UI Elements Visible**:
- Stat card component styling
- Chart visualizations and layouts
- Table headers with gray background
- Row alternating backgrounds
- Color-coded data display

---

#### Figure 3: Reports View
**File**: `03-reports-view.png`
**Location in Spec**: Section 3.3 (Main Views / Screen Layouts)
**Size**: 355 KB

**What it shows**:
- Same sidebar and toolbar as other views
- Right control panel (280px) with:
  - Radio button group for view modes (Table/Details)
  - "Include:" dropdown for data type selection
  - "Columns:" checkboxes for:
    - ☑ Project
    - ☑ Title
    - ☐ Notes
    - ☐ Billing Status
  - "Filter:" dropdown button
  - "File Format:" dropdown (Excel/CSV)
  - "Duration Format:" dropdown
  - "Export..." primary button

- Main content area:
  - Sortable data table with three columns:
    - Duration (right-aligned)
    - Project (project names)
    - Title (activity descriptions)
  - Sample data rows showing activities, projects, and durations

**Key UI Elements Visible**:
- Right panel control layout
- Checkbox styling and states
- Dropdown button styling
- Table column headers
- Primary button (Export) styling
- Three-column data table layout

---

#### Figure 4: Activities View - Grouping Mode 1 (Unified)
**File**: `04-activities-expanded.png`
**Location in Spec**: Section 3.1, subsections 5-6 (Activity Grouping Modes & Expansion Behaviors)
**Size**: 419 KB

**What it shows**:
- Activities view with **Unified View grouping mode** (first radio button selected)
- Activities organized by project/category:
  - Multiple project groups (Unassigned, Warp, Arc, Timing, etc.)
  - Some groups expanded (▼) showing sub-entries
  - Some groups collapsed (▶)
- Demonstrating the default hierarchical structure with disclosure triangles
- Sub-entries visible showing individual time entries for expanded groups
- Each group shows total duration
- Detailed expansion showing different types of metadata:
  - Simple timestamp ranges (e.g., "2025/10/31, 10:26:04 – 10:30:49")
  - Placeholder text for activities with no additional info: "(No additional information available)"
  - App icons and names for each entry

**Key UI Elements Visible**:
- Radio button group at top-right showing first button selected
- Disclosure triangles in both expanded (▼) and collapsed (▶) states
- Sub-entries with varying detail levels
- Project-based grouping hierarchy
- App icons beside project/activity names
- Duration column with proper right-alignment
- Proper indentation showing parent-child relationships

---

#### Figure 5: Activities View - Grouping Mode 2 (Alternative)
**File**: `05-activities-grouped.png`
**Location in Spec**: Section 3.1, subsection 5 (Activity Grouping Modes - Mode 2)
**Size**: 419 KB

**What it shows**:
- Activities view with **Mode 2 Grouping** (second radio button selected)
- Alternative organization structure compared to Mode 1:
  - Groups reorganized with different grouping criteria
  - Could be organized by time periods (Today, Yesterday, This Week, etc.) or by category
  - Same activity data but reorganized/re-grouped
- Demonstrating how switching grouping modes reorganizes the same activities differently
- Visual hierarchy shows different grouping relationships
- Disclosure triangles function identically to Mode 1
- Group headers display appropriate sub-totals for new grouping structure

**Key UI Elements Visible**:
- Radio button group showing second button selected (changed from Figure 4)
- Reorganized activity hierarchy (different grouping structure)
- Alternative grouping criteria applied
- Same dataset but different presentation/organization
- Disclosure triangles work consistently across modes
- Visual transition showing list reorganization

---

#### Figure 6: Activities View - Grouping Mode 3 (Alternative)
**File**: `06-activities-third-group.png`
**Location in Spec**: Section 3.1, subsection 5 (Activity Grouping Modes - Mode 3)
**Size**: 419 KB

**What it shows**:
- Activities view with **Mode 3 Grouping** (third radio button selected)
- Third alternative organization method:
  - Most different presentation from Modes 1 and 2
  - Could be timeline-based, context-based, or custom organization
  - Activities grouped according to Mode 3's specific criteria
- Demonstrating the maximum flexibility in how activities can be reorganized/reorganized
- Visual structure differs significantly from both Mode 1 and Mode 2
- Grouping structure optimized for different analysis/workflow perspective

**Key UI Elements Visible**:
- Radio button group showing third button selected (all three modes now demonstrated)
- Third unique grouping structure
- Different organizational logic from previous two modes
- Disclosure triangles maintained and functional
- Consistent column layout (Duration | Details) across all grouping modes
- Visual consistency in row styling despite different organization

---

#### Figure 7: Activity Expansion Detail View
**File**: `07-expanded-app-detail.png`
**Location in Spec**: Section 3.1, subsection 6 (Activity Expansion Behaviors)
**Size**: 430 KB

**What it shows**:
- Detailed view demonstrating **expanded activity rows** with different expansion effects
- Multiple rows in various expanded states showing:
  - Rows with "(No additional information available)" placeholder text
  - Rows with detailed timestamp ranges (e.g., "2025/10/31, 10:26:04 – 10:30:49")
  - Sub-entries for different app types showing varying detail levels
- Demonstrating **app-specific expansion behaviors**:
  - Applications with rich metadata (timestamps, context info) expanded
  - Applications with minimal data showing simple placeholder text
  - Consistent row spacing (31px) and indentation across all expansion types
- Visual distinction between:
  - Parent rows (expanded groups)
  - Child rows (individual time entries)
  - Different indentation levels showing hierarchy
- Duration values visible on both parent groups and expanded children
- Color-coded app icons next to activity names

**Key UI Elements Visible**:
- Disclosure triangles in expanded (▼) state for multiple rows
- Sub-entry rows with consistent, clean formatting
- Different content types for different applications:
  - Apps with timestamp data (time-tracing, code editing sessions)
  - Apps with basic data (simple app usage)
  - System apps with minimal metadata
- Proper hierarchical indentation (main rows at 344px, child rows at 384px/404px)
- Duration values right-aligned in left column
- App icons (18x18px) beside activity names
- Clear visual hierarchy and structure

---

## Grouping Modes Overview

**Figure 4, 5, and 6 together demonstrate**:
- How users can switch between three different organizational modes using radio buttons
- That the same time-tracking data can be viewed in three different ways
- How each mode reorganizes activities according to different criteria
- That all modes maintain consistent UI patterns (disclosure triangles, columns, spacing)
- The flexibility of the Activities view for different analysis needs

---

## How to Use These Screenshots

1. **For Development Reference**: Use these screenshots to understand the actual layout and styling of each view
2. **For Design System**: Compare the screenshots with the CSS specifications in Section 12 of the main specification
3. **For Component Testing**: Verify that implemented components match the visual appearance shown in these screenshots
4. **For User Documentation**: Include these in end-user guides to explain the different views

## Screenshot Viewing Tips

- **Zoom In**: Right-click and select "Open Image in New Tab" for full-size viewing
- **Measurements**: Use browser developer tools to measure exact pixel positions
- **Colors**: Use color picker tools to extract exact color values matching the color palette (Appendix B)
- **Typography**: Compare text sizes and weights with the typography scale (Appendix C)

## Document Version
- **Screenshots Added**: October 31, 2025
- **Specification Version**: 1.2
- **Total Images**: 7 screenshots
  - 3 main view screenshots (Figures 1-3)
  - 4 activity view detail screenshots (Figures 4-7)
- **Recommended Screen Resolution**: 2560×1440 (as captured)
- **Total Screenshot Size**: 2.7 MB

---

## What's New in Version 1.2

**Added Content**:
- **Figures 4-7**: Detailed screenshots of Activity View grouping modes and expansion behaviors
- **Section 3.1 (subsections 5-6)**: Complete documentation of:
  - Three activity grouping modes (Unified, Grouped, Alternative)
  - App-specific expansion behaviors
  - Different metadata display types
  - Radio button interaction and transitions
- **Section 4.7**: New interaction flow for switching grouping modes

**Enhanced Documentation**:
- Detailed breakdown of how different applications expand differently
- Explanation of placeholder text and timestamp information
- Visual specification of grouping mode organizational logic
- Screenshots demonstrating all three grouping modes in action

---

*For more information, refer to the main Timing_UI_Spec.md file sections 3.1-3.3 (main views) and 4.7 (grouping mode interactions).*
