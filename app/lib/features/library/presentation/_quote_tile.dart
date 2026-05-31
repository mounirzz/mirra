import 'package:flutter/material.dart';

import '../../../core/theme/colors.dart';
import '../../../core/theme/spacing.dart';
import '../../../core/theme/typography.dart';
import '../../../shared/models/quote.dart';

class LibraryQuoteTile extends StatelessWidget {
  const LibraryQuoteTile({
    super.key,
    required this.quote,
    this.trailing,
    this.subtitle,
    this.onTap,
  });

  final Quote quote;
  final Widget? trailing;
  final String? subtitle;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.all(MirraSpace.md),
        decoration: BoxDecoration(
          color: MirraColors.surface,
          borderRadius: BorderRadius.circular(MirraRadius.lg),
          border: Border.all(color: MirraColors.line),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(quote.text,
                style: MirraType.serif(size: 18, height: 1.3),
                maxLines: 3,
                overflow: TextOverflow.ellipsis),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    subtitle ?? '— ${quote.author}',
                    style: MirraType.ui(
                        size: 12, color: MirraColors.muted),
                  ),
                ),
                ?trailing,
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class LibraryEmpty extends StatelessWidget {
  const LibraryEmpty({super.key, required this.title, required this.subtitle});
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                gradient: MirraColors.gradSoft,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.collections_bookmark_outlined,
                  size: 32, color: MirraColors.ink),
            ),
            const SizedBox(height: 24),
            Text(title,
                style: MirraType.serif(size: 24).copyWith(height: 1.2)),
            const SizedBox(height: 8),
            Text(subtitle,
                textAlign: TextAlign.center,
                style:
                    MirraType.ui(size: 14, color: MirraColors.muted)),
          ],
        ),
      ),
    );
  }
}
