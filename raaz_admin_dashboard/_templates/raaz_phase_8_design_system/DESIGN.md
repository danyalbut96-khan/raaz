---
name: RAAZ Phase 8 Design System
colors:
  surface: '#f9f9ff'
  surface-dim: '#d3daef'
  surface-bright: '#f9f9ff'
  surface-container-lowest: '#ffffff'
  surface-container-low: '#f1f3ff'
  surface-container: '#e9edff'
  surface-container-high: '#e1e8fd'
  surface-container-highest: '#dce2f7'
  on-surface: '#141b2b'
  on-surface-variant: '#434655'
  inverse-surface: '#293040'
  inverse-on-surface: '#edf0ff'
  outline: '#737686'
  outline-variant: '#c3c6d7'
  surface-tint: '#0053db'
  primary: '#004ac6'
  on-primary: '#ffffff'
  primary-container: '#2563eb'
  on-primary-container: '#eeefff'
  inverse-primary: '#b4c5ff'
  secondary: '#0058be'
  on-secondary: '#ffffff'
  secondary-container: '#2170e4'
  on-secondary-container: '#fefcff'
  tertiary: '#00569c'
  on-tertiary: '#ffffff'
  tertiary-container: '#196fc0'
  on-tertiary-container: '#ebf1ff'
  error: '#ba1a1a'
  on-error: '#ffffff'
  error-container: '#ffdad6'
  on-error-container: '#93000a'
  primary-fixed: '#dbe1ff'
  primary-fixed-dim: '#b4c5ff'
  on-primary-fixed: '#00174b'
  on-primary-fixed-variant: '#003ea8'
  secondary-fixed: '#d8e2ff'
  secondary-fixed-dim: '#adc6ff'
  on-secondary-fixed: '#001a42'
  on-secondary-fixed-variant: '#004395'
  tertiary-fixed: '#d4e3ff'
  tertiary-fixed-dim: '#a4c9ff'
  on-tertiary-fixed: '#001c39'
  on-tertiary-fixed-variant: '#004883'
  background: '#f9f9ff'
  on-background: '#141b2b'
  surface-variant: '#dce2f7'
typography:
  display-lg:
    fontFamily: Inter
    fontSize: 57px
    fontWeight: '700'
    lineHeight: 64px
    letterSpacing: -0.02em
  headline-lg:
    fontFamily: Inter
    fontSize: 32px
    fontWeight: '600'
    lineHeight: 40px
    letterSpacing: -0.01em
  headline-lg-mobile:
    fontFamily: Inter
    fontSize: 28px
    fontWeight: '600'
    lineHeight: 36px
  title-lg:
    fontFamily: Inter
    fontSize: 22px
    fontWeight: '500'
    lineHeight: 28px
  title-md:
    fontFamily: Inter
    fontSize: 16px
    fontWeight: '500'
    lineHeight: 24px
    letterSpacing: 0.01em
  body-lg:
    fontFamily: Inter
    fontSize: 16px
    fontWeight: '400'
    lineHeight: 24px
  body-md:
    fontFamily: Inter
    fontSize: 14px
    fontWeight: '400'
    lineHeight: 20px
  label-lg:
    fontFamily: Inter
    fontSize: 14px
    fontWeight: '500'
    lineHeight: 20px
  label-sm:
    fontFamily: Inter
    fontSize: 11px
    fontWeight: '500'
    lineHeight: 16px
    letterSpacing: 0.05em
rounded:
  sm: 0.25rem
  DEFAULT: 0.5rem
  md: 0.75rem
  lg: 1rem
  xl: 1.5rem
  full: 9999px
spacing:
  unit: 4px
  xs: 4px
  sm: 8px
  md: 16px
  lg: 24px
  xl: 32px
  container-margin: 24px
  gutter: 24px
---

## Brand & Style
This design system is engineered for a premium Enterprise SaaS environment, balancing the rigorous logic of Material Design 3 with a refined, minimalist aesthetic. The target audience consists of high-level administrators and data analysts who require a tool that feels both powerful and effortless.

The design style is **Corporate / Modern** with subtle **Glassmorphic** accents. It prioritizes clarity through expansive whitespace, precise typography, and a "quiet" interface that recedes to let user data take center stage. The emotional response should be one of total control, reliability, and modern sophistication.

