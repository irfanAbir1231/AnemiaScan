# AnemiaScan design specification

These are static visual mockups, not a Flutter implementation. Camera and sample imagery is illustrative; retain the app's actual reference assets and analysis logic in implementation. Clinical values and next-step copy come from the supplied brief and are not newly validated clinical guidance.

Generated raster text, especially Bangla, requires proofreading before implementation. The token specification below is authoritative where generated pixels differ: status dots, saved confirmation, and summary counters must use teal, not risk colors. The alternate-state board uses neutral preview/thumbnail placeholders after the image generator rejected the initial rendering. Alternate recommendation copy is illustrative; preserve the app's established per-risk recommendations when implementing.

## Shared tokens

Primary #006B73; primary container #D5F2EF; surface #F8FAF8; surface variant #EAF0ED; outline #71817E; text #162E2C. Low #236A44, moderate #8A5700, high #B13D38. Use semantic colors only within result cards and history risk chips; always pair them with text and distinct icons. The saved confirmation uses teal to resolve the brief's conflict between a green success strip and risk-only green.

Figtree for Latin and Hind Siliguri for Bangla. Suggested type sizes: headline 28/34, title 22/28, body 16/24, label 14/20; paired Bangla two points larger. Use 4/8/12/16/24/32 spacing, 24dp card radii, 16dp icon tiles, pill buttons and chips, and at least 56dp interactive targets. Preserve text scaling with scrolling rather than clipping. Preview images cannot verify actual touch dimensions or font rendering.

## Motion and behavior

Use restrained 200–300ms Material easing for page transitions, chip selection, and tonal state changes. Avoid bouncy motion. In anemia capture, show a translucent friendly line-art eye and finger over the live preview: gently lower the lower eyelid to reveal the conjunctiva over two seconds; return to the initial pose and replay three times, then fade out. Keep the live guide and controls visible throughout. With reduced motion enabled, show one static instructional pose instead.

The anemia guide is a dashed ellipse approximately two-thirds of preview width with four external corner brackets. Jaundice uses a dashed rounded square and solid inner circle. Mode pills use teal and blue, never risk colors. Show camera switch only on devices with multiple cameras; show 2.0x after zoom becomes available and retain pinch-to-zoom. Good lighting uses a subtle teal pulse, becoming static with reduced motion.

History filters preserve the existing behavior. Fresh results show saved confirmation; reopened results show full timestamp and saved-photo card. The sample screen retains all six bundled reference-photo choices. Do not replace real sample assets with generated imagery.
