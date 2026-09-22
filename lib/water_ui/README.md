# Water UI

All six screens use `WaterScaffold`, which provides a calm, painted water surface. The camera retains its dark surface and unfiltered camera preview. Existing navigation callbacks, screening analysis, persistence, and translations are retained.

## Integration

Import `water_ui.dart`. Replace tappable wrappers with `WaterButton`, `WaterCard`, or `WaterNavItem`, preserving the child and onTap. Cards without onTap respond to physical pressure without advertising a semantic action. Use WaterInteractive directly for configurable radius, duration, intensity, opacity, damping, pressDepth, shape, and clipping.

The effect pairs physical translation and subtle pointer-relative tilt with a changing reflection, dynamic shadow, and three damped highlight/shadow wave crests. Cards also produce an expanding rounded boundary meniscus. This is a lightweight painted refraction illusion, not a shader that distorts text or camera pixels.

## Scope and accessibility

- Card waves are limited to 32 logical pixels around the card.
- Button waves have a smaller radius.
- Each navigation item masks waves to its own rounded shape; the navigation row supplies a second clip.
- Background touch handling sits behind content, avoiding ancestor ripple activation during held navigation touches.
- Gesture recognition preserves scroll cancellation. Keyboard Enter/Space activate enabled actions, with a visible focus outline.
- Platform reduced-motion settings disable water movement and physical press animations.
- A new press replaces the same component's previous wave, bounding resource use.

## Validation

`flutter test` covers corner origins, release/disposal, held navigation isolation, scroll cancellation, reduced motion, home content, and phone-width English/Bangla layout.

`flutter analyze --no-fatal-infos` checks compilation and linting. Existing style/print informational lints remain in capture/result and calibration utilities.

No Android device was connected during implementation. Profile-mode frame timing, final device typography, camera interactions, and physical visual review still require a device. The renderer uses no blur filters, saveLayer calls, image assets, or full-screen distortion shaders. Ambient painting has a separate repaint boundary; interaction content is reused as an AnimatedBuilder child. Measure these choices on the target hardware before claiming a frame-rate budget.
