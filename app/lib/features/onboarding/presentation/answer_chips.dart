import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/colors.dart';
import '../../../core/theme/spacing.dart';
import '../../../core/theme/typography.dart';
import '../../../shared/widgets/primary_button.dart';
import '../providers/onboarding_provider.dart';
import 'onboarding_questions.dart';

/// The answers of one onboarding question rendered as full-width list rows
/// (each with a radio circle). Shared between the onboarding flow and the
/// profile's answer editor. For single-choice questions, [onSingleSelect] (if
/// provided) fires after a pick so the caller can auto-advance.
class AnswerChips extends ConsumerWidget {
  const AnswerChips({super.key, required this.question, this.onSingleSelect});

  final OnbQuestion question;
  final VoidCallback? onSingleSelect;

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

    void select(String opt) {
      final notifier = ref.read(onboardingProvider.notifier);
      if (question.isMulti) {
        notifier.toggleMulti(question.id, opt, question.maxSelections);
      } else {
        notifier.answer(question.id, opt);
        onSingleSelect?.call();
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final opt in question.options) ...[
          OptionRow(
            label: opt,
            selected: question.isMulti
                ? multiSelected.contains(opt)
                : selected == opt,
            onTap: () => select(opt),
          ),
          const SizedBox(height: 10),
        ],
        for (final custom in customValues) ...[
          OptionRow(
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
          const SizedBox(height: 10),
        ],
        if (question.allowCustom)
          OptionRow(
            label: 'Write your own…',
            icon: Icons.edit_outlined,
            selected: false,
            onTap: () => _writeCustomAnswer(context, ref),
          ),
      ],
    );
  }
}

/// Full-width option row: label on the left, radio circle on the right.
class OptionRow extends StatelessWidget {
  const OptionRow({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
    this.icon,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        curve: Curves.easeOut,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: selected ? MirraColors.chip : MirraColors.surface,
          borderRadius: BorderRadius.circular(MirraRadius.pill),
          border: Border.all(
            color: selected ? MirraColors.ink : MirraColors.chipLine,
            width: 1.4,
          ),
        ),
        child: Row(
          children: [
            if (icon != null) ...[
              Icon(icon, size: 18, color: MirraColors.ink2),
              const SizedBox(width: 10),
            ],
            Expanded(
              child: Text(
                label,
                style: MirraType.carmenSans(size: 16, color: MirraColors.ink),
              ),
            ),
            // radio circle
            Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: selected ? MirraColors.ink : Colors.transparent,
                border: selected
                    ? null
                    : Border.all(color: MirraColors.muted2, width: 1.5),
              ),
              child: selected
                  ? const Icon(Icons.check_rounded, size: 14, color: Colors.white)
                  : null,
            ),
          ],
        ),
      ),
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
