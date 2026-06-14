---
name: Emerald Stealth
colors:
  surface: '#121414'
  surface-dim: '#121414'
  surface-bright: '#383939'
  surface-container-lowest: '#0d0e0f'
  surface-container-low: '#1a1c1c'
  surface-container: '#1e2020'
  surface-container-high: '#292a2a'
  surface-container-highest: '#343535'
  on-surface: '#e3e2e2'
  on-surface-variant: '#bbcbb8'
  inverse-surface: '#e3e2e2'
  inverse-on-surface: '#2f3131'
  outline: '#869583'
  outline-variant: '#3c4a3c'
  surface-tint: '#3ce36a'
  primary: '#3fe56c'
  on-primary: '#003912'
  primary-container: '#00c853'
  on-primary-container: '#004c1b'
  inverse-primary: '#006e2a'
  secondary: '#c8c6c5'
  on-secondary: '#313030'
  secondary-container: '#4a4949'
  on-secondary-container: '#bab8b7'
  tertiary: '#cbc8c8'
  on-tertiary: '#303030'
  tertiary-container: '#afadad'
  on-tertiary-container: '#414141'
  error: '#ffb4ab'
  on-error: '#690005'
  error-container: '#93000a'
  on-error-container: '#ffdad6'
  primary-fixed: '#69ff87'
  primary-fixed-dim: '#3ce36a'
  on-primary-fixed: '#002108'
  on-primary-fixed-variant: '#00531e'
  secondary-fixed: '#e5e2e1'
  secondary-fixed-dim: '#c8c6c5'
  on-secondary-fixed: '#1c1b1b'
  on-secondary-fixed-variant: '#474646'
  tertiary-fixed: '#e5e2e1'
  tertiary-fixed-dim: '#c8c6c5'
  on-tertiary-fixed: '#1b1b1c'
  on-tertiary-fixed-variant: '#474746'
  background: '#121414'
  on-background: '#e3e2e2'
  surface-variant: '#343535'
typography:
  display-lg:
    fontFamily: Inter
    fontSize: 40px
    fontWeight: '700'
    lineHeight: 48px
    letterSpacing: -0.02em
  display-lg-mobile:
    fontFamily: Inter
    fontSize: 32px
    fontWeight: '700'
    lineHeight: 38px
    letterSpacing: -0.02em
  headline-md:
    fontFamily: Inter
    fontSize: 24px
    fontWeight: '600'
    lineHeight: 32px
    letterSpacing: -0.01em
  body-lg:
    fontFamily: Inter
    fontSize: 16px
    fontWeight: '400'
    lineHeight: 24px
    letterSpacing: 0em
  body-sm:
    fontFamily: Inter
    fontSize: 14px
    fontWeight: '400'
    lineHeight: 20px
    letterSpacing: 0em
  label-upper:
    fontFamily: Inter
    fontSize: 12px
    fontWeight: '600'
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
  container-margin: 20px
  gutter: 16px
  stack-sm: 8px
  stack-md: 16px
  stack-lg: 24px
  section-padding: 32px
---

## Brand & Style
The design system is engineered for a high-tech, professional environment where precision and trustworthiness are paramount. It leans into a **Corporate Modern** aesthetic fused with **Glassmorphism**, utilizing deep charcoal tones to provide a focused, low-strain backdrop that allows vibrant emerald accents to command attention. 

The visual language communicates sophistication through:
- **Depth and Layering:** Semi-transparent surfaces and subtle blurs create a structured hierarchy.
- **Precision:** Tight tracking and crisp, low-contrast borders imply a meticulous attention to detail.
- **Vibrancy:** Emerald green serves as the primary "action" signal, representing growth, success, and system health.

## Colors
This design system utilizes a "Stealth" palette. The background is a near-black charcoal, providing maximum contrast for the Emerald Green (#00C853) primary color. 

- **Primary Emerald:** Reserved for primary actions, success states, and key data highlights.
- **Deep Charcoal Surfaces:** Used for containers to establish a subtle lift from the background without harsh transitions.
- **Glassmorphism Strokes:** Borders should use a low-opacity white (8-12%) to create a "glass edge" effect rather than a solid grey line.
- **Functional Greys:** Text scales from pure white for headings to muted grey (#9E9E9E) for secondary labels and metadata.

## Typography
The system relies exclusively on **Inter** for its neutral, highly legible, and technical character. 

- **Tightened Tracking:** Headlines and display styles use negative letter spacing (-0.01em to -0.02em) to appear more compact and professional.
- **Hierarchy through Contrast:** Large, bold white headings should be paired with smaller, medium-weight labels in the primary emerald color or muted grey.
- **Scale:** Maintain a clear distinction between data points (which should be bold and legible) and descriptive text (which should be secondary).

## Layout & Spacing
The layout follows a **Fluid Grid** logic with a focus on high information density. 

- **Density:** Elements are packed closely to allow for maximum data visibility, but clear horizontal separators and card boundaries prevent visual clutter.
- **Horizontal Flow:** Use horizontal scrolling for categorized lists (e.g., "Resume Templates" or "Skill Badges") to maximize vertical real estate.
- **Safe Areas:** A standard 20px margin is maintained on mobile devices to ensure content doesn't hit the bezel, while desktop layouts utilize a centered 12-column max-width grid.
- **Card-Based Architecture:** Group related information into distinct cards with 16px internal padding.

## Elevation & Depth
Depth is achieved through **Backdrop Blurs** and **Tonal Layering** rather than traditional drop shadows.

- **Surface Tiers:** 
  - Level 0: Pure Background (#0A0A0A).
  - Level 1: Inset containers with subtle borders.
  - Level 2: Glassmorphic cards with a 12px backdrop-blur and 8% white stroke.
- **Soft Glows:** Critical primary buttons may feature a very subtle, low-opacity emerald outer glow (blur: 20px, opacity: 15%) to simulate a light-emitting interface.
- **Interactive States:** On hover or tap, cards should increase in stroke opacity rather than shifting their Y-axis position.

## Shapes
The shape language is defined by large, friendly radii that contrast with the technical typography.

- **Primary Cards:** Use a **16px to 24px** radius (rounded-xl) to create a modern, approachable feel.
- **Buttons and Inputs:** Should follow the **16px** standard to maintain consistency with the cards.
- **Chips/Badges:** Utilize full pill-shaped rounding for high-contrast labels and status indicators.
- **Icons:** Set within circular or highly rounded square containers to maintain the "soft-tech" aesthetic.

## Components
- **Buttons:** 
  - *Primary:* Solid Emerald Green background with black text for maximum legibility.
  - *Secondary:* Transparent with an 8% white border and white text.
- **Input Fields:** Darker than the surface level with a subtle 1px border. The border turns Emerald Green when the field is focused.
- **Cards:** The workhorse of the design system. Must include a `1px` white stroke at `0.08` opacity and a background blur. 
- **Progress Indicators:** Use the Primary Emerald for active states against a dark grey track.
- **Chips:** Small, pill-shaped markers used for "AI-Generated" tags or skill levels. These should have a low-opacity emerald background and solid emerald text.
- **Lists:** Clean rows with 1px dividers. Use right-aligned chevrons or metadata to indicate drill-down capability.