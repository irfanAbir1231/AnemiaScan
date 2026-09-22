# Alternate states prompt

Use case: ui-mockup. Produce a high resolution contact sheet EXACTLY SIX complete portrait Android 412:915 screens in 3 columns x 2 rows, full flat screens without hardware frames, legible UI text. Board 2 alternate states for AnemiaScan. Unified polished Google Material 3 design, Figtree Latin and Hind Siliguri Bangla humanist faces. Paired Bangla text two points larger than English for key labels. Primary #006B73, primary container #D5F2EF, surface #F8FAF8, surface variant #EAF0ED, text #162E2C, outline #71817E. White warm light surfaces, 24dp card radius, 56dp tall pill buttons, rounded Material icons. Generous disciplined 8/16/24 spacing. Risk green #236A44 amber #8A5700 coral #B13D38 only results/history risk chips; nav/controls teal. First row: 1 Capture jaundice dark immersive phone preview newborn chest skin, back, blue Jaundice pill, camera switch, teal Good lighting pill; English + Bangla instruction to fill guide with chest or nose skin; big dashed rounded square with solid circle target and 'skin patch' pill, 2.0x bottom left; circular Torch/shutter/Upload bottom controls. 2 Fresh Low risk anemia result, bilingual title Low risk / কম ঝুঁকি, green tinted centerpiece, icon, labelled 3-segment Low Moderate High bar only low active green, estimated haemoglobin row, What this means card, NEXT STEP recommendation paired Bangla, teal saved strip, disclaimer, Done primary and Screen again secondary. 3 Fresh High risk anemia same identical layout with coral risk centerpiece, High risk / উচ্চ ঝুঁকি, high segment active, explanation and next step, estimated haemoglobin, saved strip, disclaimer and both buttons. Second row: 4 Reopened moderate anemia result same layout with full timestamp 15 September 2026 · 10:42 AM, amber Moderate risk / মাঝারি ঝুঁকি, estimated haemoglobin 9–11 g/dL, What this means, NEXT STEP Consult a doctor within 24 hours + Bangla, saved photo card Screened with timestamp replacing saved strip, disclaimer, Done and Screen again. 5 Empty History with back, History / পূর্বের পরীক্ষা, All Anemia Jaundice pill filters All selected; generous blank space centered history icon, 'No screenings yet' / 'এখনও কোনো পরীক্ষা নেই', reassuring 'Your screenings stay on this phone.' + Bangla; bottom Home History(active) Help bilingual. 6 Fresh moderate Jaundice result identical result layout, Estimated bilirubin — 8–14 mg/dL, moderate amber badge and bar, explanation and next step appropriate newborn screening, saved strip disclaimer both buttons. Readable authentic bilingual text everywhere appropriate, no invented ornament, camera photo illustrative only. Use illustrative clinical numbers, not diagnostic claims. External labels above each phone. Complete original design requirements for reference:
Redesign the UI/UX for AnemiaScan, a Flutter Android app that screens for anemia (via inner-eyelid conjunctiva color) and newborn jaundice (via skin color) using the phone camera and on-device color analysis — no cloud, no diagnosis claims, a screening aid only.
Design it as if a UI/UX designer at Google built it: the visual quality, spacing discipline, component consistency, and motion restraint of Google's own apps (Google Fit, Gmail, Google Pay, Android Health Connect). Concretely that means:
- Material Design 3 as the foundation — dynamic color roles, M3 elevation/shape tokens, M3 component shapes (large corner radii on cards, pill-shaped buttons/chips), M3 type scale.
- Generous whitespace, a restrained single-accent color used deliberately (not decoratively), and typography doing most of the hierarchy work rather than heavy borders/shadows.
- Confident, calm, trustworthy healthcare tone — closer to Google Fit or Fitbit than a clinical/hospital app. Never alarming, never cluttered.
- Every screen must still work for low digital-literacy users in rural Bangladesh: large touch targets (56px+ minimum), icon-forward, short text, bilingual (English + Bangla shown together), high contrast, legible in bright outdoor sunlight.
Output needed: a full mockup image for each of the 6 screens listed below (portrait mobile, ~412×915dp / Android reference size), as one consistent design system — same color roles, type scale, corner radii, spacing scale, and component styles reused across all six, not six unrelated designs.
Do not remove or change any existing element's functionality, information, or flow — every element listed per screen below must still be present and do the same job. You're free to add new elements on top of that — extra stat cards, small data visualizations, helpful micro-copy, secondary badges, empty/loading states not explicitly spelled out, anything that reads as a natural, tasteful addition for a health-screening app — as long as nothing existing is removed or broken. If you add something, keep it consistent with the shared design system below (same color roles, type scale, shape/spacing rules), and keep it earning its place — don't add density for its own sake on a low-literacy-friendly screen.
- Color roles (M3-style): primary (currently a teal, #0E7B86 — keep in the teal/blue-green healthcare-trust family, but feel free to modernize the exact hue/tone), primary-container, surface, surface-variant, outline, and three semantic risk colors that must stay visually distinct and colorblind-safe: Low = green, Moderate = amber, High = red/coral. Risk colors appear ONLY on result badges and history risk chips — never in navigation, buttons, or chrome.
- Type scale: a clear headline/title/body/label hierarchy (M3 type scale is a good reference: Headline Large/Medium, Title Large/Medium, Body Large/Medium, Label Large/Medium). Latin text in a clean geometric/humanist sans (current app uses Figtree); Bangla text in a matching humanist Bangla face (current app uses Hind Siliguri) sized one step larger than its paired English text, always shown together (not tabs/toggles).
- Shape: generous corner radii on cards (16–28dp), pill shapes on buttons/chips/badges, consistent icon-tile corner radii for list-row leading icons.
- Elevation/surfaces: prefer tonal surfaces (subtle color-tinted fills) and soft shadows over hard borders, per M3.
- Iconography: Material Symbols (rounded style), consistent stroke weight, used literally (eye, baby/child-care, history/clock, camera-switch, flash, gallery/photo-library, checkmark, chevron).
- Spacing scale: a consistent 4/8/12/16/24/32 rhythm.
- Motion note (describe, don't need to render): subtle M3-style easing on transitions; one screen (Capture, anemia mode) has a 2-second looping instructional micro-animation — describe it as a simple, friendly line-art or soft-3D illustration of a finger gently pulling a lower eyelid down to reveal the inner eyelid, replayed 3 times, shown as a translucent overlay on the live camera preview.
Purpose: entry point; pick which screening to run, or revisit history.
Must include:
- App identity: small squircle app-icon mark (an eye motif) + "AnemiaScan" wordmark + tagline "Community screening aid"
- A small "Offline" status pill (dot + label) — the app works with zero connectivity, this should read as a trust signal, not a warning
- A headline: "Check for anemia and newborn jaundice with the phone camera."
- Two large primary action cards, equal visual weight, tappable:
  1. "Screen for Anemia" (+ Bangla label) — icon tile (eye motif), one-line description "Photo of the inner lower eyelid · 30 seconds", trailing chevron
  2. "Screen for Jaundice" (+ Bangla label) — icon tile (baby/child motif), description "Photo of the newborn's chest or nose · 30 seconds", trailing chevron
- A secondary "Past screenings" row/card — icon, "Past screenings" + a live count ("N saved on this phone"), trailing chevron. Visually secondary to the two primary cards but still substantial (not a tiny link).
- A small text link: "Try sample photos (for demos)" — visually minor/quiet, a utility link for showing the app without a live subject
- Disclaimer microcopy: "AnemiaScan is a screening aid. It does not give a diagnosis."
- Bottom navigation bar: Home (active) / History / Help
Purpose: live camera capture guided to the exact target region, for both anemia and jaundice modes (design both mode variants).
Must include:
- Dark/immersive background (this screen inverts to a dark theme, unlike the rest of the light app) — camera preview should read as nearly edge-to-edge, minimal side margin
- Header row over the preview: back button, a mode pill ("Anemia" or "Jaundice", each a distinct accent color), a camera-switch icon (front/back toggle, only if device has multiple cameras), and a "Good lighting" live status pill (pulsing dot + label) when conditions are good
- Short instruction line + Bangla translation, e.g. "Gently pull the lower eyelid down and fill the guide." / skin-patch instruction for jaundice mode
- Live camera preview filling the frame, with a guide overlay:
  - Anemia mode: a dashed oval/ellipse outline with 4 corner brackets (viewfinder-style L-shaped marks just outside the oval's corners) and a small centered label pill "inner eyelid"
  - Jaundice mode: a dashed rounded-square outline with a solid inner circle target and a centered label pill "skin patch"
  - The oval/square should be sized proportionally to the preview (roughly two-thirds of preview width for anemia's oval), not a small fixed box lost in a huge frame
- A default-2x zoom indicator badge (e.g. "2.0x") bottom-left of the preview once zoom is available (pinch-to-zoom supported)
- Anemia mode only: the 2-second instructional pull-down-eyelid micro-animation overlay, played 3 times on screen entry (describe as noted in Design System above)
- Bottom control row: Torch toggle (left) / large circular shutter button (center, prominent) / Upload from gallery (right) — three equally-weighted circular icon+label controls
Purpose: brief on-device processing state between capture and result.
Must include:
- Small thumbnail of the just-captured image + "Captured image" label
- Large centered circular loading motif (spinner ring around a soft eye icon, or equivalent modern M3 loading motif)
- Headline "Analyzing image…" + Bangla translation
- Reassurance subtext: "Runs on this phone. No internet or data needed." (this is a core trust/privacy message — give it real visual weight, not throwaway caption)
- A 3-step checklist showing pipeline progress: "Image quality checked" (done/check), "Reading colour values" (active/spinning), "Estimating risk level" (pending) — each step's state visually distinct (done = filled check, active = spinner, pending = outline)
- A slim indeterminate progress bar
- A quiet "Cancel" text action at the bottom
Purpose: show the risk outcome, explanation, and recommended next step. Same layout serves a just-captured result and a reopened history entry — design both states.
Must include:
- Back button, screening type title ("Anemia screening" / "Jaundice screening"), meta line ("Just now · saved" for fresh, or a full date/time for a reopened history entry)
- Risk badge card — the visual centerpiece: risk icon, risk label ("Low risk"/"Moderate risk"/"High risk") + Bangla, a 3-segment low/moderate/high bar with the active segment highlighted in that risk's color, and an estimated clinical value row (e.g. "Estimated haemoglobin — 9–11 g/dL" or "Estimated bilirubin — 8–14 mg/dL"). This card's background/border tints toward the risk color; use the semantic risk colors here specifically.
- "What this means" card — a short plain-language explanation of the result
- "Next step" card — icon + label "NEXT STEP" + the recommendation ("Consult a doctor within 24 hours" etc.) + Bangla
- History-detail variant only: an additional card showing the saved thumbnail + "Screened" date/time
- Fresh-result variant only: a small success confirmation strip — "Saved to history on this phone" (checkmark + green tint)
- A quiet disclaimer card: "Screening aid, not a diagnosis. Only a clinic blood test can confirm the result."
- Two stacked buttons at the bottom: primary Done, secondary Screen again
Design all three risk states (Low/Moderate/High) as color variants of the same layout.
Purpose: browse past screenings saved on-device, filter by type, reopen any entry.
Must include:
- Back button, "History" title + Bangla subtitle
- Filter chip row: All / Anemia / Jaundice (pill chips, one selected/filled state)
- A scrollable list of entries, each row: square thumbnail, small type-icon badge (eye or baby motif) + screening title, timestamp, and a risk-color pill badge (Low/Moderate/High) trailing
- An empty state (no screenings yet) — icon, "No screenings yet" headline, reassuring subtext that data stays on-device — design this too, it's a real state, not a placeholder
- Bottom navigation bar: Home / History (active) / Help
- Optional addition to consider: a small summary stat strip at the top (e.g. total screenings, split by risk level, or a "screened X times this week") — only if it stays lightweight and doesn't compete with the list itself
Purpose: a low-key utility screen so the app can be demonstrated without a live subject — lets a reviewer/judge trigger a result using bundled real reference photos.
Must include:
- Back button, "Sample photos" title + subtitle "For demoing without a live subject"
- A quiet info card noting these are real reference photos (clinical Hb-labeled conjunctiva images for anemia, real newborn/adult jaundice cases for jaundice)
- A list of 6 rows (Anemia Low/Moderate/High, Jaundice Low/Moderate/High), each: small thumbnail, label, "Real reference photo" caption, trailing chevron
This screen should feel visually subordinate/utilitarian compared to Screens 1–5 — it's a demo tool, not a primary product surface — but still consistent with the same design system.
Six mockup images (or one composed contact-sheet image, whichever Codex supports), portrait mobile aspect ratio, showing this design system applied consistently across all six screens above, with every listed element present and functioning the same way — redesigned for visual quality only.

