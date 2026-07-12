import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/colors.dart';
import '../../../core/theme/spacing.dart';
import '../../../core/theme/typography.dart';
import '../../../shared/widgets/chip_option.dart';
import '../../../shared/widgets/primary_button.dart';
import '../providers/onboarding_provider.dart';
import 'onboarding_questions.dart';

/// The answer chips of one onboarding question — options, user-written
/// values, and the "Write your own…" entry. Shared between the onboarding
/// flow and the profile's answer editor so both behave identically.
class AnswerChips extends ConsumerWidget {
  const AnswerChips({super.key, required this.question});

  final OnbQuestion question;

  Future<void> _writeCustomAnswer(BuildContext context, WidgetRef ref) async {
    final text = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: MirraColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) => const CustomAnswerSheet(),
    );

    // Commas would corrupt the ', '-joined multi-answer storage.
    final cleaned = text?.replaceAll(',', ' ').trim() ?? '';
    if (cleaned.isEmpty) return;
    final notifier = ref.read(onboardingProvider.notifier);
    if (question.isMulti) {
      notifier.toggleMulti(question.id, cleaned, question.maxSelections);
    } else {
      notifier.answer(question.id, cleaned);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final answers = ref.watch(onboardingProvider);
    final selected = answers[question.id];
    final multiSelected = OnboardingNotifier.splitMulti(selected);
    final customValues = [
      for (final v in question.isMulti ? multiSelected : [?selected])
        if (!question.options.contains(v)) v,
    ];

    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: [
        for (final opt in question.options)
          ChipOption(
            label: opt,
            selected: question.isMulti
                ? multiSelected.contains(opt)
                : selected == opt,
            onTap: () {
              final notifier = ref.read(onboardingProvider.notifier);
              if (question.isMulti) {
                notifier.toggleMulti(question.id, opt, question.maxSelections);
              } else {
                notifier.answer(question.id, opt);
              }
            },
          ),
        for (final custom in customValues)
          ChipOption(
            label: custom,
            selected: true,
            onTap: () {
              final notifier = ref.read(onboardingProvider.notifier);
              if (question.isMulti) {
                notifier.toggleMulti(
                  question.id,
                  custom,
                  question.maxSelections,
                );
              } else {
                notifier.clearAnswer(question.id);
              }
            },
          ),
        if (question.allowCustom)
          ChipOption(
            label: 'Write your own…',
            icon: Icons.edit_outlined,
            selected: false,
            onTap: () => _writeCustomAnswer(context, ref),
          ),
      ],
    );
  }
}

/// Small input sheet for "Write your own…" answers. Owns its controller so
/// it survives the sheet's exit animation.
class CustomAnswerSheet extends StatefulWidget {
  const CustomAnswerSheet({super.key});

  @override
  State<CustomAnswerSheet> createState() => _CustomAnswerSheetState();
}

class _CustomAnswerSheetState extends State<CustomAnswerSheet> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        MirraSpace.lg,
        MirraSpace.lg,
        MirraSpace.lg,
        MediaQuery.of(context).viewInsets.bottom + MirraSpace.lg,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Your answer',
            style: MirraType.cochin(size: 20, weight: FontWeight.w700),
          ),
          const SizedBox(height: MirraSpace.md),
          TextField(
            controller: _controller,
            autofocus: true,
            maxLength: 30,
            textCapitalization: TextCapitalization.sentences,
            onSubmitted: (value) => Navigator.of(context).pop(value),
            style: MirraType.cochin(size: 17, weight: FontWeight.w700),
            decoration: InputDecoration(
              hintText: 'Type it here…',
              hintStyle: MirraType.cochin(size: 17, color: MirraColors.muted2),
              filled: true,
              fillColor: MirraColors.bg,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(MirraRadius.md),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: MirraSpace.md),
          PrimaryButton(
            label: 'Add',
            onPressed: () => Navigator.of(context).pop(_controller.text),
          ),
        ],
      ),
    );
  }
}
