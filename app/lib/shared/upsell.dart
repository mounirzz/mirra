import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/i18n/strings.dart';

/// Floating snackbar shown when a free-plan cap is hit (favorites, categories,
/// own quotes…), with a one-tap shortcut into the Mirra+ paywall.
void showFreeLimitUpsell(BuildContext context, WidgetRef ref, String message) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
        action: SnackBarAction(
          label: ref.tr('Get Mirra+'),
          onPressed: () => context.push('/paywall'),
        ),
      ),
    );
}