## Colors
The palette is rooted in a spectrum of authoritative blues. 
- **Primary (#2563EB)** is used for high-emphasis actions and active states.
- **Secondary and Tertiary** blues provide tonal variance for accents, hover states, and illustrative elements.
- **Background (#F8FAFC)** is a cool, desaturated slate that reduces eye strain compared to pure white, while **Surface (#FFFFFF)** handles the containment of interactive elements.
- **Status Colors** follow industry standards but are calibrated for high legibility against the light background.

## Typography
The system utilizes **Inter** for all roles to ensure maximum readability and a systematic, utilitarian feel across complex data densities. 

- **Headlines** use tighter letter spacing and semi-bold weights to create a strong hierarchy.
- **Body Text** maintains a generous line height (1.5x) to ensure long-form reports remain accessible.
- **Labels** are strictly used for navigation items, table headers, and form captions, often utilizing a slightly heavier weight to distinguish them from body content.

## Layout & Spacing
This system follows a **12-column fluid grid** for desktop and tablet, and a **4-column grid** for mobile. 

- **Desktop:** 24px margins and 24px gutters. Side navigation is fixed at 280px (expanded) or 80px (collapsed).
- **Spacing Rhythm:** Based on a 4px baseline grid. Most component spacing should use the `md (16px)` or `lg (24px)` tokens to maintain the "Large White Space" brand pillar.
- **Containers:** Main content area uses a maximum width of 1440px for readability, centering itself on ultra-wide displays.

## Elevation & Depth
Depth is communicated through **Tonal Layers** and **Ambient Shadows**, moving away from harsh borders.

- **Level 0 (Flat):** The background canvas (#F8FAFC).
- **Level 1 (Card/Surface):** White surface with a very soft, diffused shadow: `0px 2px 4px rgba(17, 24, 39, 0.05)`. Used for standard content cards.
- **Level 2 (Hover/Active):** Slightly deeper shadow: `0px 4px 12px rgba(17, 24, 39, 0.08)`.
- **Level 3 (Modals/Overlays):** `0px 12px 32px rgba(17, 24, 39, 0.12)`.
- **Glassmorphism:** Applied to the Side Navigation and Top Bar. These elements use a background blur (`backdrop-filter: blur(12px)`) and a 70% opacity white fill with a 1px inner white border to simulate light catching the edge of the glass.

## Shapes
In alignment with Material 3’s softer approach, the system uses a **Rounded** philosophy.
- **Standard Components:** Buttons, Input Fields, and Chips use a `0.5rem` (8px) radius.
- **Large Components:** Cards, Modals, and Bottom Sheets use `rounded-xl` (1.5rem / 24px) to create the signature premium look.
- **Icons:** Always use "Material Symbols Rounded" to maintain consistency with the UI's curved corners.

## Components

### Navigation
- **Side Navigation:** Uses a glassmorphic vertical bar. Active states are indicated by a "pill" background in the primary color (10% opacity) and a high-emphasis blue vertical bar on the leading edge.
- **Top Navigation:** Contains a centered search bar with a `rounded-lg` (16px) shape and a subtle inset shadow to denote input depth.

### Data Display
- **Data Tables:** Borderless design. Rows use a 1px bottom border in a very light neutral tint. Status chips are "Pill-shaped" with low-opacity background fills of the status color (e.g., Success status has #10B981 at 10% opacity).
- **Statistic Cards:** Large `title-lg` numbers. Trend indicators use green/red arrows with micro-animations that slide into place on load.
- **Charts:** Use a custom palette derived from the Primary and Secondary colors. Line charts should use a 3px stroke width with smoothed (bezier) curves.

### Interaction
- **Buttons:** Primary buttons use a solid fill with a gentle 2px elevation. Secondary buttons use a ghost style with a 1px border. All buttons must include a Material "Ripple" effect on click.
- **Dialogs & Sheets:** Dialogs appear centered with a Level 3 shadow. Bottom sheets are reserved for mobile/tablet views, sliding up with a 24px top-corner radius.
- **Loading Skeletons:** Use a subtle "shimmer" gradient moving from left to right, matching the background and surface colors for a seamless transition to real data.