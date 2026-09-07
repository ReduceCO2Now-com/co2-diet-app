---
name: Eco-Minimalist Wellness
colors:
  surface: '#f9f9fc'
  surface-dim: '#dadadc'
  surface-bright: '#f9f9fc'
  surface-container-lowest: '#ffffff'
  surface-container-low: '#f3f3f6'
  surface-container: '#eeeef0'
  surface-container-high: '#e8e8ea'
  surface-container-highest: '#e2e2e5'
  on-surface: '#1a1c1e'
  on-surface-variant: '#3f493f'
  inverse-surface: '#2f3133'
  inverse-on-surface: '#f0f0f3'
  outline: '#6f7a6e'
  outline-variant: '#becabc'
  surface-tint: '#016d2f'
  primary: '#005222'
  on-primary: '#ffffff'
  primary-container: '#006d2f'
  on-primary-container: '#90ec9f'
  inverse-primary: '#7fda8f'
  secondary: '#0155c7'
  on-secondary: '#ffffff'
  secondary-container: '#336fe2'
  on-secondary-container: '#fefcff'
  tertiary: '#00512d'
  on-tertiary: '#ffffff'
  tertiary-container: '#006c3d'
  on-tertiary-container: '#91eaaf'
  error: '#ba1a1a'
  on-error: '#ffffff'
  error-container: '#ffdad6'
  on-error-container: '#93000a'
  primary-fixed: '#9bf7a9'
  primary-fixed-dim: '#7fda8f'
  on-primary-fixed: '#002109'
  on-primary-fixed-variant: '#005322'
  secondary-fixed: '#d9e2ff'
  secondary-fixed-dim: '#b0c6ff'
  on-secondary-fixed: '#001945'
  on-secondary-fixed-variant: '#00419c'
  tertiary-fixed: '#9cf6ba'
  tertiary-fixed-dim: '#80d99f'
  on-tertiary-fixed: '#00210f'
  on-tertiary-fixed-variant: '#00522d'
  background: '#f9f9fc'
  on-background: '#1a1c1e'
  surface-variant: '#e2e2e5'
  leaf-green: '#2eb85c'
  soft-mint: '#4bb477'
  sky-blue: '#316fe2'
  surface-lowest: '#ffffff'
typography:
  display-lg:
    fontFamily: Plus Jakarta Sans
    fontSize: 40px
    fontWeight: '700'
    lineHeight: 48px
    letterSpacing: -0.02em
  headline-lg:
    fontFamily: Plus Jakarta Sans
    fontSize: 32px
    fontWeight: '700'
    lineHeight: 40px
    letterSpacing: -0.02em
  headline-lg-mobile:
    fontFamily: Plus Jakarta Sans
    fontSize: 28px
    fontWeight: '700'
    lineHeight: 34px
  title-md:
    fontFamily: Plus Jakarta Sans
    fontSize: 20px
    fontWeight: '600'
    lineHeight: 28px
  body-lg:
    fontFamily: Plus Jakarta Sans
    fontSize: 16px
    fontWeight: '400'
    lineHeight: 24px
  body-sm:
    fontFamily: Plus Jakarta Sans
    fontSize: 14px
    fontWeight: '400'
    lineHeight: 20px
  label-caps:
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
  base: 4px
  xs: 8px
  sm: 16px
  md: 24px
  lg: 32px
  xl: 48px
  container-margin: 20px
  stack-gap: 12px
---

## Brand & Style
The brand identity centers on "Environmental Wellness," blending personal health with ecological responsibility. The UI evokes a sense of serenity, clarity, and intentionality. 

The design style is **Soft Minimalism** with a hint of **Ambient Depth**. It prioritizes extreme legibility, generous breathing room, and a palette that feels natural yet modern. The aesthetic avoids harsh lines in favor of organic "ambient glows" and subtle entrance animations (micro-interactions) to create a premium, calm user experience. It is designed to feel like a high-end health clinic meets a sustainable lifestyle boutique.

## Colors
The palette is rooted in "Chlorophyll Green" (#006d2f), representing growth and carbon reduction. Secondary blues provide a sense of trust and technological precision. 

The background strategy utilizes "Pure White" (#ffffff) for the primary canvas to ensure maximum focus, while background-blur elements in very low opacity (3-4%) create a sense of depth without adding visual noise. Text uses a dark charcoal (#1a1c1e) rather than pure black to maintain softness, and semantic colors for success/warning should remain within the green-blue spectrum where possible to keep the theme cohesive.

## Typography
The system uses **Plus Jakarta Sans** for almost all UI levels to provide a friendly, open, and modern feel. Its slightly rounded terminals complement the health-centric brand. 

For functional and technical metadata, **Inter** is used in a "Label Caps" style (Uppercase, 12px, tracking 0.05em) to provide clear hierarchy and a systematic touch. Headlines should always use negative letter spacing to feel tight and authoritative, while body copy maintains standard spacing for maximum readability.

## Layout & Spacing
The layout follows a **Fluid Margin Model**. Mobile screens utilize a strict 20px container margin. Vertical rhythm is established using a base-4 scale, with `24px` (md) and `48px` (xl) being the primary drivers for section breaks.

Layouts should be center-aligned for splash and landing moments, transitioning to a flexible grid for data-heavy views. On larger screens, the content should be constrained to a maximum width of 600px for better focus, rather than stretching full-width.

## Elevation & Depth
This system eschews traditional heavy shadows for **Ambient Depth**.

1.  **Glow Layers:** Use high-radius (80px - 100px) blurs at very low opacities (3-5%) behind primary brand elements to create a "halo" effect.
2.  **Tonal Stacking:** Instead of elevation by shadow, use surface color steps (Surface -> Surface Container Low -> Surface Container High) to distinguish hierarchy.
3.  **Dynamic Micro-shadows:** For interactive cards, a barely-visible 2px blur shadow (#000000 @ 0.05 opacity) may be used to indicate "lift" upon hover or touch.

## Shapes
The shape language is consistently **Rounded**. 
- Standard buttons and cards use `0.5rem` (8px).
- Larger containers or distinct sections use `1rem` (16px) or `1.5rem` (24px).
- Status indicators and loading dots use a "full" roundedness to create perfect circles, maintaining the soft, organic theme.

## Components
- **Buttons:** High-contrast primary buttons use the Primary Green with white text. Secondary buttons should use a ghost style (Outline) or a soft tonal background (Surface Container).
- **Interactive Dots:** For loading or step indicators, use pulsing animations (`pulse-dot`) with `primary-container` coloring to indicate activity without being distracting.
- **Input Fields:** Use subtle `outline-variant` borders with no fill. On focus, the border transitions to `primary` with a 2px stroke.
- **Cards:** Cards should have no borders but use `surface-container-low` for subtle distinction against the white background.
- **Micro-interactions:** Elements should fade in with a slight vertical translation (10px) to give a sense of "rising" into view.
