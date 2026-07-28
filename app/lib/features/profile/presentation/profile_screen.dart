import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/auth/auth_provider.dart';
import '../../../core/i18n/strings.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/typography.dart';
import '../../../shared/widgets/tap_icon.dart';
import '../../favorites/providers/favorites_provider.dart';
import '../../onboarding/presentation/answer_chips.dart';
import '../../onboarding/presentation/onboarding_questions.dart';
import '../../onboarding/providers/onboarding_provider.dart';
import '../../preferences/presentation/settings_widgets.dart';
import '../../premium/providers/premium_provider.dart';
import '../../streak/providers/streak_provider.dart';

/// Soft card fill, identical to the Preferences rows, so Profile shares the
/// exact same design language and palette as the rest of the settings.
const _softCard = Color(0xFFF4F2F8);

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  /// Opens the same chips as the onboarding for this question; persisting on
  /// close also reschedules notifications when time/frequency changed.
  Future<void> _editAnswer(
    BuildContext context,
    WidgetRef ref,
    OnbQuestion question,
  ) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) => Padding(
        padding: EdgeInsets.fromLTRB(
          20,
          20,
          20,
          MediaQuery.of(sheetContext).viewInsets.bottom + 28,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              question.title,
              style: MirraType.cochin(size: 20, weight: FontWeight.w700),
            ),
            if (question.subtitle != null) ...[
              const SizedBox(height: 4),
              Text(
                question.subtitle!,
                style: MirraType.cochin(size: 13, color: MirraColors.muted),
              ),
            ],
            const SizedBox(height: 16),
            AnswerChips(question: question),
          ],
        ),
      ),
    );
    await ref.read(onboardingProvider.notifier).persist();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favs = ref.watch(favoritesProvider);
    final answers = ref.watch(onboardingProvider);
    final streak = ref.watch(streakProvider).count;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 4, 8, 0),
              child: MirraBackButton(onTap: () => context.pop()),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 0),
              child: Text(
                ref.tr('Profile'),
                style: MirraType.cochin(size: 24, weight: FontWeight.w800),
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 40),
                children: [
                  SettingsSectionLabel(ref.tr('Account')),
                  const _AccountCard(),
                  SettingsSectionLabel(ref.tr('Your journey')),
                  Row(
                    children: [
                      Expanded(
                        child: _StatCard(
                          label: ref.tr('Day streak'),
                          value: '$streak',
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _StatCard(
                          label: ref.tr('Favorites'),
                          value: '${favs.length}',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  if (ref.watch(isPremiumProvider))
                    _PremiumBadge(label: ref.tr('Mirra+ member'))
                  else
                    _UpsellRow(
                      label: ref.tr('Get Mirra+ — go unlimited'),
                      onTap: () => context.push('/paywall'),
                    ),
                  SettingsSectionLabel(ref.tr('Your answers')),
                  for (final q in kOnboardingQuestions)
                    if (answers[q.id] != null)
                      _AnswerRow(
                        title: q.title,
                        value: answers[q.id]!,
                        onTap: () => _editAnswer(context, ref, q),
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

/// Sign-in / account block, restyled onto the soft settings card. Signed out →
/// Apple + Google buttons. Signed in → the account email + sign out. Login is
/// optional; it exists so custom themes can be tied to the account.
class _AccountCard extends ConsumerWidget {
  const _AccountCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authProvider);

    if (auth.status == AuthStatus.signedIn) {
      return Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: _softCard,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: const BoxDecoration(
                gradient: MirraColors.gradSoft,
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: const Icon(Icons.person_rounded,
                  color: MirraColors.ink, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    ref.tr('Signed in'),
                    style: MirraType.carmenSans(
                        size: 12, color: MirraColors.muted),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    auth.email ?? ref.tr('Your account'),
                    style: MirraType.cochin(size: 15, weight: FontWeight.w700),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            GestureDetector(
              onTap: () => ref.read(authProvider.notifier).signOut(),
              behavior: HitTestBehavior.opaque,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                child: Text(
                  ref.tr('Sign out'),
                  style: MirraType.carmenSans(
                      size: 13, color: MirraColors.muted),
                ),
              ),
            ),
          ],
        ),
      );
    }

    final busy = auth.busy;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _softCard,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            ref.tr('Save your themes'),
            style: MirraType.cochin(size: 16, weight: FontWeight.w700),
          ),
          const SizedBox(height: 4),
          Text(
            ref.tr('Sign in to keep your custom themes tied to your account — '
                'on every device, even after reinstalling.'),
            style: MirraType.carmenSans(
                size: 13, color: MirraColors.muted, height: 1.3),
          ),
          const SizedBox(height: 14),
          _SignInButton(
            onTap: busy
                ? null
                : () => ref.read(authProvider.notifier).signInWithApple(),
            bg: Colors.black,
            fg: Colors.white,
            icon: const Icon(Icons.apple, color: Colors.white, size: 22),
            label: ref.tr('Continue with Apple'),
          ),
          const SizedBox(height: 10),
          _SignInButton(
            onTap: busy
                ? null
                : () => ref.read(authProvider.notifier).signInWithGoogle(),
            bg: Colors.white,
            fg: MirraColors.ink,
            border: MirraColors.chipLine,
            icon: Container(
              width: 22,
              alignment: Alignment.center,
              child: const Text(
                'G',
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 17,
                  color: Color(0xFF4285F4),
                ),
              ),
            ),
            label: ref.tr('Continue with Google'),
          ),
          if (busy) ...[
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(
                  width: 14,
                  height: 14,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
                const SizedBox(width: 8),
                Text(ref.tr('One moment…'),
                    style: MirraType.carmenSans(
                        size: 12, color: MirraColors.muted)),
              ],
            ),
          ],
          if (auth.error != null) ...[
            const SizedBox(height: 8),
            Text(auth.error!,
                style: MirraType.carmenSans(
                    size: 12, color: const Color(0xFFCB4B3F))),
          ],
        ],
      ),
    );
  }
}

