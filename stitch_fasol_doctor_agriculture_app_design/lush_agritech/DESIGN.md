---
name: Lush Agritech
colors:
  surface: '#f8f9ff'
  surface-dim: '#d0dbed'
  surface-bright: '#f8f9ff'
  surface-container-lowest: '#ffffff'
  surface-container-low: '#eff4ff'
  surface-container: '#e6eeff'
  surface-container-high: '#dee9fc'
  surface-container-highest: '#d9e3f6'
  on-surface: '#121c2a'
  on-surface-variant: '#404940'
  inverse-surface: '#27313f'
  inverse-on-surface: '#eaf1ff'
  outline: '#707a6f'
  outline-variant: '#bfc9bd'
  surface-tint: '#1f6c3a'
  primary: '#004c22'
  on-primary: '#ffffff'
  primary-container: '#166534'
  on-primary-container: '#93e0a2'
  inverse-primary: '#8bd79b'
  secondary: '#904d00'
  on-secondary: '#ffffff'
  secondary-container: '#fe932c'
  on-secondary-container: '#663500'
  tertiary: '#004943'
  on-tertiary: '#ffffff'
  tertiary-container: '#00635b'
  on-tertiary-container: '#73e0d2'
  error: '#ba1a1a'
  on-error: '#ffffff'
  error-container: '#ffdad6'
  on-error-container: '#93000a'
  primary-fixed: '#a6f4b5'
  primary-fixed-dim: '#8bd79b'
  on-primary-fixed: '#00210b'
  on-primary-fixed-variant: '#005226'
  secondary-fixed: '#ffdcc3'
  secondary-fixed-dim: '#ffb77d'
  on-secondary-fixed: '#2f1500'
  on-secondary-fixed-variant: '#6e3900'
  tertiary-fixed: '#89f5e7'
  tertiary-fixed-dim: '#6bd8cb'
  on-tertiary-fixed: '#00201d'
  on-tertiary-fixed-variant: '#005049'
  background: '#f8f9ff'
  on-background: '#121c2a'
  surface-variant: '#d9e3f6'
typography:
  display-lg:
    fontFamily: Noto Sans
    fontSize: 32px
    fontWeight: '700'
    lineHeight: 44px
  headline-lg:
    fontFamily: Noto Sans
    fontSize: 26px
    fontWeight: '700'
    lineHeight: 36px
  headline-md:
    fontFamily: Noto Sans
    fontSize: 22px
    fontWeight: '600'
    lineHeight: 32px
  headline-sm:
    fontFamily: Noto Sans
    fontSize: 18px
    fontWeight: '600'
    lineHeight: 26px
  body-lg:
    fontFamily: Noto Sans
    fontSize: 18px
    fontWeight: '400'
    lineHeight: 28px
  body-md:
    fontFamily: Noto Sans
    fontSize: 16px
    fontWeight: '400'
    lineHeight: 24px
  body-sm:
    fontFamily: Noto Sans
    fontSize: 14px
    fontWeight: '500'
    lineHeight: 20px
  label-lg:
    fontFamily: Noto Sans
    fontSize: 16px
    fontWeight: '700'
    lineHeight: 22px
  label-md:
    fontFamily: Noto Sans
    fontSize: 14px
    fontWeight: '600'
    lineHeight: 18px
  label-sm:
    fontFamily: Noto Sans
    fontSize: 12px
    fontWeight: '600'
    lineHeight: 16px
rounded:
  sm: 0.25rem
  DEFAULT: 0.5rem
  md: 0.75rem
  lg: 1rem
  xl: 1.5rem
  full: 9999px
spacing:
  spacing-4: 0.25rem
  spacing-8: 0.5rem
  spacing-12: 0.75rem
  spacing-16: 1rem
  spacing-20: 1.25rem
  spacing-24: 1.5rem
  spacing-32: 2rem
  spacing-40: 2.5rem
  spacing-48: 3rem
  touch-target-min: 3.25rem
  screen-margin-mobile: 1rem
  card-padding: 1.25rem
---

