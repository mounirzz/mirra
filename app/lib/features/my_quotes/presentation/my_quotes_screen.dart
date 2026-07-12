import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/colors.dart';
import '../../../core/theme/spacing.dart';
import '../../../core/theme/typography.dart';
import '../../../shared/models/quote.dart';
import '../../../shared/widgets/app_background.dart';
import '../../../shared/widgets/ios_status_bar.dart';
import '../../../shared/widgets/tap_icon.dart';
import '../../../shared/widgets/primary_button.dart';
import '../../premium/providers/premium_provider.dart';
import '../providers/own_quotes_provider.dart';

class MyQuotesScreen extends ConsumerWidget {
  const MyQuotesScreen({super.key});

  /// Free plan: 2 personal affirmations. The 3rd is a Mirra+ moment.
  static const _freeLimit = 2;

  Future<void> _openEditor(
    BuildContext context,
    WidgetRef ref, {
    Quote? existing,
  }) async {
    final isNew = existing == null;
    if (isNew &&
        !ref.read(isPremiumProvider) &&
        ref.read(ownQuotesProvider).length >= _freeLimit) {
      context.push('/paywall');
      return;
    }
    final text = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: MirraColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) =>
          _AffirmationEditor(initialText: existing?.text ?? ''),
    );

    final trimmed = text?.trim() ?? '';
    if (trimmed.isEmpty) return;
    final notifier = ref.read(ownQuotesProvider.notifier);
    if (existing == null) {
      await notifier.add(trimmed);
    } else {
      await notifier.edit(existing.id, trimmed);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final quotes = ref.watch(ownQuotesProvider);

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openEditor(context, ref),
        backgroundColor: MirraColors.ink,
        child: const Icon(Icons.add_rounded, color: Colors.white),
      ),
      body: AppBackground(
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const IosStatusSpacer(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: MirraSpace.lg),
                child: Row(
                  children: [
                    MirraBackButton(onTap: () => context.pop()),
                    const SizedBox(width: 8),
                    Text(
                      'My affirmations',
                      style: MirraType.cochin(
                        size: 26,
                        weight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: MirraSpace.md),
              Expanded(
                child: quotes.isEmpty
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(40),
                          child: Text(
                            'Write your own affirmations —\nwhat you tell yourself matters most.',
                            textAlign: TextAlign.center,
                            style: MirraType.cochin(
                              size: 15,
                              color: MirraColors.muted,
                              height: 1.4,
                            ),
                          ),
                        ),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.fromLTRB(
                          MirraSpace.lg,
                          0,
                          MirraSpace.lg,
                          100,
                        ),
                        itemCount: quotes.length,
                        separatorBuilder: (context, i) =>
                            const SizedBox(height: MirraSpace.sm),
                        itemBuilder: (context, i) {
                          final q = quotes[i];
                          return Container(
                            padding: const EdgeInsets.all(MirraSpace.md),
                            decoration: BoxDecoration(
                              color: MirraColors.surface,
                              borderRadius: BorderRadius.circular(
                                MirraRadius.lg,
                              ),
                              border: Border.all(color: MirraColors.line),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  q.text,
                                  style: MirraType.serif(size: 18, height: 1.3),
                                ),
                                const SizedBox(height: 10),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    TapIcon(
                                      icon: Icons.edit_outlined,
                                      size: 18,
                                      color: MirraColors.muted,
                                      semanticLabel: 'Edit affirmation',
                                      onTap: () => _openEditor(
                                        context,
                                        ref,
                                        existing: q,
                                      ),
                                    ),
                                    TapIcon(
                                      icon: Icons.delete_outline_rounded,
                                      size: 18,
                                      color: MirraColors.danger,
                                      semanticLabel: 'Delete affirmation',
                                      onTap: () => ref
                                          .read(ownQuotesProvider.notifier)
                                          .remove(q.id),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Bottom-sheet editor that owns its text controller, so the controller
/// outlives the sheet's exit animation (disposing it from the caller while
/// the TextField was still animating out crashed the app).
class _AffirmationEditor extends StatefulWidget {
  const _AffirmationEditor({required this.initialText});

  final String initialText;

  @override
  State<_AffirmationEditor> createState() => _AffirmationEditorState();
}

class _AffirmationEditorState extends State<_AffirmationEditor> {
  late final TextEditingController _controller = TextEditingController(
    text: widget.initialText,
  );

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
            widget.initialText.isEmpty ? 'New affirmation' : 'Edit affirmation',
            style: MirraType.cochin(size: 20, weight: FontWeight.w700),
          ),
          const SizedBox(height: MirraSpace.md),
          TextField(
            controller: _controller,
            autofocus: true,
            maxLines: 4,
            minLines: 2,
            maxLength: 220,
            textCapitalization: TextCapitalization.sentences,
            style: MirraType.serif(size: 20, height: 1.3),
            decoration: InputDecoration(
              hintText: 'I am…',
              hintStyle: MirraType.serif(size: 20, color: MirraColors.muted2),
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
            label: 'Save',
            onPressed: () => Navigator.of(context).pop(_controller.text),
          ),
        ],
      ),
    );
  }
}