class _SignInButton extends StatelessWidget {
  const _SignInButton({
    required this.onTap,
    required this.bg,
    required this.fg,
    required this.icon,
    required this.label,
    this.border,
  });

  final VoidCallback? onTap;
  final Color bg;
  final Color fg;
  final Widget icon;
  final String label;
  final Color? border;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Opacity(
        opacity: onTap == null ? 0.5 : 1,
        child: Container(
          height: 52,
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(999),
            border: border != null ? Border.all(color: border!) : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              icon,
              const SizedBox(width: 10),
              Text(label, style: MirraType.carmenSans(size: 15, color: fg)),
            ],
          ),
        ),
      ),
    );
  }
}

/// Two-up stat tile on the soft settings card.
class _StatCard extends StatelessWidget {
  const _StatCard({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _softCard,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: MirraType.cochin(size: 28, weight: FontWeight.w800),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: MirraType.cochin(size: 13, color: MirraColors.muted),
          ),
        ],
      ),
    );
  }
}

/// Active-member badge, soft lavender accent.
class _PremiumBadge extends StatelessWidget {
  const _PremiumBadge({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 54,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        gradient: MirraColors.gradSoft,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          const Icon(Icons.workspace_premium_rounded,
              size: 20, color: MirraColors.ink),
          const SizedBox(width: 12),
          Text(
            label,
            style: MirraType.cochin(size: 15, weight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}

/// Mirra+ upsell row — same shape as a settings row, lavender accent fill.
class _UpsellRow extends StatelessWidget {
  const _UpsellRow({required this.label, required this.onTap});
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        height: 54,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          gradient: MirraColors.gradSoft,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            const Icon(Icons.workspace_premium_rounded,
                size: 20, color: MirraColors.ink),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: MirraType.cochin(size: 15, weight: FontWeight.w700),
              ),
            ),
            const Icon(Icons.chevron_right_rounded,
                size: 20, color: MirraColors.muted2),
          ],
        ),
      ),
    );
  }
}

/// Editable onboarding answer, on the soft settings card with an edit affordance.
class _AnswerRow extends StatelessWidget {
  const _AnswerRow({
    required this.title,
    required this.value,
    required this.onTap,
  });
  final String title;
  final String value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: _softCard,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      title,
                      style: MirraType.cochin(
                        size: 13,
                        color: MirraColors.muted,
                      ),
                    ),
                  ),
                  const Icon(Icons.edit_outlined,
                      size: 15, color: MirraColors.muted2),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: MirraType.cochin(size: 15, weight: FontWeight.w700),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