## Brand & Style

This design system serves smallholder agricultural producers in rural and semi-urban Bangladesh who often interface with smartphones in bright daylight, with varying degrees of digital literacy and device performance. 

The aesthetic is **Tactile Modern Organic**: rooted in lush delta flora, sun-drenched harvest hues, and immediate physical clarity. It balances deep institutional trustworthiness with welcoming, human-centered warmth. 

### Core Tenets
- **High-Affordance Tactility**: Controls look unambiguously interactive. Surfaces suggest clear physical layers, buttons appear distinct and pressing, and affordances rely on color weight and structural borders rather than subtle conceptual cues.
- **Sunlight Readability**: Contrast ratios exceed standard WCAG AAA thresholds where possible. Crisp boundaries and high-density typography prevent wash-out under harsh outdoor sunlight.
- **Single-Path Clarity**: Every primary view focuses on one unequivocal task. Visual noise is stripped away to alleviate cognitive load for low-literacy users.
- **Iconic & Audio-Visual First**: Meaning is delivered multimodally—pairing legible, open Bengali typography with grounded, pictorial iconography and voice-assisted trigger hints.

## Colors

The palette draws directly from healthy paddy fields and ripe harvest crops. It eschews generic tech blues in favor of deeply saturated botanical greens, soil neutrals, and protective amber accents.

### Palette Architecture
- **Primary (`#166534`)**: Deep paddy green. Used for decisive actions, verified states, and primary navigation active states. Conveys health, life, and agricultural authority.
- **Secondary (`#D97706`)**: Harvest amber. Used for alerts, time-critical advisory warnings, spray reminders, and diagnostic progress tracking.
- **Tertiary (`#0D9488`)**: Irrigation teal. Applied for secondary functional utilities like weather forecasts, soil moisture indices, and water logs.
- **Neutral Surface & Base**:
  - `Surface Field`: `#F8FAF6` — a tinted natural off-white preventing outdoor screen glare.
  - `Surface Raised`: `#FFFFFF` — crisp pure white for actionable cards and modal sheets.
  - `Border Soft`: `#E2E8F0` — low-contrast containment lines defining card shapes.
- **Neutral Foreground (`#1F2937`)**: Deep charcoal bark. Delivers robust contrast against `#FFFFFF` and `#F8FAF6` for readability on low-cost TN/IPS displays.
- **Critical Diagnostics**:
  - `Disease Alert`: `#DC2626`
  - `Pest Notice`: `#EA580C`
  - `Healthy Crop`: `#16A34A`

## Typography

Typography prioritizes bilingual Bengali (বাংলা) and English rendering through the open, robust letterforms of **Noto Sans** (with fallback to system Noto Sans Bengali). 

### Principles
- **Extended Line Heights**: Bengali script requires substantial vertical headroom for *matras* (top bars), *kar* signs, and conjunct ascenders/descenders (যুক্তাক্ষর). Line heights are set 20–25% taller than standard Latin settings to prevent glyph clipping.
- **Weight Calibration**: Body text is anchored at minimum `400` with high-contrast glyph strokes. Sub-headings and interactive triggers mandate `600` or `700` weight to resist visual deterioration across entry-level Android screen renderers.
- **Accessible Minimum**: No critical data point or instruction falls below `14px`. `12px` is reserved exclusively for secondary timestamps or pill micro-tags.

## Layout & Spacing

The layout uses a **fluid, mobile-first single-column structure** optimized for portrait hand-held use in field environments.

### Grid & Margins
- **Base Rhythm**: 4px/8px modular scale.
- **Screen Margins**: Uniform `16px` on standard mobile screens (`< 480px`), scaling to `24px` on small tablets.
- **Card Gutters**: Vertical flow uses `16px` spacing between cards to maintain individual component integrity without visual clutter.
- **Reachability Architecture**: Primary interaction nodes reside in the bottom 45% thumb zone. Secondary educational references, weather overviews, and non-actionable statuses occupy the top 55%.
- **Touch Targets**: Strictly enforces a minimum tap target dimension of **52px × 52px** (`touch-target-min: 3.25rem`) to accommodate calloused hands or rapid one-handed outdoor usage.

