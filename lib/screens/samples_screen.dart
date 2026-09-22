import '../water_ui/water_ui.dart';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:path_provider/path_provider.dart';
import '../l10n/strings.dart';
import '../theme/app_theme.dart';
import '../widgets/bottom_nav.dart';
import 'analyzing_screen.dart';

/// Demo-only entry point: lets a judge/reviewer see different risk tiers
/// without depending on gallery/MediaStore indexing (unreliable mid-demo).
/// All six samples are real, Hb/clinically-labeled reference photos — see
/// calibration/README.md for full sourcing/methodology. Bundled as assets,
/// copied to a temp file, then run through the exact same analysis
/// pipeline as a live capture or gallery upload.
class SamplesScreen extends StatelessWidget {
  const SamplesScreen({super.key});

  static List<({String asset, ScreenMode mode, String label})> get _samples => [
    (
      asset: 'assets/samples/anemia_low.jpg',
      mode: ScreenMode.anemia,
      label: S.sampleLabel(jaundice: false, riskWord: S.low),
    ),
    (
      asset: 'assets/samples/anemia_moderate.jpg',
      mode: ScreenMode.anemia,
      label: S.sampleLabel(jaundice: false, riskWord: S.moderate),
    ),
    (
      asset: 'assets/samples/anemia_high.jpg',
      mode: ScreenMode.anemia,
      label: S.sampleLabel(jaundice: false, riskWord: S.high),
    ),
    (
      asset: 'assets/samples/jaundice_low.jpg',
      mode: ScreenMode.jaundice,
      label: S.sampleLabel(jaundice: true, riskWord: S.low),
    ),
    (
      asset: 'assets/samples/jaundice_moderate.jpg',
      mode: ScreenMode.jaundice,
      label: S.sampleLabel(jaundice: true, riskWord: S.moderate),
    ),
    (
      asset: 'assets/samples/jaundice_high.jpg',
      mode: ScreenMode.jaundice,
      label: S.sampleLabel(jaundice: true, riskWord: S.high),
    ),
  ];

  Future<void> _open(
    BuildContext context,
    String asset,
    ScreenMode mode,
  ) async {
    final bytes = await rootBundle.load(asset);
    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/${asset.split('/').last}');
    await file.writeAsBytes(bytes.buffer.asUint8List(), flush: true);
    if (!context.mounted) return;
    Navigator.of(context).push(
      WaterPageRoute(
        builder: (_) => AnalyzingScreen(
          mode: mode,
          imagePath: file.path,
          preparedReference: mode == ScreenMode.anemia,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return WaterScaffold(
      backgroundColor: AppColors.canvas,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 10),
              child: Row(
                children: [
                  CircleIconButton(
                    icon: Icons.arrow_back_rounded,
                    onTap: () => Navigator.of(context).pop(),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        S.samplePhotosTitle,
                        style: const TextStyle(
                          fontSize: 21,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.2,
                        ),
                      ),
                      Text(
                        S.samplePhotosSubtitle,
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.meta,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
                children: [
                  Container(
                    padding: const EdgeInsets.all(14),
                    margin: const EdgeInsets.only(bottom: 14),
                    decoration: BoxDecoration(
                      color: AppColors.sand,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.sandEdge),
                    ),
                    child: Text(
                      S.sampleInfo,
                      style: const TextStyle(
                        fontSize: 12.5,
                        height: 1.5,
                        color: AppColors.sandInkDark,
                      ),
                    ),
                  ),
                  for (final s in _samples)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: _SampleRow(
                        asset: s.asset,
                        label: s.label,
                        onTap: () => _open(context, s.asset, s.mode),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SampleRow extends StatelessWidget {
  final String asset;
  final String label;
  final VoidCallback onTap;
  const _SampleRow({
    required this.asset,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return WaterCard(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.cardEdge),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.asset(
                asset,
                width: 54,
                height: 54,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(width: 13),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    S.realReferencePhoto,
                    style: const TextStyle(fontSize: 12, color: AppColors.meta),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: AppColors.metaSoft),
          ],
        ),
      ),
    );
  }
}
