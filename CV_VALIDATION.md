# CV validation audit

## What was wrong

The previous implementation averaged every pixel in a large center crop and
assigned a risk tier unconditionally. Its anemia thresholds came from three
hand-picked, tightly cropped conjunctiva examples, while live captures contain
the pupil, sclera, skin, shadows, and background. Its jaundice thresholds came
from a small set of web reference photos without blood bilirubin labels. This
made arbitrary dark or non-red photos look like high-risk anemia and most
non-yellow photos look like low-risk jaundice.

The previous result page also displayed fixed haemoglobin and bilirubin ranges
chosen from the risk tier. The image pipeline did not measure either value, so
those ranges have been removed.

## Corrected pipeline

1. Decode the photo and apply its orientation metadata.
2. Crop the exact proportions represented by the on-screen guide.
3. Measure exposure, luminance variation, local edge contrast, target-colour
   coverage, and central eye structure.
4. Reject the image if it is dark, overexposed, flat, strongly colour-cast, or
   does not contain the required anatomy. A rejected image receives no risk
   label and is not saved to history.
5. For anemia, measure the red end of the plausible palpebral-conjunctiva pixel
   distribution. For jaundice, use a trimmed CIE Lab b* average from plausible
   skin pixels.
6. Report the measured Lab signal and an analysis-confidence score.

The confidence score combines capture quality with distance from the nearest
colour threshold. It is capped at 79% for anemia and 76% for jaundice because
this implementation has not undergone prospective clinical validation. It is
not the probability that the subject has anemia or jaundice.

## Evidence run on 15 September 2026

### Clinical anemia dataset audit

All 710 Hb-labeled CP-AnemiC conjunctiva crops were measured. The old single
mean-a* feature did not separate the labels:

| Label | n | Mean a* | Median a* | Interquartile range |
|---|---:|---:|---:|---:|
| Anemic | 424 | 27.08 | 26.66 | 21.11–33.71 |
| Non-anemic | 286 | 27.63 | 28.03 | 22.31–32.79 |

This overlap is why the app no longer treats one raw average as diagnostic
certainty. The three anemia tiers remain screening bands for accepted target
images, with an explicit confidence cap and blood-test guidance.

### Recent captures from the target phone

Nine existing captures from the connected M2004J19C were replayed through the
corrected production code in both modes.

| Mode | Accepted | Rejected | Accepted results |
|---|---:|---:|---|
| Anemia | 1 | 8 | The actual eye capture: moderate, Lab a* 21.21, 64% confidence |
| Jaundice | 4 | 5 | Three low and one moderate; confidence 65–76% |

The rejected anemia inputs were skin, fabric, paper, darkness, or frames without
the pupil/sclera/lower-eyelid structure. The rejected jaundice inputs were dark,
strongly colour-cast, or lacked enough plausible skin. These captures do not
have paired laboratory results, so this replay validates input rejection and
non-constant behavior, not medical sensitivity or specificity.

### Automated regression tests

`test/color_analysis_test.dart` verifies all six bundled low/moderate/high
reference tiers, cross-mode anatomy rejection, confidence bounds, measured
signal rendering, and removal of fake g/dL output. The complete suite currently
passes 12 tests.

## What would be required for a clinical accuracy claim

A prospective study must collect target-phone images alongside same-visit CBC
haemoglobin and serum bilirubin measurements. Thresholds must be trained and
tested on different patients, then reported with sensitivity, specificity,
ROC-AUC, calibration error, confidence intervals, and performance stratified by
skin tone, age, lighting, camera model, and disease severity. Jaundice imaging
also needs a colour reference or a validated flash/no-flash protocol to control
ambient light and camera processing.

Relevant primary studies:

- Collings et al., *PLOS ONE* 2016, DOI 10.1371/journal.pone.0153286
- Ngeow et al., *JAMA Network Open* 2024, DOI 10.1001/jamanetworkopen.2024.50260
- Outlaw et al., neonatal scleral chromaticity pilot, PMID 32119664
