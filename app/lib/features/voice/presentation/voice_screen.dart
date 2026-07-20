import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/i18n/strings.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/typography.dart';
import '../../preferences/presentation/settings_widgets.dart';
import '../voice_service.dart';

/// Voice picker for reading affirmations aloud. Tapping a voice selects it and
/// plays a short preview so you hear it.
class VoiceScreen extends ConsumerWidget {
  const VoiceScreen({super.key});

  static const _preview = 'You are exactly where you need to be.';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final voices = ref.watch(voicesProvider);
    final selected = ref.watch(selectedVoiceProvider);

    return SettingsSubScreen(
      title: ref.tr('Voice'),
      subtitle: ref.tr('Choose the voice that reads your affirmations.'),
      child: voices.when(
        loading: () => const Center(child: CircularProgressIndicator(strokeWidth: 2)),
        error: (_, _) => Center(
          child: Text('Voices unavailable',
              style: MirraType.cochin(size: 14, color: MirraColors.muted)),
        ),
        data: (list) {
          if (list.isEmpty) {
            return Center(
              child: Text('No voices found',
                  style: MirraType.cochin(size: 14, color: MirraColors.muted)),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 40),
            itemCount: list.length,
            separatorBuilder: (_, _) => const SizedBox(height: 8),
            itemBuilder: (_, i) {
              final v = list[i];
              final on = v.sameAs(selected);
              return GestureDetector(
                onTap: () async {
                  await ref.read(selectedVoiceProvider.notifier).select(v);
                  await ref.read(voiceServiceProvider).speak(_preview);
                },
                behavior: HitTestBehavior.opaque,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF4F2F8),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(_displayName(v.name),
                                style: MirraType.cochin(size: 16, weight: FontWeight.w700)),
                            const SizedBox(height: 2),
                            Text(v.locale,
                                style: MirraType.cochin(size: 12, color: MirraColors.muted)),
                          ],
                        ),
                      ),
                      Container(
                        width: 22,
                        height: 22,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: on ? MirraColors.ink : Colors.transparent,
                          border: on
                              ? null
                              : Border.all(color: MirraColors.muted2, width: 1.5),
                        ),
                        child: on
                            ? const Icon(Icons.check_rounded, size: 14, color: Colors.white)
                            : null,
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  // iOS voice names are like "Daniel" already; strip any "com.apple..." ids.
  String _displayName(String name) {
    if (name.contains('.')) {
      final parts = name.split('.');
      return parts.last.isEmpty ? name : parts.last;
    }
    return name;
  }
}
