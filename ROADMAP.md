# TraceAI Feature Roadmap

## Overview
Complete feature plan for TraceAI - an AI-powered PCB design tool. Features are ordered by dependency and priority.

---

## Phase 1: Foundation & Polish
*Get the basics solid before building the editor*

### 1.1 Complete Authentication
- [x] GitHub OAuth sign-in
- [ ] Google OAuth sign-in
- [ ] Sign out functionality working properly
- [ ] Session persistence across tabs

### 1.2 User Profile Improvements
- [ ] Avatar upload working (Supabase Storage)
- [ ] Edit profile saves to database
- [ ] Delete account option

### 1.3 Pricing Page
- [ ] Create `pricing.html`
- [ ] Free, Pro, Enterprise tiers
- [ ] Feature comparison table
- [ ] Stripe integration for payments (later)

### 1.4 Static Pages
- [ ] Features page (`features.html`)
- [ ] Documentation page (`docs.html`)
- [ ] Contact/Support page

---

## Phase 2: Project Management
*Users need to create and manage projects before editing*

### 2.1 Project CRUD
- [ ] Create new project (name, description)
- [ ] List user's projects on profile page (from database)
- [ ] Open/load a project
- [ ] Delete project
- [ ] Rename project

### 2.2 Project Data Structure
```javascript
{
  id: uuid,
  user_id: uuid,
  name: string,
  description: string,
  schematic_data: json,  // Circuit schematic
  pcb_data: json,        // PCB layout
  components: json,      // Components used
  created_at: timestamp,
  updated_at: timestamp
}
```

### 2.3 Project Thumbnails
- [ ] Auto-generate thumbnail when saving
- [ ] Display on project cards

---

## Phase 3: PCB Editor - Core Canvas
*The main editor interface*

### 3.1 Editor Page Layout
- [ ] Create `editor.html`
- [ ] Left sidebar: Component library
- [ ] Center: Canvas/workspace
- [ ] Right sidebar: Properties panel
- [ ] Top toolbar: Tools
- [ ] Bottom: AI Assistant panel

### 3.2 Canvas Foundation
- [ ] HTML5 Canvas or SVG workspace
- [ ] Pan and zoom controls
- [ ] Grid overlay (snap to grid)
- [ ] Rulers (optional)
- [ ] Layer visibility toggles

### 3.3 Basic Interactions
- [ ] Select objects
- [ ] Move objects (drag)
- [ ] Delete objects
- [ ] Undo/Redo stack
- [ ] Copy/Paste

---

## Phase 4: Component Library
*Electronic components to place on the board*

### 4.1 Built-in Components
- [ ] Resistors, Capacitors, Inductors
- [ ] Diodes, LEDs
- [ ] Transistors (NPN, PNP, MOSFET)
- [ ] ICs (DIP, SOIC packages)
- [ ] Connectors (headers, USB, etc.)
- [ ] Microcontrollers (Arduino, ESP32 footprints)

### 4.2 Component Properties
- [ ] Footprint (physical shape)
- [ ] Symbol (schematic representation)
- [ ] Pin definitions
- [ ] Datasheet link
- [ ] Part number / value

### 4.3 Component Placement
- [ ] Drag from library to canvas
- [ ] Rotate (90°, 45°)
- [ ] Flip horizontal/vertical
- [ ] Align tools

### 4.4 User Libraries
- [ ] Save custom components
- [ ] Import/export libraries

---

## Phase 5: PCB Design Tools
*Actual PCB layout functionality*

### 5.1 Routing
- [ ] Manual trace drawing
- [ ] Trace width selection
- [ ] Via placement
- [ ] Net highlighting

### 5.2 Layers
- [ ] Top copper
- [ ] Bottom copper
- [ ] Silkscreen (top/bottom)
- [ ] Solder mask
- [ ] Board outline

### 5.3 Design Rules
- [ ] Minimum trace width
- [ ] Minimum clearance
- [ ] Via sizes
- [ ] DRC (Design Rule Check)

### 5.4 Board Setup
- [ ] Board dimensions
- [ ] Board shape (rectangle, custom)
- [ ] Mounting holes
- [ ] Layer stackup

---

## Phase 6: Schematic Editor
*Circuit diagram before PCB layout*

### 6.1 Schematic Canvas
- [ ] Separate schematic view
- [ ] Symbol placement
- [ ] Wire drawing
- [ ] Net labels
- [ ] Power/Ground symbols

### 6.2 Schematic ↔ PCB Sync
- [ ] Generate PCB from schematic
- [ ] Netlist creation
- [ ] Forward/back annotation

---

## Phase 7: AI Integration (Claude Opus 4)
*The key differentiator*

### 7.1 AI Chat Interface
- [ ] Chat panel in editor
- [ ] Send design context to AI
- [ ] Display AI responses

### 7.2 AI Capabilities
- [ ] Answer PCB design questions
- [ ] Suggest component values
- [ ] Review design for issues
- [ ] Explain circuits

### 7.3 AI-Assisted Design
- [ ] Auto-routing suggestions
- [ ] Component placement optimization
- [ ] DRC fix suggestions
- [ ] BOM optimization (cheaper alternatives)

### 7.4 AI Commands
- [ ] "Route this net"
- [ ] "Check my design"
- [ ] "Suggest decoupling capacitors"
- [ ] "Optimize for manufacturing"

---

## Phase 8: Export & Manufacturing
*Getting the design made*

### 8.1 Export Formats
- [ ] Gerber files (RS-274X)
- [ ] Excellon drill files
- [ ] Pick and place file
- [ ] BOM (Bill of Materials) CSV/Excel
- [ ] PDF schematic

### 8.2 Manufacturing Integration
- [ ] PCBWay integration
- [ ] JLCPCB integration
- [ ] Instant quotes
- [ ] One-click order

---

## Phase 9: Collaboration
*Team features*

### 9.1 Sharing
- [ ] Share project link (view only)
- [ ] Share with edit access
- [ ] Public/private projects

### 9.2 Real-time Collaboration
- [ ] Multiple cursors
- [ ] Live updates
- [ ] Comments on design

### 9.3 Version History
- [ ] Auto-save versions
- [ ] Compare versions
- [ ] Restore previous version

---

## Phase 10: Polish & Monetization
*Final touches*

### 10.1 Stripe Integration
- [ ] Subscription checkout
- [ ] Manage subscription
- [ ] Usage limits by plan

### 10.2 Performance
- [ ] Optimize canvas rendering
- [ ] Lazy load components
- [ ] Offline support (PWA)

### 10.3 Mobile Support
- [ ] Responsive editor (view mode)
- [ ] Touch interactions

---

## Recommended Order of Implementation

| Priority | Feature | Effort | Impact |
|----------|---------|--------|--------|
| 1 | Project CRUD | Low | High |
| 2 | Editor page layout | Medium | High |
| 3 | Basic canvas (pan/zoom/grid) | Medium | High |
| 4 | Component library (basic) | Medium | High |
| 5 | Component placement | Medium | High |
| 6 | AI Chat interface | Medium | Very High |
| 7 | Manual routing | High | High |
| 8 | Save/load projects | Medium | High |
| 9 | Export (Gerber) | High | High |
| 10 | Pricing page + Stripe | Medium | Medium |

---

## Tech Stack

- **Frontend**: HTML/CSS/JS (vanilla for now, can add React later)
- **Canvas**: HTML5 Canvas or Fabric.js / Konva.js
- **Backend**: Supabase (auth, database, storage)
- **AI**: Claude API (Anthropic)
- **Payments**: Stripe
