---
name: High-Contrast Precision
colors:
  surface: '#f8f9fa'
  surface-dim: '#d9dadb'
  surface-bright: '#f8f9fa'
  surface-container-lowest: '#ffffff'
  surface-container-low: '#f3f4f5'
  surface-container: '#edeeef'
  surface-container-high: '#e7e8e9'
  surface-container-highest: '#e1e3e4'
  on-surface: '#191c1d'
  on-surface-variant: '#5b403d'
  inverse-surface: '#2e3132'
  inverse-on-surface: '#f0f1f2'
  outline: '#8f6f6c'
  outline-variant: '#e4beba'
  surface-tint: '#ba1a20'
  primary: '#af101a'
  on-primary: '#ffffff'
  primary-container: '#d32f2f'
  on-primary-container: '#fff2f0'
  inverse-primary: '#ffb3ac'
  secondary: '#635d5d'
  on-secondary: '#ffffff'
  secondary-container: '#eae0e0'
  on-secondary-container: '#696363'
  tertiary: '#585757'
  on-tertiary: '#ffffff'
  tertiary-container: '#706f6f'
  on-tertiary-container: '#f7f4f3'
  error: '#ba1a1a'
  on-error: '#ffffff'
  error-container: '#ffdad6'
  on-error-container: '#93000a'
  primary-fixed: '#ffdad6'
  primary-fixed-dim: '#ffb3ac'
  on-primary-fixed: '#410003'
  on-primary-fixed-variant: '#930010'
  secondary-fixed: '#eae0e0'
  secondary-fixed-dim: '#cdc4c4'
  on-secondary-fixed: '#1f1b1b'
  on-secondary-fixed-variant: '#4b4546'
  tertiary-fixed: '#e5e2e1'
  tertiary-fixed-dim: '#c8c6c5'
  on-tertiary-fixed: '#1c1b1b'
  on-tertiary-fixed-variant: '#474746'
  background: '#f8f9fa'
  on-background: '#191c1d'
  surface-variant: '#e1e3e4'
typography:
  headline-xl:
    fontFamily: Plus Jakarta Sans
    fontSize: 48px
    fontWeight: '800'
    lineHeight: 56px
    letterSpacing: -0.02em
  headline-lg:
    fontFamily: Plus Jakarta Sans
    fontSize: 32px
    fontWeight: '700'
    lineHeight: 40px
    letterSpacing: -0.01em
  headline-lg-mobile:
    fontFamily: Plus Jakarta Sans
    fontSize: 28px
    fontWeight: '700'
    lineHeight: 34px
  headline-md:
    fontFamily: Plus Jakarta Sans
    fontSize: 24px
    fontWeight: '700'
    lineHeight: 32px
  body-lg:
    fontFamily: Plus Jakarta Sans
    fontSize: 18px
    fontWeight: '400'
    lineHeight: 28px
  body-md:
    fontFamily: Plus Jakarta Sans
    fontSize: 16px
    fontWeight: '400'
    lineHeight: 24px
  label-md:
    fontFamily: Plus Jakarta Sans
    fontSize: 14px
    fontWeight: '600'
    lineHeight: 20px
    letterSpacing: 0.05em
  label-sm:
    fontFamily: Plus Jakarta Sans
    fontSize: 12px
    fontWeight: '700'
    lineHeight: 16px
rounded:
  sm: 0.25rem
  DEFAULT: 0.5rem
  md: 0.75rem
  lg: 1rem
  xl: 1.5rem
  full: 9999px
spacing:
  base: 8px
  container-max: 1280px
  gutter: 24px
  margin-mobile: 16px
  margin-desktop: 40px
---

## Brand & Style
The brand personality is energetic and authoritative, designed to instill confidence in job seekers. The aesthetic blends **High-Contrast Boldness** with **Modern Professionalism**, utilizing a striking red palette to draw attention to critical career milestones and calls to action. 

The UI should feel precise and high-velocity, minimizing visual clutter to focus on content clarity. It uses sharp color transitions and ample whitespace to maintain a sophisticated, editorial feel that differentiates it from typical corporate SaaS platforms.

## Colors
This design system utilizes a high-impact primary red (`#D32F2F`) against a stark white background to create a sense of urgency and importance. 

- **Primary Red:** Used for primary actions, branding, and highlighting key data points.
- **Surface Tint:** A very soft red/pink (`#FFF5F5`) is used for secondary backgrounds, hover states, and to soften large structural areas.
- **Deep Neutral:** A near-black (`#1A1A1A`) provides high-contrast legibility for headings and primary text.
- **Background:** Pure white (`#FFFFFF`) is the default canvas to ensure the resume content remains the focal point.

## Typography
The typography system relies exclusively on **Plus Jakarta Sans** to maintain a modern, geometric, yet approachable feel. 

Headlines use heavy weights (Bold/ExtraBold) and tighter letter-spacing to create a strong visual hierarchy. Body text is kept clean with generous line heights to ensure readability during long editing sessions. Labels are frequently used in uppercase with slight tracking to provide a technical, "scannable" look for resume sections and metadata.

## Layout & Spacing
The system follows a **Fixed Grid** philosophy for desktop to mirror the structured nature of a physical resume, while transitioning to a fluid model for mobile devices.

- **Grid:** A 12-column grid system is used for dashboard layouts, while the resume editor uses a centered 8-column stack.
- **Rhythm:** Spacing follows an 8px linear scale. Large components (cards) should use 24px or 32px internal padding to maintain the "premium" airy feel.
- **Breakpoints:** Mobile (<640px), Tablet (640px - 1024px), and Desktop (>1024px). On mobile, horizontal margins shrink to 16px to maximize real estate.

## Elevation & Depth
Depth is achieved through **Tonal Layers** rather than heavy shadows to maintain the high-contrast aesthetic.

- **Level 0 (Base):** White background.
- **Level 1 (Cards):** Soft Red background (`#FFF5F5`) with no shadow, or White background with a subtle 1px border in a pale gray.
- **Floating Elements:** Primary action menus use a high-diffusion, low-opacity red-tinted shadow (e.g., `rgba(211, 47, 47, 0.08)`) to suggest elevation without breaking the flat design language.
- **Interactive States:** Hovering over a card should trigger a slight lift (2px Y-offset) and a subtle increase in border-contrast.

## Shapes
The design system employs a **hybrid rounding strategy** to balance approachability with structural precision:

- **Cards & Containers:** 12px (`rounded-lg`) corner radius to provide a friendly, modern container for data.
- **Buttons & Chips:** Full pill (`9999px`) roundedness to create a distinct interactive language that contrasts against the rectangular grid.
- **Form Inputs:** 8px (`rounded-md`) to maintain a clean, professional alignment with the text.

## Components
- **Buttons:** Primary buttons are Solid Red (`#D32F2F`) with White text and a full pill shape. Secondary buttons use the Soft Red background with Red text.
- **Cards:** White backgrounds with 12px rounded corners. Use a 1px border of `#F0F0F0` to define edges against the white background.
- **Input Fields:** Minimalist design with a 1px bottom border that turns into a 2px Red border on focus. Backgrounds are slightly off-white.
- **Chips/Badges:** Pill-shaped with the Soft Red background and Red text for status indicators or skills.
- **Lists:** Clean rows separated by subtle 1px lines. Use Primary Red for bullet points or icons to lead the eye.
- **Progress Indicators:** Use the Primary Red for active completion states, representing the high-energy "Precision" aspect of the brand.