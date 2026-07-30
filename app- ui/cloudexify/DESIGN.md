---
name: CloudExify
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
    letterSpacing: -0.25px
  headline-lg:
    fontFamily: Inter
    fontSize: 32px
    fontWeight: '600'
    lineHeight: 40px
  headline-lg-mobile:
    fontFamily: Inter
    fontSize: 28px
    fontWeight: '600'
    lineHeight: 36px
  headline-md:
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
    letterSpacing: 0.15px
  body-lg:
    fontFamily: Inter
    fontSize: 16px
    fontWeight: '400'
    lineHeight: 24px
    letterSpacing: 0.5px
  body-md:
    fontFamily: Inter
    fontSize: 14px
    fontWeight: '400'
    lineHeight: 20px
    letterSpacing: 0.25px
  label-lg:
    fontFamily: Inter
    fontSize: 14px
    fontWeight: '500'
    lineHeight: 20px
    letterSpacing: 0.1px
  label-sm:
    fontFamily: Inter
    fontSize: 11px
    fontWeight: '500'
    lineHeight: 16px
    letterSpacing: 0.5px
rounded:
  sm: 0.25rem
  DEFAULT: 0.5rem
  md: 0.75rem
  lg: 1rem
  xl: 1.5rem
  full: 9999px
spacing:
  base: 4px
  xs: 4px
  sm: 8px
  md: 16px
  lg: 24px
  xl: 32px
  2xl: 48px
  gutter: 16px
  margin-mobile: 16px
  margin-tablet: 32px
  margin-desktop: auto
---

## Brand & Style
The design system is engineered for an anonymous sharing environment that prioritizes user safety and trust without sacrificing premium aesthetics. The brand personality is **discreet, secure, and sophisticated**. It balances the functional requirements of an anonymous platform with a high-end, editorial feel.

The style is a refined interpretation of **Material Design 3**, leaning heavily into **Modern Minimalism** and **Glassmorphism**. It utilizes expansive white space to reduce cognitive load and premium "floating" surfaces to create a sense of lightness and transparency. The visual language conveys that while the user is anonymous, the experience is high-fidelity and professional. Key characteristics include:
- **Discreet Presence:** Non-intrusive UI that lets user-generated content lead.
- **Glassmorphic Accents:** Occasional backdrop blurs on navigation bars and overlays to suggest depth.
- **Precision:** Pixel-perfect alignment and consistent stroke weights to reinforce a sense of security and quality.

## Colors
This design system utilizes a sophisticated blue-centric palette to evoke feelings of calm and reliability—crucial for an anonymous platform.

- **Primary & Secondary:** These blues are used for core actions and active states. The primary #2563EB is the anchor for brand recognition.
- **Surface Strategy:** The background uses a cool-toned #F8FAFC, allowing pure white cards (#FFFFFF) to pop with subtle contrast.
- **Functional Colors:** Success, Warning, and Error colors follow standard semantic conventions but are calibrated for high legibility against the light background.
- **Transparency:** Use 80% opacity versions of the background and card colors for glassmorphic elements.

## Typography
The system relies on **Inter** for its exceptional legibility and neutral, modern character. This choice ensures that anonymous "secrets" or shares are easy to read in various contexts.

- **Scale:** Following Material 3 logic, the scale is divided into Display, Headline, Title, Body, and Label roles.
- **Hierarchy:** Headlines are semi-bold to provide structure, while body text uses a generous line height for long-form reading comfort.
- **Mobile Adaptation:** Large headlines scale down on mobile to prevent awkward text wrapping, ensuring "Guest Mode" remains clean and professional.
- **Alternative:** For iOS implementations, **SF Pro Display** should be used following the same size and weight mapping to maintain platform-native feel.

## Layout & Spacing
The layout follows a **fluid grid** model optimized for the Android handheld experience. It emphasizes a "content-first" approach where padding is used generously to separate thoughts and shares.

- **Grid System:** A 4-column grid for mobile and 8-column for tablet. 
- **Margins:** 16px horizontal margins on mobile to maximize horizontal real estate while maintaining clear boundaries.
- **Rhythm:** An 8pt grid system governs all vertical and horizontal spacing to ensure a pixel-perfect, balanced look.
- **Guest Mode Layout:** Navigation should be simplified, often using a bottom-bar or floating action button (FAB) for primary interactions like "Share" or "Post."

## Elevation & Depth
In this design system, depth is communicated through **Soft Shadows** and **Tonal Layers** rather than heavy gradients.

- **Level 0 (Surface):** The background (#F8FAFC) is the lowest level.
- **Level 1 (Cards):** Cards use a pure white surface with a very soft, diffused shadow (Blur: 12px, Y: 4, Opacity: 0.04, Color: #111827).
- **Level 2 (Active/Hover):** Interactive cards or buttons elevate slightly on press (Blur: 20px, Y: 8, Opacity: 0.08).
- **Glassmorphism:** Navigation headers and bottom tabs use a background blur (20px) with 85% opacity to create a sense of orientation and context without blocking the content flow.
- **Material Symbols:** Use "Rounded" Material Symbols with a 200 weight for a lightweight, premium feel.

## Shapes
The shape language is defined by **Rounded** geometry to evoke friendliness and safety—essential for an anonymous community.

- **Standard Elements:** Buttons, input fields, and standard cards use a 0.5rem (8px) radius.
- **Container Elements:** Large content cards or featured sections use `rounded-lg` (1rem / 16px) or `rounded-xl` (1.5rem / 24px) for a more modern, "app-like" feel.
- **Full Rounded:** Chips and Floating Action Buttons use pill-shapes (full-radius) to differentiate them as distinct, actionable elements.

## Components
- **Buttons:** Primary buttons use the #2563EB fill with white text. Secondary buttons are outlined or tonal. All have a minimum touch target of 48dp.
- **Anonymous Cards:** Content cards are white with `rounded-xl` corners. They feature generous internal padding (16px - 24px).
- **Chips:** Used for category tags. High-contrast labels on a soft blue background (#EFF6FF).
- **Input Fields:** Outlined style with a subtle border (#E2E8F0). On focus, the border transitions to Primary Blue with a 2px stroke.
- **Glass Bottom Bar:** The main navigation uses a backdrop-blur (saturate 180%, blur 20px) with a semi-transparent white background for a premium modern feel.
- **Guest Mode Banner:** A subtle, non-intrusive banner at the top or bottom of the screen to remind users of their status without interrupting the flow.
- **Material Symbols Rounded:** Icons should be used sparingly, prioritizing clear labels for primary navigation.