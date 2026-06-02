import 'package:flutter/material.dart';

import '../../core/theme/colors.dart';
import '../../core/theme/spacing.dart';
import '../../core/theme/typography.dart';

/// Top bar used by the modal-style screens (profile, settings, …).
///
/// Mirrors the prototype `HeaderBar`: an optional leading control (a back
/// chevron or a downward "close" chevron), an optional centered title, and an
/// optional trailing action. The title stays centered regardless of the
/// leading/trailing widths.
class MirraHeader extends StatelessWidget {
  const MirraHeader({
    super.key,
    this.title,
    this.onBack,
    this.backIsClose = false,
    this.trailing,
  });

  /// Centered title text. When null, no title is shown.
  final String? title;

  /// Tapped when the leading control is pressed. When null, no leading control.
  final VoidCallback? onBack;

  /// Use a downward chevron ("dismiss sheet") instead of a back arrow.
  final bool backIsClose;

  /// Optional trailing action (e.g. a "Settings" or "Add" text button).
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.of(context).padding.top;
    return Padding(
      padding: EdgeInsets.fromLTRB(12, (top > 0 ? top : 12) + 8, 12, 8),
      child: SizedBox(
        height: 36,
        child: Stack(
          alignment: Alignment.center,
          children: [
            if (title != null)
              Center(
                child: Text(
                  title!,
                  style: MirraType.ui(size: 16, weight: FontWeight.w600),
                ),
              ),
            if (onBack != null)
              Align(
                alignment: Alignment.centerLeft,
                child: GestureDetector(
                  onTap: onBack,
                  behavior: HitTestBehavior.opaque,
                  child: Padding(
                    padding: const EdgeInsets.all(4),
                    child: Icon(
                      backIsClose
                          ? Icons.keyboard_arrow_down_rounded
                          : Icons.arrow_back_ios_new_rounded,
                      size: backIsClose ? 28 : 20,
                      color: MirraColors.ink,
                    ),
                  ),
                ),
              ),
            if (trailing != null)
              Align(alignment: Alignment.centerRight, child: trailing!),
          ],
        ),
      ),
    );
  }
}

/// A simple text action used in a header trailing slot.
class HeaderTextAction extends StatelessWidget {
  const HeaderTextAction({super.key, required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
        child: Text(
          label,
          style: MirraType.ui(size: 15, weight: FontWeight.w500),
        ),
      ),
    );
  }
}

/// Small uppercase section label that sits above a [ListGroup].
class SectionLabel extends StatelessWidget {
  const SectionLabel(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 18, 4, 8),
      child: Text(
        text.toUpperCase(),
        style: MirraType.ui(
          size: 11,
          color: MirraColors.muted,
          weight: FontWeight.w700,
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}

/// A rounded card that vertically stacks [ListRow]s with hairline dividers.
class ListGroup extends StatelessWidget {
  const ListGroup({super.key, required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final rows = <Widget>[];
    for (var i = 0; i < children.length; i++) {
      rows.add(children[i]);
      if (i != children.length - 1) {
        rows.add(
          const Divider(
            height: 1,
            thickness: 1,
            indent: 52,
            color: MirraColors.line,
          ),
        );
      }
    }
    return Container(
      decoration: BoxDecoration(
        color: MirraColors.surface,
        borderRadius: BorderRadius.circular(MirraRadius.md),
        border: Border.all(color: MirraColors.line),
      ),
      child: Column(children: rows),
    );
  }
}

/// A single tappable row inside a [ListGroup]: icon, label, trailing value /
/// chevron.
class ListRow extends StatelessWidget {
  const ListRow({
    super.key,
    required this.icon,
    required this.label,
    this.value,
    this.onTap,
    this.showChevron = true,
  });

  final IconData icon;
  final String label;

  /// Optional trailing value text shown before the chevron.
  final String? value;
  final VoidCallback? onTap;
  final bool showChevron;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
        child: Row(
          children: [
            Icon(icon, size: 18, color: MirraColors.ink2),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                label,
                style: MirraType.ui(size: 15, weight: FontWeight.w500),
              ),
            ),
            if (value != null) ...[
              Text(
                value!,
                style: MirraType.ui(size: 13, color: MirraColors.muted),
              ),
              const SizedBox(width: 6),
            ],
            if (showChevron)
              const Icon(
                Icons.chevron_right_rounded,
                size: 20,
                color: MirraColors.muted2,
              ),
          ],
        ),
      ),
    );
  }
}