## Elevation & Depth

To avoid optical confusion for users unfamiliar with abstract drop-shadow semantics, elevation uses **dual-token depth**: combining subtle ambient shadows with crisp, low-contrast structural outlines.

### Elevation Levels
- **Level 0 (Flat Canvas)**: `#F8FAF6`. Ground layer. No shadows or borders.
- **Level 1 (Resting Cards & Containers)**: `#FFFFFF` background with a `1px` border of `#E2E8F0` and an ambient shadow: `box-shadow: 0px 2px 6px -1px rgba(22, 101, 52, 0.06), 0px 1px 4px -1px rgba(0, 0, 0, 0.04)`. The green-tinted shadow mirrors natural ground light.
- **Level 2 (Interactive Floating / Sticky CTAs / Bottom Navigation)**: `#FFFFFF` with a `1px` border of `#E2E8F0` and `box-shadow: 0px 8px 20px -3px rgba(22, 101, 52, 0.12)`. Applied to sticky diagnosis triggers and drawer sheets.
- **Level 3 (Modal Alerts & Critical Overlays)**: `#FFFFFF` paired with an scrim backdrop of `rgba(31, 41, 55, 0.6)`. Shadow: `0px 16px 32px -4px rgba(0, 0, 0, 0.18)`.

## Shapes

The shape vocabulary uses generous curves (`roundedness: 2`), projecting an inviting, organic feeling while maintaining clean bounding boxes for content.

### Token Mapping
- **Buttons & Large CTAs**: `16px` (`rounded-lg`) to `24px` (`rounded-xl`).
- **Surface Cards**: `16px` to `20px` perimeter radius.
- **Diagnostic Image Capture Windows**: `20px` corner radii with defined viewfinder brackets.
- **Input Fields & Search**: `14px` corner radii for gentle tactile presence.
- **Micro Tags & Status Pills**: Full pill radius (`9999px`) to immediately distinguish them from squarish interactive operational buttons.

## Components

### Buttons & CTAs
- **Primary Action (Leaf Action)**: Solid `#166534` background, `#FFFFFF` text, `56px` height. Features large leading visual icons (e.g., camera, microphone). Only one primary action button per screen.
- **Secondary Action (Soil Action)**: `#FFFFFF` background, `2px` border in `#166534`, text `#166534`. Height `52px`.
- **Audio Assist Action (Voice Trigger)**: Rounded floating action or embedded button with a vivid harvest accent `#D97706` and dynamic sound-wave iconography, triggering voice playback of the on-screen text.

### Agricultural Diagnostic Cards
- White background (`#FFFFFF`), `16px` rounded corners, `1px` soft border (`#E2E8F0`).
- Divided into three distinct zones:
  1. Top: Full-width photographic preview of the diseased leaf or crop stage.
  2. Middle: Large Bengali label in `headline-sm` with a status pill (e.g., "ধানের ব্লাস্ট রোগ" / "Rice Blast").
  3. Bottom: Direct single-touch resolution step with high contrast.

### Form Inputs & Selectors
- Explicit bounding boxes with minimum height of `54px`.
- Inactive border: `1.5px` solid `#CBD5E1`. Active focused border: `2px` solid `#166534`.
- Labels are permanently floating or anchored above the input—never disappearing placeholder text.
- Form fields pair textual inputs with numeric stepper buttons (`+` / `-`) at minimum `48px` width for easy land area and seed weight calculations.

### Chips & Category Selectors
- Height `44px` to ensure easy thumb selection.
- Unselected: `#FFFFFF` fill with `#E2E8F0` border, text `#1F2937`.
- Selected: `#166534` fill with `#FFFFFF` text, accompanied by a checkmark icon.

### Radio & Checkbox Toggles
- Sized at `28px × 28px` with an expanded invisible tap area of `52px × 52px`.
- Active state uses `#166534` fill with high-contrast white check/dot. Unchecked uses `#94A3B8` border.