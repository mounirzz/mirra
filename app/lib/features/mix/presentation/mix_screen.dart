import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/i18n/strings.dart';
import 'category_picker.dart';

/// Mix — pick one or more categories to shape the feed. Shares its interface
/// and backend selection with Content preferences via [CategoryPickerView].
class MixScreen extends ConsumerWidget {
  const MixScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return CategoryPickerView(
      title: ref.tr('Mix'),
      subtitle: ref.tr('Pick one or more categories to shape your feed.'),
    );
  }
}
