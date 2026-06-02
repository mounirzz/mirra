import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/colors.dart';
import '../../../core/theme/spacing.dart';
import '../../../core/theme/typography.dart';
import '../../../shared/widgets/mirra_chrome.dart';

/// Preferences hub (`mirra-preferences.jsx` → PreferencesScreen). Sectioned
/// list of settings; Language is wired to a real subscreen, the rest surface a
/// coming-soon notice until their Phase-2 screens land.
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  void _comingSoon(BuildContext context, String label) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: MirraColors.ink,
          content: Text(
            '$label — coming soon',
            style: MirraType.ui(size: 14, color: Colors.white),
          ),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MirraColors.surface,
      body: Column(
        children: [
          MirraHeader(title: 'Preferences', onBack: () => context.pop()),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(22, 4, 22, 28),
              children: [
                const SectionLabel('Premium'),
                ListGroup(children: [
                  ListRow(
                    icon: Icons.workspace_premium_outlined,
                    label: 'Manage subscription',
                    onTap: () => _comingSoon(context, 'Manage subscription'),
                  ),
                ]),
                const SectionLabel('Make it yours'),
                ListGroup(children: [
                  ListRow(
                    icon: Icons.tune_rounded,
                    label: 'Content preferences',
                    onTap: () => _comingSoon(context, 'Content preferences'),
                  ),
                  ListRow(
                    icon: Icons.person_outline_rounded,
                    label: 'Gender identity',
                    onTap: () => _comingSoon(context, 'Gender identity'),
                  ),
                  ListRow(
                    icon: Icons.volume_off_outlined,
                    label: 'Muted content',
                    onTap: () => _comingSoon(context, 'Muted content'),
                  ),
                  ListRow(
                    icon: Icons.language_rounded,
                    label: 'Language',
                    value: 'English',
                    onTap: () => context.push('/settings/language'),
                  ),
                  ListRow(
                    icon: Icons.badge_outlined,
                    label: 'Name',
                    onTap: () => _comingSoon(context, 'Name'),
                  ),
                  ListRow(
                    icon: Icons.volume_up_outlined,
                    label: 'Sound',
                    onTap: () => _comingSoon(context, 'Sound'),
                  ),
                  ListRow(
                    icon: Icons.graphic_eq_rounded,
                    label: 'Voice',
                    onTap: () => _comingSoon(context, 'Voice'),
                  ),
                  ListRow(
                    icon: Icons.mic_none_rounded,
                    label: 'Add Siri Shortcuts',
                    onTap: () => _comingSoon(context, 'Siri Shortcuts'),
                  ),
                ]),
                const SectionLabel('Account'),
                ListGroup(children: [
                  ListRow(
                    icon: Icons.login_rounded,
                    label: 'Sign in',
                    onTap: () => _comingSoon(context, 'Sign in'),
                  ),
                ]),
                const SectionLabel('Support us'),
                ListGroup(children: [
                  ListRow(
                    icon: Icons.ios_share_rounded,
                    label: 'Share Mirra',
                    onTap: () => _comingSoon(context, 'Share Mirra'),
                  ),
                  ListRow(
                    icon: Icons.apps_rounded,
                    label: 'More by Mirra Studio',
                    onTap: () => _comingSoon(context, 'More by Mirra Studio'),
                  ),
                  ListRow(
                    icon: Icons.reviews_outlined,
                    label: 'Leave us a review',
                    onTap: () => _comingSoon(context, 'Leave a review'),
                  ),
                ]),
                const SectionLabel('Help'),
                ListGroup(children: [
                  ListRow(
                    icon: Icons.help_outline_rounded,
                    label: 'Help',
                    onTap: () => _comingSoon(context, 'Help'),
                  ),
                ]),
                const SectionLabel('Other'),
                ListGroup(children: [
                  ListRow(
                    icon: Icons.description_outlined,
                    label: 'Privacy Policy',
                    onTap: () => _comingSoon(context, 'Privacy Policy'),
                  ),
                  ListRow(
                    icon: Icons.description_outlined,
                    label: 'Terms and Conditions',
                    onTap: () => _comingSoon(context, 'Terms and Conditions'),
                  ),
                ]),
                const SizedBox(height: 20),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: MirraColors.tile,
                    borderRadius: BorderRadius.circular(MirraRadius.sm),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Mirra app — version 6.1.1',
                              style: MirraType.ui(
                                size: 12,
                                weight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'User ID: F7399D6E-1F45-41AC-8099-E…',
                              style: MirraType.ui(
                                size: 11,
                                color: MirraColors.muted,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(
                        Icons.copy_rounded,
                        size: 16,
                        color: MirraColors.ink,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
