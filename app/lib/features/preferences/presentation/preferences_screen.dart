import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../shared/share_anchor.dart';

import '../../../core/auth/auth_provider.dart';
import '../../../core/i18n/language_provider.dart';
import '../../../core/i18n/strings.dart';
import '../../../core/theme/typography.dart';
import '../../../shared/widgets/tap_icon.dart';
import '../providers/settings_providers.dart';
import 'settings_widgets.dart';

/// Preferences menu, modeled on Motivation's: PREMIUM / MAKE IT YOURS /
/// ACCOUNT / SUPPORT US sections of rounded rows, each opening a sub-screen.
class PreferencesScreen extends ConsumerWidget {
  const PreferencesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final language = ref.watch(languageProvider);
    final name = ref.watch(displayNameProvider);
    final muted = ref.watch(mutedCategoriesProvider);
    final signedIn = ref.watch(isSignedInProvider);

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
                ref.tr('Preferences'),
                style: MirraType.cochin(size: 24, weight: FontWeight.w800),
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 40),
                children: [
                  SettingsSectionLabel(ref.tr('Premium')),
                  SettingsRow(
                    icon: Icons.workspace_premium_outlined,
                    label: ref.tr('Manage subscription'),
                    onTap: () => context.push('/preferences/subscription'),
                  ),
                  SettingsSectionLabel(ref.tr('Make it yours')),
                  SettingsRow(
                    icon: Icons.menu_book_outlined,
                    label: ref.tr('Content preferences'),
                    onTap: () => context.push('/preferences/content'),
                  ),
                  SettingsRow(
                    icon: Icons.person_outline_rounded,
                    label: ref.tr('Gender identity'),
                    onTap: () => context.push('/preferences/gender'),
                  ),
                  SettingsRow(
                    icon: Icons.voice_over_off_outlined,
                    label: ref.tr('Muted content'),
                    trailing: muted.isEmpty ? null : '${muted.length}',
                    onTap: () => context.push('/preferences/muted'),
                  ),
                  SettingsRow(
                    icon: Icons.language_rounded,
                    label: ref.tr('Language'),
                    trailing: language.label,
                    onTap: () => context.push('/preferences/language'),
                  ),
                  SettingsRow(
                    icon: Icons.badge_outlined,
                    label: ref.tr('Name'),
                    trailing: name,
                    onTap: () => context.push('/preferences/name'),
                  ),
                  SettingsRow(
                    icon: Icons.volume_up_outlined,
                    label: ref.tr('Sound'),
                    onTap: () => context.push('/preferences/sound'),
                  ),
                  SettingsRow(
                    icon: Icons.record_voice_over_outlined,
                    label: ref.tr('Voice'),
                    onTap: () => context.push('/preferences/voice'),
                  ),
                  SettingsRow(
                    icon: Icons.mic_none_rounded,
                    label: ref.tr('Siri'),
                    onTap: () => context.push('/siri'),
                  ),
                  SettingsRow(
                    icon: Icons.notifications_none_rounded,
                    label: ref.tr('Reminders'),
                    onTap: () => context.push('/preferences/reminders'),
                  ),
                  SettingsRow(
                    icon: Icons.palette_outlined,
                    label: ref.tr('App theme'),
                    onTap: () => context.push('/theme'),
                  ),
                  SettingsSectionLabel(ref.tr('Account')),
                  SettingsRow(
                    icon: Icons.account_circle_outlined,
                    label: signedIn ? ref.tr('My account') : ref.tr('Sign in'),
                    onTap: () => context.push('/profile'),
                  ),
                  SettingsSectionLabel(ref.tr('Support us')),
                  Builder(
                    builder: (rowContext) => SettingsRow(
                      icon: Icons.ios_share_rounded,
                      label: ref.tr('Share Mirra'),
                      onTap: () => shareAnchored(
                        rowContext,
                        'Mirra — daily affirmations that actually feel '
                        'like you. Try it 💜',
                      ),
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
